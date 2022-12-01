import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genome_2133/tabs/faq.dart';
import 'package:genome_2133/tabs/login.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../home.dart';
import 'contact.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      body: SafeArea(
          child: Column(children: [
            Stack(
              children: [
                Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Row(
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
                              color: Theme.of(context).dialogBackgroundColor,
                            ),
                          ),
                        ),
                        Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "Settings",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Theme.of(context).dialogBackgroundColor
                                ),
                              ),
                            )
                        )
                      ]
                    )
                )
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("User Info", style: TextStyle(fontSize: 24)),
                                const Text("\n"),
                                Text("Email: ${FirebaseAuth.instance.currentUser!.email!}", style: const TextStyle(fontSize: 16)),
                                const Text("\n"),
                                Text("Account Created: ${DateFormat("MMMM d, yyyy").format(FirebaseAuth.instance.currentUser!.metadata.creationTime!)}", style: const TextStyle(fontSize: 16)),
                                const Text("\n"),
                                Text("User ID: ${FirebaseAuth.instance.currentUser!.uid}", style: const TextStyle(fontSize: 16)),
                              ],
                            )
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(padding: EdgeInsets.all(12)),
                              const Text("Account Management", style: TextStyle(fontSize: 24)),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut().then((value) {
                                      user = null;
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
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
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!)
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
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Error: $error"),
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
                                    padding: EdgeInsets.all(12),
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
                                padding: const EdgeInsets.all(12),
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
                                                await FirebaseAuth.instance.currentUser!.delete().then((value) {
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
                                                      title: Text("Error: $error"),
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
                                    padding: EdgeInsets.all(12),
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

                          )
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(padding: EdgeInsets.all(12)),
                              const Text("Other", style: TextStyle(fontSize: 24)),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      "Enable Dark Mode",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              if (!isDesktop)
                                Padding(
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState((){
                                      isMapDisabled = !isMapDisabled;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      isMapDisabled ? "Enable Map" : "Disable Map",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context, builder: (_) => contact(context));
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      "Contact Us",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () => launchUrl(Uri.parse(
                                            'https://github.com/Fried-man/genome_2133#readme')),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      "Credits",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                      ),
                                    ),
                                  ),
                                )

                              //const Text("\n\n\n"),
                            ]
                        )
                      ],
                    ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("FAQ", style: TextStyle(fontSize: 24)),
                          FutureBuilder(
                              future: rootBundle.loadString("assets/data.json"),
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                if (!snapshot.hasData) return Container();
                                return recursiveList(json.decode(snapshot.data!)["FAQ"]);
                              }),
                        ],

                      ),
                    ],
                  )
                )
                 ,
              ),
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FutureBuilder<String>(
                    future: getVersion(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return Text(
                        'Version: ${snapshot.hasData ? snapshot.data! : 'unknown'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      );
                    }),
              ),
            ),
      ])),
    );
  }
}

Future<String> getVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return "v${packageInfo.version} (${packageInfo.buildNumber})";
}
