import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:test/consts.dart';
import 'package:test/model.dart';
import 'package:test/publicKeyFetch.dart';

// const clientId = '506132801757-6j4ce5noo1po91j1r68eoq6dp0kqgag5.apps.googleusercontent.com';

const clientId = webClientId;

// serverAuthCode/idToken will be generated only if I use web client id.

class GoogleAuthApi {
  late SharedPreferences prefs;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: [
      'email',
      'profile',
      // 'https://www.googleapis.com/auth/userinfo.email',
      // 'https://www.googleapis.com/auth/userinfo.profile',
      // 'openid',
    ],
  );

  Future<UserModel> signUp() async {
    prefs = await SharedPreferences.getInstance();
    final publicKey = prefs.getString('publicKey') ?? '';

    UserModel res = UserModel.empty();
    try {
      _googleSignIn.signOut();
      debugPrint('-------------STARTING SIGNING IN ');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // authenticate user
      final GoogleSignInAuthentication googleUserAuthentication =
          await googleUser!.authentication;

      debugPrint('-----------------${googleUser.serverAuthCode}\n');

      debugPrint('-----------------${googleUserAuthentication.accessToken}\n');
      debugPrint('-----------------${googleUserAuthentication.idToken}\n\n\n');

      // encrypt idToken.
      final encryptedToken = await encryptIdToken(
          googleUserAuthentication.idToken!,
          // 'You bought a High-End Gamepad, but it doesn’t actually work with 99% of Android Games, right?',
          publicKey);

      debugPrint(
          '-------------------Cypher Token : ${encryptedToken.toString()}');

      final userData = await _handleLogin(
        encryptedToken.toString(),
      );
      //

      // debugPrint(
      //     '-------------------FINAL DATA Map<String, String> : $userData');
      // res = UserModel.fromJson(userData['data']['data']);
    } on Exception catch (e) {
      // Handle exceptions gracefully (e.g., show a snackbar)
      debugPrint('Error signing in: $e');
    }

    return res;
  }

  Future<dynamic> _handleLogin(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          "Content-Type": 'application/json',
        },
        body: jsonEncode({
          "token": idToken,
        }),
      );

      debugPrint('${response.statusCode}');
      debugPrint(response.body);
      final res = jsonDecode(response.body);
      // debugPrint('----------TOKEN : ${res['token']}');
      //
      await prefs.setString('token', res['token']);
      debugPrint(
          '------------------LOCAL TOKEN :  ${prefs.getString('token')}');

      final userData = await _getUserData();
      return userData;
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
    //
    // } else {
    //   // Handle login failure (e.g., show an error message)
    //   debugPrint('Login failed: ${response.statusCode}');
    // }
  }

  Future<dynamic> _getUserData() async {
    String localToken = prefs.getString('token') ?? '';

    if (localToken == null) throw Exception();

    final headers = {
      'Authorization': 'Bearer $localToken',
    };

    const userDataApiString = currentUserUrl;
    final userDataApiUri = Uri.parse(userDataApiString);
    try {
      final userDataResponse = await http.get(
        userDataApiUri,
        headers: headers,
      );
      if (userDataResponse.statusCode == 200) {
        // Handle successful user data retrieval
        debugPrint('\n\n\nUser data retrieved successfully!');
        // debugPrint(userDataResponse.body);

        // Process the user data as needed
        final userData = jsonDecode(userDataResponse.body);
        return userData;
        // Do something with the user data, e.g., update UI, store in local database, etc.
      } else {
        // Handle user data retrieval failure
        debugPrint(
            'User data retrieval failed: ${userDataResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
