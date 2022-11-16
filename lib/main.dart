import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> cameras;

 Future<void> main() async {

   WidgetsFlutterBinding.ensureInitialized();
   final cameras = await availableCameras();
   final firstCamera = cameras.first;

   runApp(
     MaterialApp(
         theme: ThemeData.dark(),
         home: MyApp()),
   );
 }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /*
      home:Scaffold(
        body: Center(
            child: controller.value.isInitialized ?
            CameraPreview(controller) :
            Container()
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // 写真を撮る
            final imageFile = await controller.takePicture();
            // path を出力
            print(imageFile.path);
          },
          child: const Icon(Icons.camera_alt),
        ),
      )
     */

      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
          title: 'Flutter Demo Home Page'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//(_cameras[0], ResolutionPreset.max);

class _MyHomePageState extends State<MyHomePage> {
  XFile? _image;
  CameraController? _controller;
  final imagePicker = ImagePicker();
  // カメラから写真を取得するメソッド
  Future getPhotoFromCamera() async {
    final path = join(
      // 撮影した画像を一時的に保存する場所を確保。
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    final XFile? pickedFile = await _controller?.takePicture();
    _controller = CameraController(
        cameras[0],
        ResolutionPreset.max);

    if(_controller == null){return;}
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ギャラリーから写真を取得するメソッド
  Future getPhotoFromGarally() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          // 取得した画像を表示(ない場合はメッセージ)
            child: _controller == null
                ? Text(
              '写真を選択してください',
              style: Theme.of(context).textTheme.headline4,
            )
                : Image.file(File(_image!.path))),
        floatingActionButton:
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // カメラから取得するボタン
          FloatingActionButton(
              onPressed: getPhotoFromCamera,
              child: const Icon(Icons.photo_camera)),
          // ギャラリーから取得するボタン
          FloatingActionButton(
              onPressed: getPhotoFromGarally,
              child: const Icon(Icons.photo_album))
        ]));
  }
}