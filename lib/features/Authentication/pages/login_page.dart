import 'package:ease_scan/features/features.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../../../screens/screens.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  static navigate(context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(-1.0, 0.0);
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

  String email = '';
  String password = '';
  late AuthenticationProvider authenticationProvider;
  late TextEditingController emailTextFieldController;
  late TextEditingController passwordTextFieldController;

  @override
  Widget build(BuildContext context) {
    authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    emailTextFieldController = TextEditingController();
    passwordTextFieldController = TextEditingController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 30,
                ),
                _header(context),
                const SizedBox(
                  height: 40,
                ),
                _inputField(context),
                _forgotPassword(context),
                _signup(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome to Ease Scan",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Text field
        TextField(
          controller: emailTextFieldController,
          cursorColor: Colors.black54,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            prefixIcon: const Icon(Icons.person),
          ),
          onChanged: (value) {
            email = value;
          },
        ),
        const SizedBox(height: 10),
        // Password TextField
        TextField(
          cursorColor: Colors.black54,
          controller: passwordTextFieldController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
          onChanged: (value) {
            password = value;
          },
        ),
        const SizedBox(height: 10),
        // Login with email and password button
        Builder(
          builder: (BuildContext innerContext) {
            return ElevatedButton(
              onPressed: () {
                email = emailTextFieldController.text;
                password = passwordTextFieldController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  authenticationProvider
                      .signInWithEmailPassword(email, password)
                      .then((value) {
                    // Check if user email is authenticated
                    authenticationProvider.isUserVerified()
                        ? HomeScreen.navigate(context)
                        : EmailVerificationScreen.navigate(context);
                  }).catchError((error) {
                    String errorMessage;
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
                          errorMessage = "Wrong email/password combination.";
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
                          errorMessage = "Login failed. Please try again.";
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
                      content: Text('Please enter your email and password.'),
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
                "Login",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        // Sign In with Google Button
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
          child: TextButton(
            onPressed: () {
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
                      image:
                          AssetImage('assets/images/authentication/google.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 18),
                const Text(
                  "Sign In with Google",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Function to handle forgot password
  _forgotPassword(context) {
    return Builder(
      builder: (BuildContext innerContext) {
        void resetPassword() {
          final email = emailTextFieldController.text;

          if (email.isNotEmpty) {
            authenticationProvider.resetPassword(email).then((_) {
              ScaffoldMessenger.of(innerContext).showSnackBar(
                const SnackBar(
                  content: Text('Password reset email sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            }).catchError((error) {
              String errorMessage;
              if (error is FirebaseAuthException) {
                switch (error.code) {
                  case 'invalid-email':
                    errorMessage = 'The email address is badly formatted.';
                    break;
                  case 'user-not-found':
                    errorMessage = 'No user found for that email.';
                    break;
                  default:
                    errorMessage = 'An unexpected error occurred.';
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
                content: Text('Please enter your email.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        return TextButton(
          onPressed: () {
            resetPassword();
          },
          child: const Text(
            "Forgot password?",
            style: TextStyle(color: Colors.blue),
          ),
        );
      },
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            SignupPage.navigate(context);
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.blue),
          ),
        )
      ],
    );
  }
}
