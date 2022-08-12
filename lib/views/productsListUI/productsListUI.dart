import 'package:flutter/material.dart';

Widget getSavedItems(
    List items, Function(dynamic item) openSavedItemInfoScreen) {
  var listEls = <Widget>[];
  for (var item in items) {
    listEls.add(InkWell(
      onTap: () {
        openSavedItemInfoScreen(item);
      },
      child: ListTile(
        leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  item["images"].length > 0
                      ? item["images"][0]
                      : 'https://media.istockphoto.com/vectors/image-unavailable-icon-vector-id1206575314?k=20&m=1206575314&s=612x612&w=0&h=vHGhGdWirBbzLm-O15AQuZPnazpHZjtt3vtCBDl-T7g=',
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
