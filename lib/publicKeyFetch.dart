import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/consts.dart';
import 'package:fast_rsa/fast_rsa.dart';

Future<String> fetchPublicKeyFromServer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final keyPair = await RSA.generate(4096);
  final publicKey = keyPair.publicKey;
  debugPrint('---------------------Generated Public key : $publicKey');
  debugPrint('---------------------Private key : ${keyPair.privateKey}');

  // await prefs.setString('public_key', publicKey);


  //
  // final publicKey = prefs.getString('public_key') ?? '';
  //
  // debugPrint('-------------------Local public key : $publicKey');
  return publicKey;
}

Future<dynamic> encryptIdToken(String idToken, String publicKey) async {
  return await RSA.encryptOAEP(idToken, '', Hash.SHA256, publicKey);
}
