import 'package:flutter/material.dart';
import '../utilities/file_utilities.dart';
import 'pdf_viewer.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
     List<String> pdfFiles = [];
    return  Column(
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
        );
  }
}