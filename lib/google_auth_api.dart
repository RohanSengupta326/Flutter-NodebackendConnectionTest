import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// const clientId = '506132801757-6j4ce5noo1po91j1r68eoq6dp0kqgag5.apps.googleusercontent.com';

const clientId =
    '506132801757-guitla7d7odcao08n23ilgkm3v207bkh.apps.googleusercontent.com';

// for idToken to not be null, we have use clientId as web client id then only idToken won't be null.

// serverAuthCode/idToken will be generated only if I use web client id. openid scopes is required
// get serverAuthCode too.

class GoogleAuthApi {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid',
    ],
  );

  Future<void> signUp() async {
    try {
      _googleSignIn.signOut();
      debugPrint('-------------STARTING SIGNING IN ');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // authenticate user
      final GoogleSignInAuthentication googleUserAuthentication =
          await googleUser!.authentication;


      debugPrint('-----------------${googleUser.serverAuthCode}\n');

      debugPrint('-----------------${googleUserAuthentication.accessToken}\n');
      debugPrint('-----------------${googleUserAuthentication.idToken}\n');

      await _handleLogin(
        googleUserAuthentication.idToken!,
      );
    } on Exception catch (e) {
      // Handle exceptions gracefully (e.g., show a snackbar)
      debugPrint('Error signing in: $e');
    }
  }

  Future<dynamic> _handleLogin(String accessToken) async {

    try {
      final response = await http.post(
        Uri.parse('https://analytics.mantispro.app:5100/api/v1/users/auth/google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': accessToken,
        }),
      );

      debugPrint('${response.statusCode}');
      debugPrint(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }

    // if (response.statusCode == 200) {
    //   // Handle successful login (e.g., navigate to a home screen)
    //   debugPrint('Login successful!\n');
    //   debugPrint(response.body);
    //   // Process the response from your backend (e.g., extract JWT token)

    // final prefs = await SharedPreferences.getInstance();
    //   await prefs.setString('token', response.body);

    //   // Make the second API request to retrieve user data
    //   final userData = await _getUserData(response.body);
    // return userData;
    // } else {
    //   // Handle login failure (e.g., show an error message)
    //   debugPrint('Login failed: ${response.statusCode}');
    // }
  }

  Future<void> _getUserData(String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    const userDataApiString = '';
    final userDataApiUri = Uri.parse(userDataApiString);
    final userDataResponse = await http.get(
      userDataApiUri,
      headers: headers,
    );

    if (userDataResponse.statusCode == 200) {
      // Handle successful user data retrieval
      debugPrint('User data retrieved successfully!');
      debugPrint(userDataResponse.body);

      // Process the user data as needed
      final userData = jsonDecode(userDataResponse.body);
      return userData;
      // Do something with the user data, e.g., update UI, store in local database, etc.
    } else {
      // Handle user data retrieval failure
      debugPrint('User data retrieval failed: ${userDataResponse.statusCode}');
    }
  }
}
