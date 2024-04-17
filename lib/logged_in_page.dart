import 'package:flutter/material.dart';

class LoggedInPage extends StatelessWidget {
  const LoggedInPage({required this.userData});
  final userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(''),
        ),
        SizedBox(
          height: 50,
        ),
        Text(
          '',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Text(
          '',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
