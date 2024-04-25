import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/google_auth_api.dart';
import 'package:test/publicKeyFetch.dart';

import 'logged_in_page.dart';
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleAuthApi googleAuthApi = GoogleAuthApi();
  bool isLoaded = false;

  UserModel userData = UserModel.empty();
  String publicKey = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setPublicKey();
  }

  void setPublicKey() async {
    // String publicKey = generateKeyPair();
    String publicKey =
        "MIIBCgKCAQEA4kB4sTqHMSI7BmfYe1e4ag7gwEpIxxAFi/w6lxFSdxwV90iKkay8Pe6jlv6Z9ziTqfMm3uvF8gF2ytAQn5JPQ9eUGlbdYaaKudy4p7nHdIcEcoARLA16zWyBNXiK3xYonVAW/zJNGA6i6F1Y1+QiUbklpoHVbhIYFs3t/uEqDyfw2W/S4tS5Zekhdw3MYHyJHd+Bf8cdfmcPl5Wj/S4kXbX7NyaRYvMURcYTnH4IiLIHr22dLjfXDrDD0Eptv5+cbdA20YVmsH9bkm0RjLkPtfpwyaoxAfGq1ajNd1BE53IAMv+WZ7ZECEcjUKjKxapPqh0eRdRfUOtLiewv3fkgpQIDAQAB";
    // String pemPublicKey = extractBase64FromPem(publicKey);
    // debugPrint('----------------pemPublicKey : $pemPublicKey\n\n');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pemPublicKey', publicKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: isLoaded ? signedUp() : signUpPage());
  }

  Widget signedUp() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Signed Up Successfully ',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(25)),
            height: 45,
            width: 500,
            child: ElevatedButton(
              onPressed: () async {
                userData = await googleAuthApi.getUserData();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => LoggedInPage(
                      userData: userData,
                    ),
                  ),
                );
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
                'Get User Data',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signUpPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sign Up with Google ',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(25)),
          height: 45,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              // function to call google signup
              final statusCode = await googleAuthApi.signUp();

              if (statusCode == 200) {
                setState(() {
                  isLoaded = true;
                });
              } else {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Something Went Wrong!',
                    ),
                    duration: Duration(seconds: 5),
                  ),
                );
              }

              //
              // setState(() {
              //   userData.name != 'name' ? isLoaded = true : isLoaded = false;
              // });
            },
            style: ButtonStyle(
              elevation: const MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              backgroundColor: const MaterialStatePropertyAll(Colors.white),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Image.asset(
                        'assets/images/google_sign_in.png',
                        height: 18,
                        width: 18,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: 'Sign Up with Google',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
