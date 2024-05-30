import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test/main.dart';

import 'model.dart';

class LoggedInPage extends StatefulWidget {
  const LoggedInPage({
    required this.userData,
    required this.logOut,
    required this.context,
  });

  final UserModel userData;
  final void Function(BuildContext) logOut;
  final BuildContext context;

  @override
  State<LoggedInPage> createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Fetched User Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userData.displayPicture),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              widget.userData.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              widget.userData.email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.userData.accountType,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                widget.logOut(widget.context);
              },
              style: ButtonStyle(
                elevation: const MaterialStatePropertyAll(0),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                backgroundColor:
                    const MaterialStatePropertyAll(Colors.lightBlueAccent),
              ),
              child: const Text(
                'SignOut',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
