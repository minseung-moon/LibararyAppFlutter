import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UDialog {
  static void confirm(BuildContext context, {
    required String title,
    required String content,
    required DialogAction positive,
    DialogAction? negative,
  }) {
    switch(Theme.of(context).platform) {
      case TargetPlatform.iOS:
        _showCupertinoStyle(context,
            title: title,
            content: content,
            positive: positive,
            negative: negative);
        break;
      default:
        _showMaterialStyle(context,
            title: title,
            content: content,
            positive: positive,
            negative: negative);
        break;

    }
  }

  // Material UI
  static void _showMaterialStyle(BuildContext context, {
    required String title,
    required String content,
    required DialogAction positive,
    DialogAction? negative,
  }) {
    showDialog(context: context, builder: (BuildContext context) =>
      AlertDialog(
        //title: Text(title),
        content: Text(content),
        actions: [
          positive.createActionMaterial(context),
          if(negative != null) negative.createActionMaterial(context),
        ],
      )
    );
  }

  // Cupertino UI
  static void _showCupertinoStyle(BuildContext context, {
    required String title,
    required String content,
    required DialogAction positive,
    DialogAction? negative,
  }) {
    showCupertinoDialog(context: context, builder: (BuildContext context) =>
      CupertinoAlertDialog(
        //title: Text(title),
        content: Text(content),
        actions: [
          positive.createActionCupertino(context, isDefaultAction: true),
          if(negative != null) negative.createActionCupertino(context, isDestructiveAction: true)
        ],
      )
    );
  }
}

class DialogAction {
  String text;
  OnPressed? event;

  DialogAction(this.text, this.event);

  void _onDismiss(BuildContext context) { Navigator.pop(context); }

  VoidFunction _invokeOnFunction(BuildContext context) => () {
    if(event != null && !event!()) return;

    _onDismiss(context);
  };

  TextButton createActionMaterial(BuildContext context) =>
      TextButton(onPressed: _invokeOnFunction(context), child: Text(text));

  CupertinoDialogAction createActionCupertino(BuildContext context, {
    bool isDefaultAction = false,
    bool isDestructiveAction = false
  }) => CupertinoDialogAction(child: Text(text),
    onPressed: _invokeOnFunction(context),
    isDefaultAction: isDefaultAction,
    isDestructiveAction: isDestructiveAction,);
}

typedef OnPressed = bool Function();
typedef VoidFunction = void Function();

