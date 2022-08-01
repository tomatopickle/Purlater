import 'package:flutter/material.dart';

void openSavedItemInfoScreen(
    context, result, Function(String itemId) deleteItem) {
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
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(result["images"][0])),
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
                          child: Text("Close")),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            deleteItem(result["ean"]);
                          },
                          child: Text("Delete"))
                    ],
                  )
                ]));
      });
}
