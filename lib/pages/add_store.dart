import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/view_models/add_store_view_model.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({Key? key}) : super(key: key);

  @override
  _AddStorePageState createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final _formKey = GlobalKey<FormState>();

  late AddStoreViewModel _addStoreViewModel;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _addressController.dispose();
  }

  void showDialogPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(""),
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

  void _saveButtonTapped(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_addStoreViewModel.imageFile != null) {
        context.loaderOverlay.show();
        final fetchedMap = await _addStoreViewModel.uploadImage();

        final bool isUploaded = fetchedMap["isUploaded"] as bool;
        if (isUploaded) {
          _addStoreViewModel.url = fetchedMap["url"] as String;
          final isSaved = await _addStoreViewModel.saveStore();
          context.loaderOverlay.hide();
          if (isSaved) {
            Navigator.pop(context);
          }
        } else {
          context.loaderOverlay.hide();
          showDialogPopup(context, "Error occurred while uploading the image");
        }
      } else {
        context.loaderOverlay.show();
        final isSaved = await _addStoreViewModel.saveStore();
        context.loaderOverlay.hide();
        if (isSaved) {
          Navigator.pop(context);
        }
      }
    } else {
      print('Addddd');
    }
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: _addStoreViewModel.imageFile != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_addStoreViewModel.imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Column(children: [
                            Expanded(child: Container()),
                            Row(
                              children: [
                                Expanded(child: Container()),
                                TextButton(
                                    onPressed: () {
                                      _deleteImage();
                                    },
                                    child: Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.redAccent,
                                    ))
                              ],
                            ),
                          ])
                        ],
                      )
                    : Icon(Icons.image_aspect_ratio),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "Enter Store Name",
                  hintText: "e.g. Reliance Market",
                ),
                onChanged: (value) {
                  _addStoreViewModel.name = value;
                },
                validator: (val) {
                  if (val == null) {
                    return 'Please enter name';
                  } else if (val.length == 0) {
                    return 'Please enter name';
                  } else if (val.length < 2) {
                    return 'Name should be greater than 2 charcters.';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "Enter Store Address",
                  hintText: "e.g. Adda Link Road",
                ),
                onChanged: (value) {
                  _addStoreViewModel.address = value;
                },
                validator: (val) {
                  if (val == null) {
                    return 'Please enter address';
                  } else if (val.length == 0) {
                    return 'Please enter address';
                  } else if (val.length < 2) {
                    return 'Address should be greater than 2 characters.';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                _addStoreViewModel.message,
                style: TextStyle(fontSize: 15, color: Colors.redAccent),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () => _saveButtonTapped(context),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _addStoreViewModel = Provider.of<AddStoreViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Store'),
        actions: [
          TextButton(
              onPressed: () async {
                _showActionSheet(context);
              },
              child: Icon(Icons.add_a_photo, color: Colors.white))
        ],
      ),
      body: LoaderOverlay(child: _buildBody(context)),
    );
  }

  Future _pickImage(ImageSource source) async {
    final imageFile = await _picker.getImage(source: source);
    _addStoreViewModel.setImageFile(imageFile);
  }

  void _deleteImage() {
    _addStoreViewModel.setImageFile(null);
  }

  void _showActionSheet(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text("Choose Option"),
              message: const Text('Select option to select image.'),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  child: Text("Camera"),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
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
    } else {
      showModalBottomSheet(
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
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    }),
                ListTile(
                    title: Text(
                      "Gallery",
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
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
    }
  }
}
