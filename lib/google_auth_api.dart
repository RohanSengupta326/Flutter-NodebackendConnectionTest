import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:test/consts.dart';
import 'package:test/model.dart';
import 'package:test/publicKeyFetch.dart';

const String hugeString =
    ''' Spider-Man's secret identity is Peter Benjamin Parker. Initially, Peter was depicted as a teenage high-school student and an orphan raised by his Aunt May and Uncle Ben in New York City after his parents Richard and Mary Parker died in a plane crash. Lee and Ditko had the character deal with the struggles of adolescence and financial issues and gave him many supporting characters, such as Flash Thompson, J. Jonah Jameson, and Harry Osborn; romantic interests Gwen Stacy, Mary Jane Watson, and the Black Cat; and enemies such as the Green Goblin, Doctor Octopus, and Venom. In his origin story, Spider-Man gets his superhuman spider-powers and abilities after being bitten by a radioactive spider. These powers include superhuman strength, agility, reflexes, stamina, durability, coordination, and balance; clinging to surfaces and ceilings like a spider; and detecting danger with his precognition ability called "spider-sense". He builds wrist-mounted "web-shooter" devices that shoot artificial spider-webs of his own design, which he uses both for fighting and for web-swinging across the city. Peter Parker originally used his powers for his own personal gain, but after his Uncle Ben was killed by a thief that Peter could not stop, he began to use his powers to fight crime by becoming Spider-Man.

When Spider-Man first appeared in the early 1960s, teenagers in superhero comic books were usually relegated to the role of sidekick to the protagonist. The Spider-Man comic series broke ground by featuring Peter Parker, a high school student from Queens, New York, as Spider-Man's secret identity, whose "self-obsessions with rejection, inadequacy, and loneliness" were issues to which young readers could relate.[8] While Spider-Man was a quintessential sidekick, unlike previous teen heroes Bucky Barnes and Robin, Spider-Man had no superhero mentor like Captain America and Batman; he had learned the lesson for himself that "with great power comes great responsibility"—a line included in a text box in the final panel of the first Spider-Man's origin story, but later retroactively attributed to the late Uncle Ben Parker.

Marvel has featured Spider-Man in several comic book series, the first and longest-lasting of which is The Amazing Spider-Man. Since his introduction, the main-continuity version of Peter has gone from a high school student to attending college to currently being somewhere in his late 20s. Peter has been a member of numerous superhero teams, most notably the Avengers and Fantastic Four. Doctor Octopus also took on the identity for a story arc spanning 2012–2014, following a body swap plot in which Peter appears to die.[9] Marvel has also published comic books featuring alternate versions of Spider-Man, including Spider-Man 2099, which features the adventures of Miguel O'Hara, the Spider-Man of the future; Ultimate Spider-Man, which features the adventures of a teenage Peter Parker in the alternate universe; and Ultimate Comics: Spider-Man, which depicts a teenager named Miles Morales who takes up the mantle of Spider-Man after Ultimate Peter Parker's apparent death. Miles later became a superhero in his own right and was brought into mainstream continuity during the Secret Wars event, where he sometimes works alongside the mainline version of Peter.''';

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

  UserModel res = UserModel.empty();

  // List<String> splitAndEncryptChunks(String data, int chunkSize, String pKey) {
  //   List<String> chunks = [];
  //   for (int i = 0; i < data.length; i += chunkSize) {
  //     int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
  //     // Encrypt the chunk before adding it to the list
  //     String encryptedChunk = encryptData(data.substring(i, end), pKey);
  //     chunks.add(encryptedChunk);
  //   }
  //   return chunks;
  // }

  // ---***---
  // To get User's system locale, system language , and android unique id :

  // https://gemini.google.com/app/bf1f56f7eb8f6fbd
  // android unique id : https://stackoverflow.com/questions/45031499/how-to-get-unique-device-id-in-flutter
  // ---***---

  Future<int> signUp() async {
    prefs = await SharedPreferences.getInstance();
    final publicKey = prefs.getString('pemPublicKey') ?? '';
    late int statusCode;
    debugPrint('--------------------Local Stored Public Key : $publicKey\n\n');

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
      // final encryptedToken = await encryptIdToken(
      //     // googleUserAuthentication.idToken!,
      //     'You bought a High-End Gamepad, but it doesn’t actually work with 99% of Android Games, right?',
      //     publicKey);

      // encrypt idToken.
      // final encryptedToken = encryptData(
      //     googleUserAuthentication.idToken!,
      //     // 'You bought a High-End Gamepad, but it doesn’t actually work with 99% of Android Games, right?',
      //     publicKey);

      // encrypt and create chunks
      // List<String> encryptedChunks = splitAndEncryptChunks(
      //     googleUserAuthentication.idToken!,
      //     // 'Rohan Sengupta',
      //     // hugeString,
      //     200,
      //     publicKey);

      // print('-------------------Encrypted Chunks : $encryptedChunks\n\n');
      // debugPrint(
      //     '-------------------Encrypted Chunks List Size : ${encryptedChunks.length}');
      // for (int i = 0; i < encryptedChunks.length; i++) {
      //   debugPrint('----$i : ${encryptedChunks[i]} ');
      // }

      // debugPrint(
      //     '-------------------Encrypted Chunks last element : ${encryptedChunks[2]}');

      // final userData = await _handleEncryptedChunksLogin(encryptedChunks);

      // AES + RSA.
      Map<String, String> encryptedDataMap = encryptDataWithAES(
          googleUserAuthentication.idToken!,
          // hugeString,
          // 'Mantis Pro Gaming',
          publicKey);

      print('-------------------EncryptedDataMap : $encryptedDataMap\n\n');

      statusCode = await _handleEncryptedDataMapLogin(encryptedDataMap);

      // final userData = await _handleLogin(
      //   encryptedToken.toString(),
      // );

      // debugPrint(
      //     '-------------------FINAL DATA Map<String, String> : $userData');
    } on Exception catch (e) {
      // Handle exceptions gracefully (e.g., show a snackbar)
      debugPrint('Error signing in: $e');
    }

    return statusCode;
  }

  Future<int> _handleEncryptedDataMapLogin(
      Map<String, String> encryptedDataMap) async {
    //
    int statusCodeInteger = 400;

    String jsonBody = jsonEncode(encryptedDataMap);
    debugPrint('Sending encrypted json: $jsonBody');

    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          "Content-Type": 'application/json',
        },
        body: jsonBody,
      );

      debugPrint('${response.statusCode}');
      statusCodeInteger = response.statusCode;
      print(response.body);
      final res = jsonDecode(response.body);
      debugPrint('----------Received TOKEN from server : ${res['token']}');
      //
      await prefs.setString('token', res['token']);
    } catch (e) {
      debugPrint(e.toString());
    }

    return statusCodeInteger;
  }

  // Future<void> _handleEncryptedChunksLogin(List<String> eChunks) async {
  //   String jsonBody = jsonEncode({"token": eChunks});
  //   // print('Sending encrypted chunks: $jsonBody');
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(authUrl),
  //       headers: {
  //         "Content-Type": 'application/json',
  //       },
  //       body: jsonBody,
  //     );
  //
  //     debugPrint('${response.statusCode}');
  //     print(response.body);
  //     final res = jsonDecode(response.body);
  //     debugPrint('----------Received TOKEN from server : ${res['token']}');
  //     //
  //     await prefs.setString('token', res['token']);
  //     debugPrint(
  //         '------------------Locally saved TOKEN :  ${prefs.getString('token')}');
  //
  //     // final userData = await _getUserData();
  //     // return userData;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<dynamic> _handleLogin(String idToken) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(authUrl),
  //       headers: {
  //         "Content-Type": 'application/json',
  //       },
  //       body: jsonEncode({
  //         "token": idToken,
  //       }),
  //     );
  //
  //     debugPrint('${response.statusCode}');
  //     debugPrint(response.body);
  //     final res = jsonDecode(response.body);
  //     // debugPrint('----------TOKEN : ${res['token']}');
  //     //
  //     await prefs.setString('token', res['token']);
  //     debugPrint(
  //         '------------------LOCAL TOKEN :  ${prefs.getString('token')}');
  //
  //     final userData = await _getUserData();
  //     return userData;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //
  //   // if (response.statusCode == 200) {
  //   //   // Handle successful login (e.g., navigate to a home screen)
  //   //   debugPrint('Login successful!\n');
  //   //   debugPrint(response.body);
  //   //   // Process the response from your backend (e.g., extract JWT token)
  //
  //   // final prefs = await SharedPreferences.getInstance();
  //   //   await prefs.setString('token', response.body);
  //
  //   //   // Make the second API request to retrieve user data
  //   //
  //   // } else {
  //   //   // Handle login failure (e.g., show an error message)
  //   //   debugPrint('Login failed: ${response.statusCode}');
  //   // }
  // }

  Future<UserModel> getUserData() async {
    String localToken = prefs.getString('token') ?? '';
    debugPrint('------------------Locally saved Received TOKEN :  $localToken');

    if (localToken == '') throw Exception();

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

        res = UserModel.fromJson(userData['data']['data']);
        // Do something with the user data, e.g., update UI, store in local database, etc.
      } else {
        // Handle user data retrieval failure
        debugPrint(
            'User data retrieval failed: ${userDataResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('------------------Error : $e ');
      rethrow;
    }

    return res;
  }
}
