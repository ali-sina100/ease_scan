import 'package:ease_scan/screens/pdf_viewer.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  List<String> filesList;
  SearchScreen({super.key, required this.filesList});

  // static method for navigation
  static navigate(context, List<String> filesList) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
          filesList: filesList,
        ),
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
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> searchResults = [];
  @override
  void initState() {
    searchResults = widget.filesList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Search Files'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchResults = widget.filesList
                      .where((element) => element
                          .split('/')
                          .last
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          // Search results
          Expanded(
              child: searchResults.isEmpty
                  ? const Text("No results found")
                  : Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to pdf viewer
                                PdfViewer.navigate(
                                    context, searchResults[index]);
                              },
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                        searchResults[index].split('/').last),
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
                    )),
        ],
      ),
    );
  }
}
