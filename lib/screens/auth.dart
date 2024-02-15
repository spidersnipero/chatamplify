// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chat_app/widgets/user_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = false;
  var _isAuthenticating = false;

  // crdentials
  var _userName = "";
  var _userEmail = "";
  var _userPassword = "";
  File? _userImageFile;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (!isValid) {
      return;
    }
    if (!_isLogin && _userImageFile == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please pick an image"),
          backgroundColor: Color.fromARGB(255, 45, 44, 44),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _auth.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
      } else {
        final userCredentials = await _auth.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_userImageFile!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          "username": _userName,
          "email": _userEmail,
          "image_url": imageUrl,
        });
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'email-already-in-use') {
        // ..
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message ?? "Authentication failed"),
          backgroundColor: const Color.fromARGB(255, 181, 41, 46),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, right: 20, left: 20),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            Userimagepicker(
                              imagePickFn: (pickedImage) {
                                _userImageFile = pickedImage;
                              },
                            ),
                          // text form feild for name
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Username",
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 4) {
                                  return "Please enter at least 4 characters";
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                _userName = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email address",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) => value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains("@")
                                ? "Please enter a valid email address"
                                : null,
                            onSaved: (value) {
                              _userEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.length < 6) {
                                return "Password must be at least 6 characters long";
                              } else {
                                return null;
                              }
                            },
                            obscureText: true,
                            onSaved: (value) {
                              _userPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              onPressed: () => {
                                _submit(),
                              },
                              child: Text(_isLogin ? "Login" : "Sign up"),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () => {
                                setState(() {
                                  _isLogin = !_isLogin;
                                })
                              },
                              child: Text(_isLogin
                                  ? "Create an account"
                                  : "Already have an account ?"),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
