import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utilities/file_utilities.dart';
import '../features/auto_crop_scan/pages/edit_page.dart';
import 'home_tab_screen.dart';
class FileScreen extends StatelessWidget {
  const FileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        Row(
          children: [
        
           TextButton.icon(
             onPressed: () async {
                // Pick a file from the gallery
                final pickedFile = await ImagePicker()
                    .pickImage(source: ImageSource.gallery);
                // Check if the file is not null
                if (pickedFile != null) {
                  // Save file to /temp directory
                  String path =
                      await FileUtilities.saveTempFile(pickedFile);
                  // Navigate to EditPage
                  EditPage.navigate(context, path);
                }
               }, 
            icon:const Padding(
              padding:  EdgeInsets.all(8.0),
              child:  Icon( Icons.image_rounded , color: Colors.purple, size: 40,),
            ),
            label: const Text("Import Image"),
            
            ),
            TextButton.icon(
            onPressed: () async {
                // Pick a file from the gallery
                final pickedFile = await ImagePicker()
                    .pickImage(source: ImageSource.gallery);
                // Check if the file is not null
                if (pickedFile != null) {
                  // Save file to /temp directory
                  String path =
                      await FileUtilities.saveTempFile(pickedFile);
                  // Navigate to EditPage
                  EditPage.navigate(context, path);
                }
               },
            icon: const Icon( Icons.file_open , color: Colors.purple, size: 40,),
            label: const Text("Import File")),
          ],
         ),
        const  SizedBox(height: 50,),
       const Expanded(
        child:HomeTabScreen(),

    )
      ],
    ),
     
    );
  }
}