import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../screens/screens.dart';
import '../provider/authetication_provider.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  static navigate(context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutQuart;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String _email = '';

  String _password = '';

  bool signupProcess = false;

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Create your account",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  // User name
                  TextField(
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      hintText: "Username",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.blue.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email
                  TextField(
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.blue.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.email)),
                    onChanged: (value) => _email = value,
                  ),
                  const SizedBox(height: 20),
                  // Password
                  TextField(
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.blue.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  // Confirm password
                  TextField(
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.blue.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                    onChanged: (value) => _password = value,
                  ),
                ],
              ),
              // Signup button
              // Login with email and password button
              Builder(
                builder: (BuildContext innerContext) {
                  return ElevatedButton(
                    onPressed: () {
                      if (_email.isNotEmpty && _password.isNotEmpty) {
                        String errorMessage;
                        // update the process indicator
                        setState(() {
                          signupProcess = true;
                        });
                        // Call the register method
                        authenticationProvider
                            .registerWithEmailPassword(_email, _password)
                            .then((value) {
                          setState(() {
                            signupProcess = false;
                          });

                          errorMessage = "Your account registered please login";
                          ScaffoldMessenger.of(innerContext).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // After successfully account registered, then wait two seconds and then navigate to login
                          Timer.periodic(
                            const Duration(seconds: 2),
                            (timer) {
                              LoginPage.navigate(context);
                            },
                          );
                        }).catchError((error) {
                          setState(() {
                            signupProcess = false;
                          });
                          if (error is FirebaseAuthException) {
                            switch (error.code) {
                              case "ERROR_EMAIL_ALREADY_IN_USE":
                              case "account-exists-with-different-credential":
                              case "email-already-in-use":
                                errorMessage =
                                    "Email already used. Go to login page.";
                                break;
                              case "ERROR_WRONG_PASSWORD":
                              case "wrong-password":
                              case "invalid-credential":
                                errorMessage =
                                    "Wrong email/password combination.";
                                break;
                              case "ERROR_USER_NOT_FOUND":
                              case "user-not-found":
                                errorMessage = "No user found with this email.";
                                break;
                              case "ERROR_USER_DISABLED":
                              case "user-disabled":
                                errorMessage = "User disabled.";
                                break;
                              case "ERROR_TOO_MANY_REQUESTS":
                              case "operation-not-allowed":
                                errorMessage =
                                    "Too many requests to log into this account.";
                                break;
                              case "ERROR_OPERATION_NOT_ALLOWED":
                              case "operation-not-allowed":
                                errorMessage =
                                    "Server error, please try again later.";
                                break;
                              case "ERROR_INVALID_EMAIL":
                              case "invalid-email":
                                errorMessage = "Email address is invalid.";
                                break;
                              default:
                                errorMessage =
                                    "Login failed. Please try again.";
                                break;
                            }
                          } else {
                            errorMessage = 'An unexpected error occurred.';
                          }
                          ScaffoldMessenger.of(innerContext).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(innerContext).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill the form'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Sign up with google container
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                // With google
                child: TextButton(
                  // When the sign in with google button pressed
                  onPressed: () {
                    // If Sign in was a success then navigate to home screen
                    authenticationProvider.signInWithGoogle().then((value) {
                      if (value != null) {
                        HomeScreen.navigate(context);
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 30.0,
                        width: 30.0,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/authentication/google.png'),
                              fit: BoxFit.cover),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Text(
                        "Sign up with Google",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        LoginPage.navigate(context);
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.blue),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
