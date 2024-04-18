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
    setPublicKey();
  }

  void setPublicKey() async{
    publicKey = await fetchPublicKeyFromServer();
    SharedPreferences prefs = await  SharedPreferences.getInstance();
    prefs.setString('publicKey', publicKey);
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
              userData = await googleAuthApi.signUp();

              //
              setState(() {
                userData.name != 'name' ? isLoaded = true : isLoaded = false;
              });
            },
            style: ButtonStyle(
              elevation: const MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              backgroundColor: MaterialStatePropertyAll(Colors.white),
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
