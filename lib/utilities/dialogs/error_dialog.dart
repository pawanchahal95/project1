import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'an error occurred ',
    content: text,
    optionBuilder: ()=>{
      'OK':null,
    },
  );
}
