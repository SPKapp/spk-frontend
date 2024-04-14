import 'package:flutter/material.dart';

class RabbitInfoButton extends StatelessWidget {
  const RabbitInfoButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.right = false,
  });

  final void Function() onPressed;
  final String text;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 2.0,
        bottom: 2.0,
        left: right ? 2.0 : 8.0,
        right: right ? 8.0 : 2.0,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 2.0,
          bottom: 2.0,
          left: right ? 2.0 : 8.0,
          right: right ? 8.0 : 2.0,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
