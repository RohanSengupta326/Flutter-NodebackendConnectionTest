import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/block/aes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/consts.dart';
import 'package:fast_rsa/fast_rsa.dart';

import 'dart:convert';
import 'package:pointycastle/export.dart';

// Future<String> fetchPublicKeyFromServer() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   // final keyPair = await RSA.generate(2048);
//   // final publicKey = keyPair.publicKey;
//   // debugPrint('---------------------Generated Public key : $publicKey');
//   // debugPrint('---------------------Private key : ${keyPair.privateKey}');
//
//   // await prefs.setString('public_key', publicKey);
//
//   //
//   final publicKey = prefs.getString('publicKey') ?? '';
//   //
//   debugPrint('-------------------Local public key : $publicKey');
//   return publicKey;
// }
//
// Future<dynamic> encryptIdToken(String idToken, String publicKey) async {
//   return await RSA.encryptOAEP(idToken, '', Hash.SHA256, publicKey);
// }

// String formatPublicKeyPem(String base64PublicKey) {
//   return "-----BEGIN PUBLIC KEY-----\n${formatPem(base64PublicKey)}\n-----END PUBLIC KEY-----";
// }
//
// String formatPrivateKeyPem(String base64PrivateKey) {
//   return "-----BEGIN PRIVATE KEY-----\n${formatPem(base64PrivateKey)}\n-----END PRIVATE KEY-----";
// }
//
// String formatPem(String base64String) {
//   // Formats the key by inserting a newline every 64 characters (common PEM format practice)
//   return base64String.replaceAllMapped(
//       RegExp('.{1,64}'), (match) => "${match.group(0)}\n");
// }

// String extractBase64FromPem(String pemKey) {
//   // Split the string into lines, remove lines containing PEM headers and footers, and concatenate.
//   return pemKey
//       .split('\n') // Split the string by new lines to process each line
//       .map((line) => line.trim()) // Trim whitespace from each line
//       .where((line) =>
//           line.isNotEmpty &&
//           !line.startsWith(
//               '-----')) // Filter out empty lines and lines with PEM headers/footers
//       .join(''); // Join the remaining lines back into a single string
// }

//
// String generateKeyPair() {
//   var keyGen = RSAKeyGenerator()
//     ..init(ParametersWithRandom(
//         RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12),
//         SecureRandom("Fortuna")
//           ..seed(
//               KeyParameter(Uint8List.fromList(List.generate(32, (i) => i))))));
//
//   AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();
//   PublicKey publicKey = keyPair.publicKey;
//   PrivateKey privateKey = keyPair.privateKey;
//   debugPrint('-------------------Public Key : $publicKey\n\n');
//   debugPrint('-------------------Private Key : ${keyPair.privateKey}\n\n');
//   // Generated public key.
//
//   // encoding in base64, without header footer.
//   var rsaPublicKey = publicKey as RSAPublicKey;
//   var asn1PublicKey = ASN1Sequence()
//     ..add(ASN1Integer(rsaPublicKey.modulus!))
//     ..add(ASN1Integer(rsaPublicKey.exponent!));
//   var publicKeyDer = asn1PublicKey.encodedBytes;
//   var encoded = base64Encode(publicKeyDer);
//
//
//
//   var rsaPrivateKey = privateKey as RSAPrivateKey;
//   var asn1PrivateKey = ASN1Sequence()
//     ..add(ASN1Integer(rsaPrivateKey.modulus!))
//     ..add(ASN1Integer(rsaPrivateKey.exponent!));
//   var privateKeyDer = asn1PrivateKey.encodedBytes;
//   var encodedPrivate = base64Encode(privateKeyDer);
//
//   var privateKeyPem = formatPrivateKeyPem(encodedPrivate);
//   debugPrint('---------------FormatPEM : $privateKeyPem\n\n');
//
//   debugPrint('-------------------------Encoded Public Key: $encoded\n\n');
//   debugPrint(
//       '-------------------------Encoded Private Key: $encodedPrivate\n\n');
//
//   return encoded;
// }

Uint8List generateSecureRandomBytes(int length) {
  final rng = Random.secure();
  final bytes = List<int>.generate(length, (_) => rng.nextInt(256));
  return Uint8List.fromList(bytes);
}

Map<String, String> encryptDataWithAES(String data, String rsaPublicKey) {
// Generating a random AES key and IV
  final secureRandom = FortunaRandom();
  // FortunaRandom is pointycastle's secure random generator.
  final seedSource = generateSecureRandomBytes(32);
  // generating random bytes.

  secureRandom.seed(KeyParameter(seedSource)); // seeding those random bytes.

  // generating key and iv.
  final key = secureRandom.nextBytes(16);
  final iv = secureRandom.nextBytes(16);
  // converting keys and iv to a format to a supported one by pointycastle
  final keyParam = KeyParameter(key);
  final params = ParametersWithIV(keyParam, iv);

// Encrypting data with AES in CBC mode
//   final cbc = CBCBlockCipher(AESEngine());
  // padding suited for large data sets. PKCS7
  final padding = PaddedBlockCipher("AES/CBC/PKCS7")
    ..init(
        true, PaddedBlockCipherParameters(params, null)); // true for encryption

  final plainData = utf8.encode(data);
  final encryptedData = padding.process(plainData); // AES encryption.
  // Till this much from PaddedBlockCipher this takes care of the padding
  // automatically, abstractly.
  // if we would have used CBCBlockCipher that takes care of padding manually
  // for each block of data
  // and more low level manual process. ( check docs )

  print(
      '-------------------encryptedData AES : ${base64Encode(encryptedData)}\n\n');
  print('-------------------AES iv: ${base64.encode(iv)} ');

  print(
      '-------------------AES iv Non Encoded: ${base64Decode(base64Encode(iv))}');
  print('-------------------AES key: $key');

// Encrypt the AES key using the existing RSA encryption function
  final encryptedKey =
      encryptData(key, rsaPublicKey); // Assuming encryptData() is available

  debugPrint('-------------------encrypted AES key : $encryptedKey');

  return {
    'encryptedData': base64Encode(encryptedData),
    'encryptedKey': encryptedKey,
    'iv': base64Encode(iv),
  };
}

String encryptData(Uint8List dataBytes, String publicKey) {
  String encoded = "";
  try {
    // Decode the public key from Base64
    var publicBytes = base64Decode(publicKey);

    // Parse ASN1 format to extract RSA public key components
    var parser = ASN1Parser(publicBytes);
    var topLevelSeq = parser.nextObject() as ASN1Sequence;

    //
    debugPrint(
        '---------------publicKeyBitString : ${topLevelSeq.elements}\n\n');

    var modulus = topLevelSeq.elements[0] as ASN1Integer;
    var exponent = topLevelSeq.elements[1] as ASN1Integer;

    // Create a cipher instance using RSA with OAEP padding
    // final digest = SHA256Digest();
    // final mgf1 = MaskedGenParameter(digest);
    // final oaepParams = OAEPEncodingParameters(digest, mgf1, null);

    final cipher = OAEPEncoding(
      RSAEngine(),
    )..init(
        true, // true for encryption
        PublicKeyParameter<RSAPublicKey>(
          RSAPublicKey(
            modulus.valueAsBigInteger,
            exponent.valueAsBigInteger,
          ),
        ),
      );

    // Encrypt the data
    var encrypted = cipher.process(dataBytes);

    // Encode the encrypted data into Base64
    encoded = base64Encode(encrypted);
  } catch (e) {
    print('Error during encryption: $e');
  }
  return encoded;
}
