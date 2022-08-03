import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'pages/BarcodeScanner/BarcodeScanner.dart';
import 'pages/SavedItemInfo/SavedItemInfo.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
          // '/scan': (context) => BarcodeScannerPage()
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
  /* var savedItems = <Map>[
    {
      "ean": "0190199503977",
      "title":
          "Apple iPhone SE 2020 2nd Gen 64/128/256GB Unlocked Very Good Condition",
      "description":
          "Apple A13 Bionic Hexa-Core 12.0 MP Rear Camera 7 MP Front-Facing Camera 3GB RAM 64GB 4.7' Retina IPS LCD 1334 x 750 326 ppi Non-removable Li-Ion Battery 1821mAh iOS 13",
      "upc": "190199503977",
      "brand": "Apple",
      "model": "MX9T2",
      "color": "",
      "size": "",
      "dimension": "",
      "weight": "",
      "category": "Electronics > Communications > Telephony > Mobile Phones",
      "currency": "CAD",
      "lowest_recorded_price": 299,
      "highest_recorded_price": 1145.25,
      "images": [
        "https://c1.neweggimages.com/NeweggImage/productimage/75-113-609-V01.jpg",
        "https://www.techinthebasket.com/media/catalog/product/t/e/techinthebasket_apple_iphone_se_2020_64gb_white-1_2.jpg"
      ],
      "offers": [
        {
          "merchant": "Newegg Canada",
          "domain": "Newegg Canada",
          "title":
              "Apple iPhone SE A2296 4G LTE Cell Phone 4.7' White 64GB 3GB RAM",
          "currency": "CAD",
          "list_price": "",
          "price": 1135.59,
          "shipping": "34.00",
          "condition": "New",
          "availability": "",
          "link":
              "https://www.upcitemdb.com/norob/alink/?id=y2x253233303e464u2&tid=1&seq=1659161582&plt=22ae442…",
          "updated_t": 1602774891
        },
        {
          "merchant": "TechInTheBasket UK",
          "domain": "TechInTheBasket UK",
          "title": "Apple iPhone SE 2020 Dual SIM 64GB - White",
          "currency": "GBP",
          "list_price": "",
          "price": 335.99,
          "shipping": "",
          "condition": "New",
          "availability": "",
          "link":
              "https://www.upcitemdb.com/norob/alink/?id=y2x243u2v2z2b464q2&tid=1&seq=1659161582&plt=63c173c…",
          "updated_t": 1635118668
        }
      ],
      "elid": "384351125268"
    }
  ];
*/
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
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  item["images"][0],
                  width: 50,
                )),
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
      String res;
      try {
        res = await http.read(Uri.parse(
            'https://cors-anywhere-tomatopickle.herokuapp.com/https://api.upcitemdb.com/prod/trial/lookup?upc=$barcodeId'));
        //code that has potential to throw an exception
      } catch (e) {
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
                        const Text(
                          'Unknown Barcode',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
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
        return;
      }
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
      body: Container(child: getSavedItems(savedItems)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint("scanning");
          openScanner(context, _onResult);
        },
        tooltip: 'Save Item',
        // child: const Icon(Icons.add),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void _openLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          content: Row(children: [
        CircularProgressIndicator(),
        SizedBox(
          width: 25,
        ),
        Text("Fetching barcode info")
      ]));
    },
  );
}
