import 'package:camcode/cam_code_scanner.dart';
import 'package:flutter/material.dart';

class EditProductInfoPage extends StatefulWidget {
  final Map item;
  final String title;
  final Function(Map item) onSaved;

  const EditProductInfoPage(this.item, this.title, this.onSaved);

  @override
  _EditProductInfoPageState createState() => _EditProductInfoPageState();
}

class _EditProductInfoPageState extends State<EditProductInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.item);
    Map controllers = {
      'name': TextEditingController(text: widget.item['title']),
      'description':
          TextEditingController(text: widget.item['description'] ?? ''),
      'brand': TextEditingController(text: widget.item['brand'] ?? ''),
      'category': TextEditingController(text: widget.item['category'] ?? ''),
    };

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
          child: Column(
            children: [
              TextField(
                controller: controllers['name'],
                decoration: const InputDecoration(label: Text('Product Name')),
              ),
              SizedBox(height: 15),
              TextField(
                controller: controllers['brand'],
                decoration: const InputDecoration(label: Text('Brand Name')),
              ),
              SizedBox(height: 15),
              TextField(
                controller: controllers['category'],
                decoration: const InputDecoration(label: Text('Category')),
              ),
              SizedBox(height: 15),
              TextField(
                controller: controllers['description'],
                decoration: const InputDecoration(label: Text('Description')),
                maxLines: 2,
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                widget.item["images"].length > 0
                                    ? widget.item["images"][0]
                                    : 'https://media.istockphoto.com/vectors/image-unavailable-icon-vector-id1206575314?k=20&m=1206575314&s=612x612&w=0&h=vHGhGdWirBbzLm-O15AQuZPnazpHZjtt3vtCBDl-T7g=',
                              ))))),
              OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        40), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text("Edit Photo")),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    Map result = {
                      'title': controllers['name'].text,
                      'description': controllers['description'].text,
                      'brand': controllers['brand'].text,
                      'category': controllers['category'].text,
                      'images': widget.item['images'],
                      'ean': widget.item['ean'],
                    };
                    widget.onSaved(result);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        40), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  child: const Text("Save"))
            ],
          ),
        ));
  }
}
