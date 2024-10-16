import 'package:ease_scan/features/features.dart';
import 'package:ease_scan/screens/screens.dart';
import 'package:ease_scan/utilities/file_utilities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../utilities/share_app.dart';
import '../utilities/send_feedback.dart';
import 'pdf_viewer.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static navigate(context) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
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
      (Route<dynamic> route) =>
          false, // This condition removes all previous routes
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTabIndex = 0;
  String appLink =
      "https://play.google.com/store/apps/details?id=com.azarlive.android";
  List<String> pdfFiles = [];
  goToCameraViewPage() async {
    CameraViewPage.navigate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/app_icon.png'),
                    radius: 40,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('ScanEase'),
                ],
              ),
            ),
            // Settings button
            ListTile(
              title: const Text("Settings"),
              leading: const Icon(Icons.settings_rounded),
              onTap: () {
                SettingsScreen.navigate(context);
              },
            ),
            // Feedback
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
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => {
                    SearchScreen.navigate(context, pdfFiles),
                  },
              icon: const Icon(Icons.search_rounded)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      // IndexedStack is used to show the current tab screen
      body: IndexedStack(
        index: currentTabIndex,
        children: [
          buildHomeTab(),
          const FileScreen(),
          const MeScreen(),
        ],
      ),

      // Floating action button to capture image
      floatingActionButton: FloatingActionButton.extended(
        label: const Icon(Icons.camera_alt_rounded),
        onPressed: () {
          goToCameraViewPage();
        },
      ),
      // Bottom navigation bar to switch between tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        // Navigation bar items (Home, Files, Me)
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded), label: "Files"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_3_rounded), label: "Me")
        ],
      ),
    );
  }

  Widget buildHomeTab() {
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<String>>(
              // Fetch All pdf files that has been created
              future: FileUtilities.getAllPDFFiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text("Error");
                } else {
                  pdfFiles = snapshot.data ?? [];
                  return pdfFiles.isEmpty
                      ? const Text("No PDF Files")
                      : Expanded(
                          child: ListView.builder(
                            itemCount: pdfFiles.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to pdf viewer
                                    PdfViewer.navigate(
                                        context, pdfFiles[index]);
                                  },
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                            pdfFiles[index].split('/').last),
                                      ),
                                      const Divider(
                                        height: 0.4,
                                        thickness: 1,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

//screen to be shown in the files tab
class FileScreen extends StatelessWidget {
  const FileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Files"),
      ],
    ));
  }
}

//screen to be shown in the me tab
class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: true);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // show profile picture
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                image: DecorationImage(
                    image: NetworkImage(
                        authenticationProvider.getUser()!.photoURL.toString()),
                    fit: BoxFit.fill)),
          ),
          // show email
          Text(
              "Email: ${authenticationProvider.getUser()?.email ?? "Not SignedIn"}"),

          // show signout button
          ElevatedButton(
            onPressed: () {
              authenticationProvider.signOut().then((value) {
                LoginPage.navigate(context);
              });
            },
            child: const Text("Sign Out"),
          )
        ],
      ),
    );
  }
}
