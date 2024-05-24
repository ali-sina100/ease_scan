import 'package:ease_scan/features/features.dart';
import 'package:ease_scan/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  static navigate(context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTabIndex = 2;

  captureImage() async {
    // Generate filepath for saving
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
    try {
      //TODO
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    String? _email = _authenticationProvider.isUserSignedIn()
        ? _authenticationProvider.getUser()!.email
        : "Not SignedIn";
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
              child: Text('Drawer Header'),
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
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.search_rounded)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      // IndexedStack is used to show the current tab screen
      body: IndexedStack(
        index: currentTabIndex,
        children: const [
          Home(),
          FileScreen(),
          MeScreen(),
        ],
      ),

      // Floating action button to capture image
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("+"),
        onPressed: () {
          captureImage();
        },
      ),
      // Bottom navigation bar to switch between tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
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
}

// Screen to be shown in the home tab
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text("Home"),
      ],
    ));
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
      children: const [
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
    AuthenticationProvider _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: true);
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // show profile picture
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person_rounded),
        ),
        // show email
        Text(
            "Email: ${_authenticationProvider.getUser()?.email ?? "Not SignedIn"}"),

        // show signout button
        ElevatedButton(
          onPressed: () {
            _authenticationProvider.signOut();
          },
          child: const Text("Sign Out"),
        )
      ],
    ));
  }
}
