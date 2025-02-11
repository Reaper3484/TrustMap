import 'package:flutter/material.dart';
import 'package:safety_application/google_map.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safety_application/signin_page.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token'),));
}

class MyApp extends StatelessWidget {

  final token;
  const MyApp({
    @required this.token,
    super.key,
});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (token != null && JwtDecoder.isExpired(token) == false )?GoogleMapFlutter(token: token):SignInPage()

      // home: GoogleMapFlutter(), // Directly showing the map
    );
  }
}
