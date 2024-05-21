import 'package:flutter/material.dart';

import 'model.dart';

class LoggedInPage extends StatelessWidget {
  const LoggedInPage({required this.userData});

  final UserModel userData;

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
              backgroundImage: NetworkImage(userData.displayPicture),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              userData.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              userData.email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userData.accountType,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
