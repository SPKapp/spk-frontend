import 'package:flutter/material.dart';

class OnLoad extends StatefulWidget {
  const OnLoad({
    super.key,
    required this.child,
    required this.onLoad,
  });

  final Widget child;
  final void Function(BuildContext) onLoad;

  @override
  State<OnLoad> createState() => _OnLoadState();
}

class _OnLoadState extends State<OnLoad> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoad(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
