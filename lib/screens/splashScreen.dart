import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './index.dart';
import './loginScreen.dart';
import '../providers/authProvider.dart';
import '../services/authenticationServices.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthProvider _authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder(
      future: AuthenticationServices()
          .loginExistingUser(authProvider: _authProvider),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data ? Index() : LoginScreen();
        } else {
          return Scaffold(
            body: Center(
              child: Image.asset(
                'assets/images/img_envirocar_logo.png',
                scale: 5,
              ),
            ),
          );
        }
      },
    );
  }
}
