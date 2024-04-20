import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/homepage.dart';
import 'splash_screen.dart';

 late User user;

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  SplashScreen.splashscreen: ((context) => SplashScreen()),
  GriveanceHomepage.grivencehomepage: ((context) => GriveanceHomepage(
    user: user,
  )),
};
