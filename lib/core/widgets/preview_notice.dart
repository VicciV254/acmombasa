import 'package:flutter/material.dart';

/// Used by dashboard controls that have no real behaviour yet, so they never
/// silently pretend to work.
void showPreviewNotice(BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Preview only: this action is not connected yet.'),
        duration: Duration(seconds: 2),
      ),
    );
}
