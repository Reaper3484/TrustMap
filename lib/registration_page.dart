import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:safety_application/signin_page.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;

  void registerUser() async{
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){

      var regBody = {
        "email":emailController.text,
        "password":passwordController.text
      };

      var response = await http.post(Uri.parse(registration),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(regBody)
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if(jsonResponse['status']){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInPage()));
      }else{
        print("SomeThing Went Wrong");
      }
    }else{
      setState(() {
        _isNotValidate = true;
      });
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // CommonLogo(),
                  HeightBox(10),
                  "Create account".text.size(22).black.make(),
                  HeightBox(15),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: TextStyle(color: Colors.white),
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      hintText: "Email",
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
                        suffixIcon: IconButton(icon: Icon(Icons.copy),onPressed: (){
                          final data = ClipboardData(text: passwordController.text);
                          Clipboard.setData(data);
                        },),
                        prefixIcon: IconButton(icon: Icon(Icons.password),onPressed: (){
                          String passGen =  generatePassword();
                          passwordController.text = passGen;
                          setState(() {

                          });
                        },),
                        contentPadding: EdgeInsets.all(15.0),
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.white),
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        hintText: "Password",
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(color: Color.fromARGB(255, 200, 200, 200), width: 1.0),
                        )
                      ),
                  ).p4().px24(),
                  HStack([
                    GestureDetector(
                      onTap: ()=>{
                        registerUser(),
                      },
                        child: VxBox(child: "Register".text.white.makeCentered().p16()).black.roundedLg.make().px16().py16(),
                    ),
                  ]),
                  HeightBox(20),
                  GestureDetector(
                    onTap: (){
                      print("Sign In");
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInPage()));
                    },
                    child: HStack([
                      "Already Registered? Sign in.".text.make()
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

String generatePassword() {
  String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String lower = 'abcdefghijklmnopqrstuvwxyz';
  String numbers = '1234567890';
  String symbols = '!@#\$%^&*()<>,./';

  String password = '';

  int passLength = 20;

  String seed = upper + lower + numbers + symbols;

  List<String> list = seed.split('').toList();

  Random rand = Random();

  for (int i = 0; i < passLength; i++) {
    int index = rand.nextInt(list.length);
    password += list[index];
  }
  return password;
}