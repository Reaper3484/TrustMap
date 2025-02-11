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
  final bool _isNotValidate = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async{
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async{
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){

      var reqBody = {
        "email":emailController.text,
        "password":passwordController.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(reqBody)
      );

      var jsonResponse = jsonDecode(response.body);
      print("Login API Response: $jsonResponse"); // Debugging

      if(jsonResponse['status']){
          var myToken = jsonResponse['token'];
          print("Token received: $myToken"); // Debugging
          prefs.setString('token', myToken);//in token key our token is saved
          Navigator.push(context, MaterialPageRoute(builder: (context)=>GoogleMapFlutter(token: myToken)));
      }else{
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
                colors: [const Color.fromARGB(255, 255, 255, 255),const Color.fromARGB(255, 255, 255, 255)],
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomCenter,
                stops: [0.0,0.8],
                tileMode: TileMode.mirror
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // CommonLogo(),
                  HeightBox(10),
                  "Sign in".text.size(22).black.make(),
                  HeightBox(15),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Email",
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Color.fromARGB(255, 200, 200, 200), width: 1.0),
                      ),
                    ),
                  ).p4().px24(),
                  HeightBox(10),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Password",
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Color.fromARGB(255, 200, 200, 200), width: 1.0),
                      ),
                    ),
                  ).p4().px24(),
                  HeightBox(15),
                  GestureDetector(
                    onTap: (){
                        loginUser();
                    },
                    child: HStack([
                      VxBox(child: "Login".text.white.makeCentered().p16()).black.roundedLg.make(),
                    ]),
                  ),
                  HeightBox(25),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Registration()));
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