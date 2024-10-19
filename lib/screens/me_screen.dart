import 'package:ease_scan/features/Authentication/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import '../utilities/send_feedback.dart';
import '../utilities/share_app.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../screens/setting_screen.dart';


class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String appLink = "https://play.google.com/store/apps/details?id=com.azarlive.android";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 150,
            decoration:BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/Pbackgroud.png"),
                fit: BoxFit.cover,
                
              ),
               borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    if(user!=null){
                      Navigator.push(
                        context,
                        MaterialPageRoute<ProfileScreen>(
                            builder: (context) => ProfileScreen(
                                  appBar: AppBar(
                                    title: const Text('User Profile'),
                                  ),
                                  actions: [
                                    SignedOutAction((context) {
                                      Navigator.of(context).pop();
                                    })
                                  ],
                              )));
                      }else{
                        LoginPage();
                      }
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/download.png')
                            as ImageProvider,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(user?.displayName ?? "Guest",
                  style:const TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                ),
                const SizedBox(
                  width: 40,
                ),
                ElevatedButton(
                    onPressed: () {
                      if(user!=null){
                      Navigator.push(
                        context,
                        MaterialPageRoute<ProfileScreen>(
                            builder: (context) => ProfileScreen(
                                  appBar: AppBar(
                                    title: const Text('User Profile'),
                                  ),
                                  actions: [
                                    SignedOutAction((context) {
                                      Navigator.of(context).pop();
                                    })
                                  ],
                              )));
                      }else{
                        LoginPage();
                      }
                        
                    },
                    child: Text(user !=null ? "manage" : "Sign In"))
              ],
            ),
          ),
         const SizedBox(height: 10,),
          // ignore: avoid_unnecessary_containers
          Container(
            height: 300,
            decoration:  BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[800], 
            ),
            
            child: Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text("Account"),
                    leading: const Icon(Icons.account_circle),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<ProfileScreen>(
                              builder: (context) => ProfileScreen(
                                    appBar: AppBar(
                                      title: const Text('User Profile '),
                                    ),
                                    actions: [
                                      SignedOutAction((context) {
                                        Navigator.of(context).pop();
                                      })
                                    ],
                                  )));
                    },
                  ),
                  ListTile(
                    title: const Text("Feedback"),
                    leading: const Icon(Icons.feedback_rounded),
                    onTap: () {
                      sendfeedback();
                    },
                  ),
                  ListTile(
                    title: const Text("Invite Friends"),
                    leading: const Icon(Icons.person_add),
                    onTap: () {
                      ShareUtils().shareAppLink(appLink);
                    },
                  ),
                  ListTile(
                    title: const Text("Privacy Policy"),
                    leading: const Icon(Icons.privacy_tip_outlined),
                    onTap: () {
                      launchUrlString(
                          'https://najeebullah04.github.io/ScanEase-Privacy-Policy/Scan_Ease_Privacy_Policy.html');
                    },
                  ),
                  ListTile(
                    title: const Text("Settings"),
                    leading: const Icon(Icons.settings_rounded),
                    onTap: () {
                      SettingsScreen.navigate(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}