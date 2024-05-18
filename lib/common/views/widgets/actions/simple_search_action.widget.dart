import 'package:flutter/material.dart';

class SimpleSearchAction extends StatelessWidget {
  const SimpleSearchAction({
    super.key,
    required this.generateResults,
    required this.onClear,
  });

  final Widget Function(BuildContext, String) generateResults;
  final void Function() onClear;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        showSearch(
          context: context,
          delegate: _AppSearchDelegate(
            generateResults: generateResults,
            onClear: onClear,
          ),
        );
      },
    );
  }
}

class _AppSearchDelegate extends SearchDelegate {
  _AppSearchDelegate({
    required this.generateResults,
    required this.onClear,
  });

  final Widget Function(BuildContext, String) generateResults;
  final void Function() onClear;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            onClear();
          },
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
          onClear();
        },
      );

  @override
  Widget buildResults(BuildContext context) {
    return generateResults(context, query.toString());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return generateResults(context, query.toString());
  }
}
