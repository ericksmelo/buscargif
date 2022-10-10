import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GifPage extends StatefulWidget {
  final Map gifData;
  const GifPage({Key? key, required this.gifData}) : super(key: key);

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {
  @override
  void initState() {
    super.initState();

    //Pede Permissao para salvar na Galeria
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(widget.gifData["title"]),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveGif,
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.gifData["images"]["fixed_height"]["url"],
              fit: BoxFit.fitWidth,
            ),
          ],
        ));
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  _saveGif() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.mp4";
    String fileUrl = widget.gifData["images"]["fixed_height"]["mp4"];
    await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      String downloadingPercert =
          ((count / total * 100).toStringAsFixed(0) + "%");
      _toastInfo(downloadingPercert);
    });
    final result = await ImageGallerySaver.saveFile(savePath);
    print(result);
    _toastInfo("Salvo na Galeria!");
    // ignore: deprecated_member_use
    Share.shareFiles([savePath], subject: widget.gifData["title"]);
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(
        msg: info,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 24.0);
  }
}
