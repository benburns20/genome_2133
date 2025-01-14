import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cards/continent.dart';
import '../cards/country.dart';
import '../cards/skeleton.dart';
import '../cards/variant.dart';
import '../home.dart';
import '../main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  Map<String, TextEditingController> inputText = {
    "Email": TextEditingController(),
    "Password": TextEditingController()
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dict[theme].secondaryHeaderColor,
      body: SafeArea(
          child: ListView(
            children: [Column(children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width / 20,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: MediaQuery.of(context).size.width / 5,
                        width: MediaQuery.of(context).size.width / 5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: inputText["Email"],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: inputText["Password"],
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize:
                                      MediaQuery.of(context).size.width / 61,
                                      color: Colors.black),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  for (String typeText in inputText.keys) {
                                    // null checks
                                    if (inputText[typeText]!.text.isEmpty) {
                                      throw CustomException('Fill in all fields');
                                    }
                                  }
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                      email: inputText['Email']!.text,
                                      password: inputText['Password']!.text)
                                      .then((value) async {
                                    user = FirebaseAuth.instance.currentUser;
                                    if (user != null && user!.emailVerified) {
                                      userData = (await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get()).data()!;
                                      if (userData.containsKey("theme")) {
                                        theme = userData["theme"];
                                      }
                                      if (userData.containsKey("map disabled")) {
                                        isMapDisabled = userData["map disabled"];
                                      }
                                      if (userData.containsKey("dyslexic")) {
                                        isDyslexic = userData["dyslexic"];
                                      }
                                      if (theme == "Dark Mode" && !isDesktop) {
                                        await DefaultAssetBundle.of(context).loadString('assets/data.json').then((string) {
                                          mapController.setMapStyle(json.encode(json.decode(string)["Dark Mode"]));
                                        });
                                      }
                                      context.findAncestorStateOfType<State<MyApp>>()!.setState(() {
                                        for (SkeletonCard currCard in windows) {
                                          if (currCard.body is VariantCard) {
                                            (currCard.body as VariantCard).controlKey.currentState!.updateState();
                                          }else if (currCard.body is CountryCard) {
                                            (currCard.body as CountryCard).controlKey.currentState!.updateState();
                                          }else if (currCard.body is ContinentCard) {
                                            (currCard.body as ContinentCard).controlKey.currentState!.updateState();
                                          }
                                        }
                                        Navigator.pop(context);
                                      });
                                      return;
                                    }
                                    throw CustomException("Email not verified");
                                  });
                                } on FirebaseAuthException catch (e) {
                                  String error = "Server error: ${e.code}";
                                  if (e.code == 'user-not-found') {
                                    error = 'No user found for that email.';
                                  } else if (e.code == 'wrong-password') {
                                    error = 'Wrong password provided for that user.';
                                  }
                                  createErrorScreen(error, context, "Sign in");
                                } on CustomException catch (e) {
                                  if (e.cause == "Email not verified") {
                                    showDialog<void>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Sign in Failure"),
                                        content: const Text("Verify account email"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Resend Email'),
                                            onPressed: () async {
                                              await user!.sendEmailVerification();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  createErrorScreen(e.cause, context, "Sign in");
                                } catch (e) {
                                  createErrorScreen(e.toString(), context, "Sign in");
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                      fontSize:
                                      MediaQuery.of(context).size.width / 61,
                                      color: Colors.black),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  for (String typeText in inputText.keys) {
                                    // null checks
                                    if (inputText[typeText]!.text.isEmpty) {
                                      throw CustomException('Fill in all fields');
                                    }
                                  }
                                  // valid email check
                                  String email = inputText['Email']!.text;
                                  if (!email.contains('@') ||
                                      !email.contains('.') ||
                                      email.indexOf('.') == (email.length - 1)) {
                                    throw CustomException('Fill in a valid email');
                                  }
                                  // create account
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                      email: email,
                                      password: inputText['Password']!.text)
                                      .then((value) async {
                                    user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title:
                                          const Text("Account Created"),
                                          content: const Text(
                                              "Verify your email before logging in."),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({"saved" : []});
                                      await user!
                                          .sendEmailVerification();
                                      await FirebaseAuth.instance
                                          .signOut();
                                    }
                                  });
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    createErrorScreen(
                                        "The password provided is too weak.",
                                        context,
                                        "Registration");
                                  } else if (e.code == 'email-already-in-use') {
                                    createErrorScreen(
                                        "The account already exists for that email.",
                                        context,
                                        "Registration");
                                  }
                                } on CustomException catch (e) {
                                  createErrorScreen(e.cause, context, "Registration");
                                } catch (e) {
                                  createErrorScreen(
                                      e.toString(), context, "Registration");
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: inputText["Email"]!.text)
                            .then((value) {
                          showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Password Reset Email Sent"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        })
                            .onError((error, stackTrace) {
                              String body = "";
                              print(error);
                              if (error.toString() == "[firebase_auth/missing-email] Error") {
                                error = "No Email Provided";
                                body = "Enter email in field.";
                              }else if (error.toString() == "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                                error = "No User Found";
                                body = "There is no user record corresponding to this identifier. The user may have been deleted.";
                              }
                          showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Error: $error"),
                              content: Text(body.isNotEmpty ? body : stackTrace.toString()),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                      child: const Align(
                          alignment: Alignment.centerRight,
                          child: Text("Forgot password?")),
                    )
                  ],
                ),
              ),
            ])]
          )),
    );
  }
}

class CustomException implements Exception {
  String cause;

  CustomException(this.cause);
}

void createErrorScreen(error, context, sourceString) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(sourceString + " Failure"),
      content: Text(error),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
