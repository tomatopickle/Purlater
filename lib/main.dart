import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'pages/BarcodeScanner/BarcodeScanner.dart';
import 'pages/SavedItemInfo/SavedItemInfo.dart';
import 'pages/Camera/Camera.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:expendable_fab/expendable_fab.dart';

final storage = new FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = '0p0LzC6zw1bUYgWf1j3QKMrZtppnXud43w2dThvy';
  const keyClientKey = '2QdUPjXPYX9sfAxDT4lWcS8oggKCpxkD9f7dIiYT';
  const keyParseServerUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Purlater',
        debugShowCheckedModeBanner: false,
        theme: FlexThemeData.light(
          scheme: FlexScheme.aquaBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 20,
          appBarOpacity: 0.95,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            blendOnColors: false,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          // To use the playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.aquaBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          appBarStyle: FlexAppBarStyle.background,
          appBarOpacity: 0.90,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 30,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          // To use the playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        initialRoute: "/",
        routes: {
          // When navigating to the "/" route, build the HomeScreen widget.
          '/': (context) => const HomePage(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/cam': (context) => WebCam()
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var result;
  var savedItems = [];
  @override
  void initState() {
    super.initState();
    storage.read(key: "savedItems").then((value) {
      String? stringSavedItems = value;
      if (stringSavedItems != null) {
        savedItems = json.decode(stringSavedItems.toString());
        print(savedItems);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void addItem(Map item) async {
      print(item);
      setState(() {
        savedItems.add(item);
      });
      await storage.write(key: "savedItems", value: json.encode(savedItems));
    }

    Widget getSavedItems(List items) {
      var listEls = <Widget>[];
      for (var item in items) {
        listEls.add(InkWell(
          onTap: () {
            openSavedItemInfoScreen(context, item, (ean) {
              setState(() {
                savedItems.removeWhere((item) => item["ean"] == ean);
                storage
                    .write(key: "savedItems", value: json.encode(savedItems))
                    .then((value) => {Navigator.of(context).pop()});
              });
            });
          },
          child: ListTile(
            leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Image.network(
                      item["images"][0],
                      width: 50,
                    ))),
            title: Text(
              item["title"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
      }
      if (listEls.isEmpty) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(25),
                child: Text(
                  "No saved items, maybe add one using the button below",
                  textAlign: TextAlign.center,
                )));
      }
      return ListView(children: listEls);
    }

    void _onResult(String barcodeId) async {
      _openLoadingDialog(context);
      final response;
      try {
        response = await http.Client().get(Uri.parse(
            'https://cors-anywhere-tomatopickle.herokuapp.com/https://api.upcitemdb.com/prod/trial/lookup?upc=$barcodeId'));
        if (response.statusCode != 200) {
          showErrorSheet(context);
          print(response.statusCode);
          return;
        }
        //code that has potential to throw an exception
      } catch (e) {
        Navigator.pop(context);
        print(e);
        showErrorSheet(context);
        return;
      }
      String res = response.body;
      Map results = json.decode(res);
      Map result = results["items"][0];
      Navigator.pop(context);
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        result["title"],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Opacity(opacity: 0.65, child: Text(result["category"])),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(result["images"][0]))),
                      const SizedBox(
                        height: 10,
                      ),
                      Opacity(
                          opacity: 0.75,
                          child: Text(result["brand"],
                              style: TextStyle(fontSize: 16))),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(result["description"]),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel")),
                          SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                addItem(result);
                                Navigator.of(context).pop();
                              },
                              child: Text("Save"))
                        ],
                      )
                    ]));
          });
    }

    void openScanner(BuildContext context, Function(String) onResult) {
      showDialog(
        context: context,
        builder: (context) => CamCodeScannerPage(_onResult),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purlater"),
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: getSavedItems(savedItems)),
      floatingActionButton: ExpendableFab(
        distance: 112.0,
        children: [
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              openScanner(context, _onResult);
            },
            tooltip: "Scan Barcode",
            child: const Icon(Icons.document_scanner_rounded),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cam');
            },
            tooltip: "Scan Picture",
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
    );
  }
}

void _openLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          content: Row(children: const [
        CircularProgressIndicator(),
        SizedBox(
          width: 25,
        ),
        Text("Fetching barcode info")
      ]));
    },
  );
}

void showErrorSheet(context) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Unknown Barcode',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"))
                ]));
      });
}
