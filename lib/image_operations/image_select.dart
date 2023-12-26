
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImageSelectionWidget extends StatefulWidget {
  //重要
  final Function(PlatformFile) onImageSelected; // PlatformFile型に変更

  const ImageSelectionWidget({
    Key? key,
    required this.onImageSelected
  }):super(key: key);

  @override
  _ImageSelectionWidgetState createState() => _ImageSelectionWidgetState();
}

class _ImageSelectionWidgetState extends State<ImageSelectionWidget> {
  String? selectedImagePath;

  Future<void> selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true, //androidではデフォルトでfalseになるらしいが、trueにしないとbytesがnullになる
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.count > 0) {
      final file = result.files[0];
      setState(() {
        selectedImagePath = file.name; // Webではファイルパスではなくファイル名を表示
      });
      widget.onImageSelected(file); // PlatformFile型に変更
      print(selectedImagePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImagePath != null)
          Text(
            selectedImagePath!,
            style: TextStyle(fontSize: 16),
          ),
        ElevatedButton(
          onPressed: selectImage,
          child: Text("画像を選択してくださいね"),
        ),
      ],
    );
  }
} 