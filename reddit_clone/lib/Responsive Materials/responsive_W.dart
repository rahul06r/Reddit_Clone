import 'package:flutter/material.dart';

class ResponsiveW extends StatelessWidget {
  final Widget child;
  const ResponsiveW({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: child,
      ),
    );
  }
}
