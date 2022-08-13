import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:purlater/views/EditProductInfo/EditProductInfo.dart';
import 'package:purlater/views/productInfoUI/productInfoUI.dart';
import 'package:purlater/views/productsListUI/productsListUI.dart';
import 'views/BarcodeScanner/BarcodeScanner.dart';
import 'views/SavedItemInfo/SavedItemInfo.dart';
import 'views/Camera/Camera.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:expendable_fab/expendable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

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
          '/cam': (context) => WebCam(),
          // '/saveCam': (context,byArray) => WebCam(),
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

    void _onResult(String barcodeId) async {
      _openLoadingDialog(context, "Fetching Barcode Info");
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
      Navigator.pop(context);

      if (results["items"].length <= 0) {
        showErrorSheet(context);
        return;
      }
      Map result = results["items"][0];
      debugPrint(result.toString());
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
                      productInfoUI(context, result),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                              icon: Icon(
                                Icons.edit_note_rounded,
                                size: 24.0,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => EditProductInfoPage(
                                      result, 'Edit Product Info', (result) {
                                    addItem(result);
                                    Navigator.pop(context);
                                  }),
                                );
                              },
                              label: Text("Edit")),
                          SizedBox(
                            width: 10,
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
          child: getSavedItems(savedItems, (item) {
            openSavedItemInfoScreen(context, item, (ean) {
              setState(() {
                savedItems.removeWhere((item) => item["ean"] == ean);
                storage
                    .write(key: "savedItems", value: json.encode(savedItems))
                    .then((value) => {Navigator.of(context).pop()});
              });
            }, (item) {
              savedItems.removeWhere((e) => e['ean'] == item['ean']);
              debugPrint(savedItems.toString());
              storage
                  .write(key: "savedItems", value: json.encode(savedItems))
                  .then((value) {
                addItem(item);
                Navigator.of(context).pop();
              });
            });
          })),
      floatingActionButton: ExpendableFab(
        distance: 112.0,
        children: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditProductInfoPage({
                  'title': '',
                  'images': [
                    'https://media.istockphoto.com/vectors/image-unavailable-icon-vector-id1206575314?k=20&m=1206575314&s=612x612&w=0&h=vHGhGdWirBbzLm-O15AQuZPnazpHZjtt3vtCBDl-T7g='
                  ],
                  'description': '',
                  'category': '',
                  'brand': '',
                  'ean': DateTime.now().millisecondsSinceEpoch.toString()
                }, 'Add New Product', (result) {
                  addItem(result);
                  Navigator.pop(context);
                }),
              );
            },
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
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              final XFile? photo =
                  await _picker.pickImage(source: ImageSource.camera);
              _openLoadingDialog(context, "Scanning Image");
              ParseFileBase? parseFile;
              parseFile =
                  ParseWebFile(await photo!.readAsBytes(), name: 'test.jpg');
              await parseFile.save();
              final gallery = ParseObject('Gallery')..set('file', parseFile);
              gallery.save().then((e) async {
                final ParseCloudFunction function = ParseCloudFunction('ocr');
                print(e.result['file']['url']);
                final ParseResponse parseResponse = await function
                    .execute(parameters: {'src': e.result['file']['url']});
                if (parseResponse.success && parseResponse.result != null) {
                  print(parseResponse.result);
                  Navigator.pop(context);
                  Map result = {
                    'title': parseResponse.result,
                    'images': [e.result['file']['url']],
                    'description': '',
                    'category': '',
                    'brand': '',
                    'ean': DateTime.now().millisecondsSinceEpoch.toString()
                  };
                  showDialog(
                    context: context,
                    builder: (context) => EditProductInfoPage(
                        result, 'Save Product Info', (result) {
                      addItem(result);
                      Navigator.pop(context);
                    }),
                  );
                }
              });
            },
            tooltip: "Scan Picture",
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
    );
  }
}

void _openLoadingDialog(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          content: Row(children: [
        const CircularProgressIndicator(),
        const SizedBox(
          width: 25,
        ),
        Text(message)
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
