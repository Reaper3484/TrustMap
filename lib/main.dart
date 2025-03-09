import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safety_application/google_map.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:safety_application/services/notification_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safety_application/new_signin_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
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

      // home: GoogleMapFlutter(token: 'token'), // Directly showing the map
    );
  }
}
