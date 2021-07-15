import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DialogsHelper {
  void showMessageDialogWith(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  Future<ImageSource?> showActionSheetForImagePicker(
      BuildContext context) async {
    if (Platform.isIOS) {
      final source = await showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text("Choose Option"),
              message: const Text('Select option to select image.'),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                  child: Text("Camera"),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                  child: Text("Gallery"),
                ),
              ],
              cancelButton: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.red,
                      ))),
            );
          });
      return source;
    } else {
      final source = await showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Wrap(children: [
                ListTile(
                    title: Text(
                      "Camera",
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.pop(context, ImageSource.camera);
                    }),
                ListTile(
                    title: Text(
                      "Gallery",
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.pop(context, ImageSource.gallery);
                    }),
                ListTile(
                    title: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    }),
              ]),
            );
          });
      return source;
    }
  }
}
