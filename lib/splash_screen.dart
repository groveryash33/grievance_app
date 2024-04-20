import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'constants/custom_color.dart';
import 'firebase_storage/firebase_auth.dart';
import 'screens/homepage.dart';

class SplashScreen extends StatefulWidget {
  static const String splashscreen = "splashscreen";

  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  late User _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(
                  left: 46.0,
                  right: 46.0,
                  bottom: 20.0,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome to Grievance App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.whiteColor, fontSize: 20.0),
                      ),
                      const SizedBox(
                        height: 35.0,
                      ),
                      Text(
                        'Your Feedback, Our Action!!',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                            height: 1.5,
                            color: AppColors.whiteColor,
                            fontSize: 20.0),
                      ),
                      const SizedBox(
                        height: 55.0,
                      ),
                      FutureBuilder(
                        future:
                            Authentication.initializeFirebase(context: context),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error initializing Firebase');
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return const GoogleSignInButton();
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.whiteColor,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 55.0,
                      ),
                    ]))));
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: _isSigningIn
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
              ),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(AppColors.whiteColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                User? user =
                    await Authentication.signInWithGoogle(context: context);

                if (user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => GriveanceHomepage(
                              user: user,
                            )),
                  );
                }

                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Image(
                      image: AssetImage("assets/images/google_logo.png"),
                      height: 35.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
