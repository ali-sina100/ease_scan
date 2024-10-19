import 'package:firebase_auth/firebase_auth.dart';
import 'package:ease_scan/features/features.dart';
import 'package:flutter/material.dart';
import '../screens/me_screen.dart';
import '../screens/home_tab_screen.dart';
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
  User? user = FirebaseAuth.instance.currentUser;
  List<String> pdfFiles = [];
  goToCameraViewPage() async {
    CameraViewPage.navigate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        onTap: (index) => {
          setState(() {
            currentTabIndex = index;
          })
        },
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
        child: const HomeTabScreen(),
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

