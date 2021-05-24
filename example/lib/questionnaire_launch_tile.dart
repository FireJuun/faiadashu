import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:faiadashu/resource_provider/resource_provider.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

/// Tile that launches a [QuestionnaireScrollerPage] when tapped.
class QuestionnaireLaunchTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String questionnairePath;
  final Locale? locale;
  final FhirResourceProvider fhirResourceProvider;
  final void Function(String id, QuestionnaireResponse? questionnaireResponse)
      saveResponseFunction;
  final void Function(String id, QuestionnaireResponse? questionnaireResponse)
      uploadResponseFunction;
  final QuestionnaireResponse? Function(String id) restoreResponseFunction;

  const QuestionnaireLaunchTile(
      {required this.title,
      this.subtitle,
      this.locale,
      required this.questionnairePath,
      required this.fhirResourceProvider,
      required this.saveResponseFunction,
      required this.uploadResponseFunction,
      required this.restoreResponseFunction,
      Key? key})
      : super(key: key);

  @override
  _QuestionnaireLaunchTileState createState() =>
      _QuestionnaireLaunchTileState();
}

class _QuestionnaireLaunchTileState extends State<QuestionnaireLaunchTile> {
  late final FhirResourceProvider _questionnaireProvider;

  @override
  void initState() {
    super.initState();
    _questionnaireProvider = AssetResourceProvider.singleton(
        questionnaireResourceUri, widget.questionnairePath);
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);

    return ListTile(
      title: Text(widget.title),
      subtitle: (widget.subtitle != null) ? Text(widget.subtitle!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.preview),
        onPressed: () async {
          final questionnaireModel =
              await QuestionnaireModel.fromFhirResourceBundle(
                  fhirResourceProvider: _questionnaireProvider,
                  locale: locale,
                  aggregators: [NarrativeAggregator()]);
          questionnaireModel.populate(
              widget.restoreResponseFunction.call(widget.questionnairePath));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NarrativePage(
                        questionnaireModel: questionnaireModel,
                      )));
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionnaireScrollerPage(
                locale: locale,
                fhirResourceProvider: RegistryFhirResourceProvider([
                  AssetResourceProvider.singleton(
                      questionnaireResourceUri, widget.questionnairePath),
                  InMemoryResourceProvider.inMemory(
                      questionnaireResponseResourceUri,
                      widget.restoreResponseFunction(widget.questionnairePath)),
                  widget.fhirResourceProvider
                ]),
                persistentFooterButtons: [
                  Builder(
                    builder: (context) => ElevatedButton.icon(
                      label: const Text('Upload'),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      onPressed: () {
                        // Generate a response and upload it to a FHIR server.
                        // TODO: In a real-world scenario this should have more state handling.
                        widget.uploadResponseFunction.call(
                            widget.questionnairePath,
                            QuestionnaireFiller.of(context)
                                .aggregator<QuestionnaireResponseAggregator>()
                                .aggregate(
                                    responseStatus:
                                        QuestionnaireResponseStatus.completed));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Uploading survey…')));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Builder(
                    builder: (context) => ElevatedButton.icon(
                      label: const Text('Save Locally'),
                      icon: const Icon(Icons.save_alt),
                      onPressed: () {
                        // Generate a response and store it in-memory.
                        // In a real-world scenario one would persist or post the response instead.
                        widget.saveResponseFunction.call(
                            widget.questionnairePath,
                            QuestionnaireFiller.of(context)
                                .aggregator<QuestionnaireResponseAggregator>()
                                .aggregate());
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Survey saved.')));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}
