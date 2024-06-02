import 'package:flutter/material.dart';

Future<void> showModalMyBottomSheet<T>({
  required Widget Function(BuildContext) builder,
  required String title,
  required BuildContext context,
  void Function(T)? onClosing,
}) async {
  final result = await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        widthFactor: 1.0,
        heightFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: builder(context),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (result != null && context.mounted) {
    onClosing?.call(result);
  }
}
