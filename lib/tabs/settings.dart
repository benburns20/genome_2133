import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genome_2133/tabs/login.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.chevron_left,
                      size: MediaQuery.of(context).size.width / 30,
                    ),
                  ),
                ),
                const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          "Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30
                          ),
                      ),
                    )
                )
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("User Info", style: TextStyle(fontSize: 24)),
                    Text("Email: " + FirebaseAuth.instance.currentUser!.email!, style: const TextStyle(fontSize: 16)),
                    Text("Account Created: " + DateFormat("MMMM d, yyyy").format(FirebaseAuth.instance.currentUser!.metadata.creationTime!), style: const TextStyle(fontSize: 16)),
                    Text("User ID: " + FirebaseAuth.instance.currentUser!.uid, style: const TextStyle(fontSize: 16)),
                    const Text("Accessibility", style: TextStyle(fontSize: 24)),
                    const Text("Account Management", style: TextStyle(fontSize: 24)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut().then((value) {
                            user = null;
                            Navigator.pop(context);
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!)
                              .whenComplete(() {
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
                            showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Error: " + error.toString()),
                                content: Text(stackTrace.toString()),
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
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Are you sure?"),
                              content: const Text("Account deletion is permanent."),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('NO'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text('YES'),
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).delete().whenComplete(() async {
                                      await FirebaseAuth.instance.currentUser!.delete().whenComplete(() {
                                        user = null;
                                        Navigator.pop(context);
                                        showDialog<void>(
                                          context: context,
                                          builder: (_) => const AlertDialog(
                                            title: Text("Account Deleted"),
                                          ),
                                        );
                                      })
                                          .onError((error, stackTrace) {
                                        if (error.toString() == "[firebase_auth/requires-recent-login] This operation is sensitive and requires recent authentication. Log in again before retrying this request.") {
                                          showDialog<void>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text("Expired Credentials"),
                                              content: const Text("Log back in to continue account deletion."),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                                TextButton(
                                                  child: const Text('LOG OUT'),
                                                  onPressed: () async {
                                                    await FirebaseAuth.instance.signOut().then((value) {
                                                      user = null;
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                                          builder: (context) => const Login()));
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }
                                        showDialog<void>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text("Error: " + error.toString()),
                                            content: Text(stackTrace.toString()),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Delete Account",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
      ])),
    );
  }
}
