import 'dart:async';

import 'package:ease_scan/features/Authentication/pages/login_page.dart';
import 'package:ease_scan/features/Authentication/provider/authetication_provider.dart';
import 'package:ease_scan/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  static navigate(context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EmailVerificationScreen(),
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
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late Timer _timer;
  late Timer _resendEmailTimer;
  late AuthenticationProvider authProvider;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        authProvider.getUser()!.reload().then(
          (value) {
            if (authProvider.getUser()!.emailVerified) {
              HomeScreen.navigate(context);
            }
          },
        );
      },
    );

    startResendEmailTimer();
  }

  // Function to start the Resend Email timer
  void startResendEmailTimer() {
    _resendEmailTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        canResendEmail = true;
        _resendEmailTimer.cancel();
      });
    });
  }

  @override
  void dispose() {
    // dispose the timer after job finished
    _timer.cancel();
    _resendEmailTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthenticationProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Email Icon
              Lottie.asset("assets/animations/lotties/email_animation.json",
                  repeat: false),
              const SizedBox(
                height: 20,
              ),
              // Check your email text
              const Text(
                "Check you email",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 10,
              ),

              // Text field
              const Text(
                "We have sent a verification link to",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 5,
              ),
              // Email
              Text(
                authProvider.isUserSignedIn()
                    ? authProvider.getUser()?.email ?? "No Email"
                    : "Not signed In",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // Continue button
              InkWell(
                onTap: () async {
                  await authProvider.getUser()!.reload().then(
                    (value) {
                      if (authProvider.getUser()!.emailVerified) {
                        HomeScreen.navigate(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please verify your email'),
                            duration: Duration(
                                seconds:
                                    2), // Duration for how long the toast should be visible
                          ),
                        );
                      }
                    },
                  );
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.sizeOf(context).width - 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't recieve the email?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 8, 72, 174),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (canResendEmail) {
                        authProvider.sendVerificationEmail();
                        startResendEmailTimer();
                        setState(() {
                          canResendEmail = false;
                        });
                      }
                    },
                    child: Text(
                      "Click to resend",
                      style: TextStyle(
                        color: canResendEmail
                            ? const Color.fromARGB(255, 8, 72, 174)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              // Back to login Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 8, 72, 174),
                  ),
                  TextButton(
                    onPressed: () {
                      LoginPage.navigate(context);
                    },
                    child: const Text(
                      "back to log in",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 8, 72, 174),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
