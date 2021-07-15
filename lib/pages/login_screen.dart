import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/Pages/store_list.dart';
import 'package:flutter_todo/pages/register.dart';
import 'package:flutter_todo/utils/dialogs.dart';
import 'package:flutter_todo/utils/string_extension.dart';
import 'package:flutter_todo/view_models/login_view_model.dart';
import 'package:flutter_todo/view_models/register_view_model.dart';
import 'package:flutter_todo/view_models/store_list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  late LoginViewModel _loginViewModel;

  final _emailController = TextEditingController();
  String _emailError = "";
  String _passwordError = "";
  final _passwordController = TextEditingController();

  void _loginButtonTapped(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_validateFields()) {
      final message = await _loginViewModel.loginUser();
      if (message != null) {
        DialogsHelper().showMessageDialogWith(context, "Alert!", message);
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ChangeNotifierProvider(
            create: (context) => StoreListViewModel(),
            child: StoresList(),
          );
        }));
      }
    }
  }

  bool _validateFields() {
    bool isVerified = false;

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() {
        _emailError = "Please enter email address.";
      });
    } else if (email.length < 2) {
      setState(() {
        _emailError = "Please enter valid email address.";
      });
    } else if (!email.isValidEmail()) {
      setState(() {
        _emailError = "Please enter valid email address.";
      });
    } else if (password.isEmpty) {
      setState(() {
        _emailError = "";
        _passwordError = "Please enter password.";
      });
    } else if (password.length < 8) {
      setState(() {
        _emailError = "";
        _passwordError = "Password must be of atleast 8 characters.";
      });
    } else {
      isVerified = true;
      setState(() {
        _emailError = "";
        _passwordError = "";
      });
    }

    return isVerified;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(30),
          child: Center(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(shrinkWrap: true,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Image.asset("images/logo.png"),
                    ),
                    CupertinoTextField.borderless(
                      controller: _emailController,
                      padding: EdgeInsets.all(16),
                      placeholder: "Email Address",
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
                        _loginViewModel.email = value;
                      },
                    ),
                    (_emailError == null || _emailError.length == 0)
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              _emailError,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                    SizedBox(
                      height: 16,
                    ),
                    CupertinoTextField.borderless(
                      controller: _passwordController,
                      obscureText: isObscurePassword,
                      padding: EdgeInsets.all(16),
                      placeholder: "Password",
                      placeholderStyle: TextStyle(color: Colors.grey[400]),
                      cursorHeight: 20,
                      suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              isObscurePassword = !isObscurePassword;
                            });
                          },
                          icon: Icon(
                            isObscurePassword ? Icons.lock_open : Icons.lock,
                            color: Colors.grey[600],
                          )),
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
                        _loginViewModel.password = value;
                      },
                    ),
                    (_passwordError.length == 0)
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _passwordError,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ))),
                          onPressed: () {
                            debugger();
                            _loginButtonTapped(context);
                          },
                          child: Text(AppLocalizations.of(context)!.login)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final isRegistered = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return ChangeNotifierProvider(
                                            create: (_) => RegisterViewModel(),
                                            child: RegisterPage());
                                      },
                                      fullscreenDialog: true));

                              if (isRegistered != null ||
                                  isRegistered == true) {
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChangeNotifierProvider(
                                    create: (context) => StoreListViewModel(),
                                    child: StoresList(),
                                  );
                                }));
                              }
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Don\'t have an account? ',
                                style: TextStyle(color: Colors.black),
                                children: const <TextSpan>[
                                  TextSpan(
                                      text: 'Sign Up',
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
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
