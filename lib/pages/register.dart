import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/utils/dialogs.dart';
import 'package:flutter_todo/view_models/register_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/utils/string_extension.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<TextEditingController> _editingControllers =
      List.generate(4, (d) => TextEditingController());
  late RegisterViewModel _registerViewModel;

  void _registerButtonTapped(BuildContext context) {
    FocusScope.of(context).unfocus();

    final name = _editingControllers[0].text;
    final email = _editingControllers[1].text;
    final password = _editingControllers[2].text;

    if (name.length == 0) {
      DialogsHelper()
          .showMessageDialogWith(context, "Alert!", "Please enter name.");
    } else if (name.length < 2) {
      DialogsHelper()
          .showMessageDialogWith(context, "Alert!", "Please enter valid name.");
    } else if (email.length == 0) {
      DialogsHelper().showMessageDialogWith(
          context, "Alert!", "Please enter email address.");
    } else if (email.length < 2) {
      DialogsHelper().showMessageDialogWith(
          context, "Alert!", "Please enter valid email address.");
    } else if (!email.isValidEmail()) {
      DialogsHelper().showMessageDialogWith(
          context, "Alert!", "Please enter valid email address.");
    } else if (password.length == 0) {
      DialogsHelper()
          .showMessageDialogWith(context, "Alert!", "Please enter password.");
    } else if (password.length < 8) {
      DialogsHelper().showMessageDialogWith(
          context, "Alert!", "Password must be of atleast 8 characters.");
    } else if (_registerViewModel.dob == null) {
      DialogsHelper().showMessageDialogWith(
          context, "Alert!", "Please select date of birth.");
    } else if (_registerViewModel.qualification ==
        RegisterViewModel.dropDownPlaceholder) {
      DialogsHelper().showMessageDialogWith(
          context, "Alert!", "Please select qualification.");
    } else {
      registerUser(context);
    }
  }

  Future<void> registerUser(BuildContext context) async {
    context.loaderOverlay.show();

    try {
      final imageUrl = await uploadProfilePicture();
      final isUserCreated = await _registerViewModel.createUser();
      if (isUserCreated) {
        final isLoggedIn = await _registerViewModel.loginUser();
        await _registerViewModel.registerUser(imageURL: imageUrl);
        Navigator.pop(context, true);
        context.loaderOverlay.hide();
      } else {
        context.loaderOverlay.hide();
        DialogsHelper().showMessageDialogWith(
            context, "Alert!", "Something went wrong! Please try again later!");
      }
    } catch (e) {
      context.loaderOverlay.hide();
      DialogsHelper().showMessageDialogWith(context, "Alert!", e.toString());
    }
  }

  Future<String?> uploadProfilePicture() async {
    if (_registerViewModel.imageFile != null) {
      final result = await _registerViewModel.uploadImage();
      if (result["isUploaded"]) {
        return result["url"];
      } else {
        throw Exception("Error in uploading image.");
      }
    } else {
      return null;
    }
  }

  void _selectDate(BuildContext context) async {
    final pickeddate = await showDatePicker(
        context: context,
        initialDate: DateTime(2002, 12, 31),
        firstDate: DateTime(1900, 1, 1),
        lastDate: DateTime(2002, 12, 31));

    if (pickeddate != null) {
      setState(() {
        _editingControllers[3].text =
            DateFormat("dd MMM, yyyy").format(pickeddate);
        _registerViewModel.dob = pickeddate;
      });
    }
  }

  Future<void> _imageBtnTapped(BuildContext context) async {
    final source = await DialogsHelper().showActionSheetForImagePicker(context);
    if (source != null) {
      final _picker = ImagePicker();
      final imageFile = await _picker.getImage(source: source);
      _registerViewModel.setImageFile(imageFile);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _editingControllers.forEach((element) {
      element.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    _registerViewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
        body: SafeArea(
      child: LoaderOverlay(
        child: Container(
          padding: EdgeInsets.all(30),
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: ListView(shrinkWrap: true, children: [
              _buildImageView(),
              SizedBox(
                height: 25,
              ),
              _textFields(),
              _bottomButton()
            ]),
          ),
        ),
      ),
    ));
  }

  Widget _textFields() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CupertinoTextField.borderless(
          controller: _editingControllers[0],
          padding: EdgeInsets.all(16),
          placeholder: "Name",
          placeholderStyle: TextStyle(color: Colors.grey[400]),
          cursorHeight: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[200],
          ),
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(64),
          ],
          onChanged: (value) {
            _registerViewModel.name = value;
          },
        ),
        SizedBox(
          height: 16,
        ),
        CupertinoTextField.borderless(
          controller: _editingControllers[1],
          padding: EdgeInsets.all(16),
          placeholder: "Email",
          placeholderStyle: TextStyle(color: Colors.grey[400]),
          cursorHeight: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[200],
          ),
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(265),
          ],
          onChanged: (value) {
            _registerViewModel.email = value;
          },
        ),
        SizedBox(
          height: 16,
        ),
        CupertinoTextField.borderless(
          controller: _editingControllers[2],
          padding: EdgeInsets.all(16),
          placeholder: "Password",
          placeholderStyle: TextStyle(color: Colors.grey[400]),
          cursorHeight: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[200],
          ),
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            LengthLimitingTextInputFormatter(16),
          ],
          onChanged: (value) {
            _registerViewModel.password = value;
          },
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio(
              value: Gender.Male,
              groupValue: _registerViewModel.gender,
              onChanged: (value) {
                setState(() {
                  _registerViewModel.gender = Gender.Male;
                });
              },
            ),
            GestureDetector(
              child: Text(
                "Male",
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  _registerViewModel.gender = Gender.Male;
                });
              },
            ),
            SizedBox(
              width: 16,
            ),
            Radio(
              value: Gender.Female,
              groupValue: _registerViewModel.gender,
              onChanged: (value) {
                setState(() {
                  _registerViewModel.gender = Gender.Female;
                });
              },
            ),
            GestureDetector(
              child: Text(
                "Female",
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  _registerViewModel.gender = Gender.Female;
                });
              },
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Stack(
            children: [
              CupertinoTextField.borderless(
                controller: _editingControllers[3],
                padding: EdgeInsets.all(16),
                placeholder: "Date of Birth",
                placeholderStyle: TextStyle(color: Colors.grey[400]),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey[200],
                ),
                readOnly: true,
                enableInteractiveSelection: false,
                // enabled: false,
                suffix: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                  color: Colors.grey[600],
                ),
                suffixMode: OverlayVisibilityMode.always,
              ),
              GestureDetector(onTap: () {
                _selectDate(context);
              })
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: DropdownButton(
              underline: SizedBox.shrink(),
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                size: 40,
                color: Colors.grey[600],
              ),
              value: _registerViewModel.qualification,
              style: TextStyle(fontSize: 16, color: Colors.black),
              onChanged: (String? newValue) {
                setState(() {
                  _registerViewModel.qualification = newValue!;
                  setState(() {});
                });
              },
              items: RegisterViewModel.getQualifications()
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomButton() {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ))),
              onPressed: () {
                _registerButtonTapped(context);
              },
              child: Text("REGISTER")),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.black),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildImageView() {
    final size = MediaQuery.of(context).size;
    final image = _registerViewModel.imageFile == null
        ? Image.asset("images/profile.png", fit: BoxFit.cover)
        : Image.file(File(_registerViewModel.imageFile!.path),
            fit: BoxFit.cover);

    return Center(
      child: Stack(
        children: [
          Container(
            width: size.width * 0.5,
            height: size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(
                Radius.circular((size.width * 0.5) / 2),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: LayoutBuilder(builder: (context, contraint) {
                final size = contraint.maxWidth - 8;
                return Container(
                  width: size,
                  height: size,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.all(
                      Radius.circular(size),
                    ),
                  ),
                  child: image,
                );
              }),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: IconButton(
                  onPressed: () {
                    _imageBtnTapped(context);
                  },
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    size: 30,
                    color: Colors.white,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
