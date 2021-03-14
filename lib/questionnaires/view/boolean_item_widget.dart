import 'package:fhir/r4.dart';
import 'package:fhir/r4/resource_types/clinical/diagnostics/diagnostics.dart';
import 'package:flutter/material.dart';

import '../questionnaires.dart';

class BooleanItemAnswer extends QuestionnaireAnswerFiller {
  const BooleanItemAnswer(
      QuestionnaireLocation location, AnswerLocation answerLocation,
      {Key? key})
      : super(location, answerLocation, key: key);
  @override
  State<StatefulWidget> createState() => _BooleanItemState();
}

class _BooleanItemState
    extends QuestionnaireAnswerState<Boolean, BooleanItemAnswer> {
  _BooleanItemState();

  @override
  void initState() {
    super.initState();
    initialValue = widget.answerLocation.answer?.valueBoolean;
  }

  @override
  Widget buildReadOnly(BuildContext context) {
    return Text(value?.toString() ?? '');
  }

  @override
  Widget buildEditable(BuildContext context) {
    return Checkbox(
      value: value?.value,
      tristate: true,
      onChanged: (newValue) {
        value = (newValue != null) ? Boolean(newValue) : null;
      },
    );
  }

  @override
  QuestionnaireResponseAnswer? fillAnswer() =>
      (value != null) ? QuestionnaireResponseAnswer(valueBoolean: value) : null;
}
