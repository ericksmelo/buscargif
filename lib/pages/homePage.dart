import 'package:buscadorgif/pages/gifPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _getGifs().then((map) {
      print(map);
    });

    //_initGoogleMobileAds();

    // BannerAd(
    //   adUnitId: AdHelper.bannerAdUnitId,
    //   request: AdRequest(),
    //   size: AdSize.banner,
    //   listener: BannerAdListener(
    //     onAdLoaded: (ad) {
    //       setState(() {
    //         _bannerAd = ad as BannerAd;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, err) {
    //       print('Failed to load a banner ad: ${err.message}');
    //       ad.dispose();
    //     },
    //   ),
    // ).load();

    super.initState();
  }

  BannerAd? _bannerAd;

  String _search = "";
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search.isEmpty) {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=1DQy0XzwD9EYjPR56VyWY8jHFShtEi9L&limit=20&rating=g'));
      print('trend');
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=1DQy0XzwD9EYjPR56VyWY8jHFShtEi9L&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt-Br'));
      print('pesquisa');
    }
    return json.decode(response.body);
  }

  int _getCount(List data) {
    if (_search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  // _onShare method:

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                }),
          ),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (BuildContext context, int index) {
        if (_search.isEmpty || index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => GifPage(
                        gifData: snapshot.data["data"][index],
                      )),
                ),
              );
            },
            onLongPress: () async {
              await Share.share(snapshot.data["data"][index]["images"]
                  ["fixed_height"]["url"]);
            },
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                fit: BoxFit.cover,
                height: 300.0,
                image: snapshot.data["data"][index]["images"]["fixed_height"]
                    ["url"]),
          );
        } else {
          return GestureDetector(
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white,
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 90.0,
                  ),
                  Text(
                    'Carregar...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();

    super.dispose();
  }

  //Inicializando o Adbmob
  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }
}
