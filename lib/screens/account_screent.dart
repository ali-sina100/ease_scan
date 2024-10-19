import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return  Scaffold(
      appBar: AppBar(
        title:const Text("Account"),
      ),
      body: Column(
        children: [
          Center(
        child:  CircleAvatar(
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : const AssetImage(
                        'assets/images/app_icon.png') // Fallback image
                    as ImageProvider,
             ),
          ),
          Text(user?.displayName ?? "Guest",
           style:const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold, 
            fontStyle: FontStyle.italic, // Italicize the text (optional)
            ),),
           const SizedBox(height: 10,),
          Text(user?.email ?? "",
          style: const TextStyle(
            
          ),),
          ElevatedButton(
            onPressed: (){
              if(user!=null){
                const SignInScreen();
              }
          }, 
          child: Text(user!=null ? "Sign Out":"Sign In"),),
        ],
      )
    );
  }
}