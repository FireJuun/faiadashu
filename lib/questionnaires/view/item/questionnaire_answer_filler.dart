import 'package:fhir/r4/r4.dart';
import 'package:flutter/material.dart';

import '../../../fhir_types/fhir_types_extensions.dart';
import '../../../logging/logging.dart';
import '../../questionnaires.dart';

/// A Widget to fill an individual [QuestionnaireResponseAnswer].
abstract class QuestionnaireAnswerFiller extends StatefulWidget {
  final QuestionnaireLocation location;
  final AnswerLocation answerLocation;
  static final logger = Logger(QuestionnaireAnswerFiller);

  const QuestionnaireAnswerFiller(this.location, this.answerLocation,
      {Key? key})
      : super(key: key);
}

abstract class QuestionnaireAnswerState<V, W extends QuestionnaireAnswerFiller>
    extends State<W> {
  static final logger = Logger(QuestionnaireAnswerState);
  V? _value;

  QuestionnaireAnswerState();

  Widget buildReadOnly(BuildContext context);

  Widget buildEditable(BuildContext context);

  QuestionnaireResponseAnswer? fillAnswer();

  List<QuestionnaireResponseAnswer>? fillChoiceAnswers() {
    throw UnimplementedError('fillChoiceAnswers not implemented.');
  }

  bool hasChoiceAnswers() => false;

  set value(V? newValue) {
    if (mounted) {
      setState(() {
        _value = newValue;
      });

      if (hasChoiceAnswers()) {
        widget.answerLocation.stashChoiceAnswers(fillChoiceAnswers());
      } else {
        widget.answerLocation.stashAnswer(fillAnswer());
      }
    }
  }

  // ignore: avoid_setters_without_getters
  set initialValue(V? initialValue) {
    logger.debug('initialValue ${widget.location.linkId} = $initialValue');
    _value = initialValue;
  }

  V? get value => _value;

  /// Returns the human-readable entry format.
  ///
  /// See: http://hl7.org/fhir/R4/extension-entryformat.html
  String? get entryFormat {
    return widget.location.questionnaireItem.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/entryFormat')
        ?.valueString;
  }

  @override
  Widget build(BuildContext context) {
    return widget.location.isReadOnly
        ? buildReadOnly(context)
        : buildEditable(context);
  }
}
