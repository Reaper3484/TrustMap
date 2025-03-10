import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:safety_application/google_map.dart';
import 'package:safety_application/registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController authKeyController = TextEditingController();
  late SharedPreferences prefs;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      if (isAdmin && authKeyController.text.isEmpty) {
        print('Admin authentication key is required');
        return;
      }

      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text,
        if (isAdmin) "role": "admin" else "role": "user",
        if (isAdmin) "secretKey": authKeyController.text,
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonResponse = jsonDecode(response.body);
      print("Login API Response: $jsonResponse");

      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        prefs.setBool('isAdmin', isAdmin);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => GoogleMapFlutter(token: myToken, isAdmin: isAdmin)));
      } else {
        print('Something went wrong: ${jsonResponse['message']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomCenter,
                stops: [0.0, 0.8],
                tileMode: TileMode.mirror),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  HeightBox(10),
                  "Sign in".text.size(22).black.make(),
                  HeightBox(15),

                  // Radio buttons for user type selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: false,
                        groupValue: isAdmin,
                        onChanged: (value) {
                          setState(() => isAdmin = false);
                        },
                      ),
                      "User".text.make(),
                      Radio(
                        value: true,
                        groupValue: isAdmin,
                        onChanged: (value) {
                          setState(() => isAdmin = true);
                        },
                      ),
                      "Admin".text.make(),
                    ],
                  ),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Email",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ).p4().px24(),
                  HeightBox(10),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ).p4().px24(),

                  if (isAdmin) ...[
                    HeightBox(10),
                    TextField(
                      controller: authKeyController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15.0),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Authentication Key",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ).p4().px24(),
                  ],

                  HeightBox(15),
                  GestureDetector(
                    onTap: loginUser,
                    child: HStack([
                      VxBox(child: "Login".text.white.makeCentered().p16())
                          .black
                          .roundedLg
                          .make(),
                    ]),
                  ),
                  HeightBox(25),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Registration()));
                    },
                    child: HStack([
                      "Don't have an account? Sign up.".text.make()
                    ]).centered(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
