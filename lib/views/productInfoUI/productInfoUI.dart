import 'package:flutter/material.dart';

Widget productInfoUI(context, result) {
  return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 90,
              child: Text(
                result["title"],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const Spacer(),
            const CloseButton()
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        if (result['category'] != Null)
          Opacity(
              opacity: 0.65,
              child: Text(
                result["category"],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
        const SizedBox(
          height: 10,
        ),
        if (result['images'].length > 0)
          Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(result["images"][0]))),
        const SizedBox(
          height: 10,
        ),
        if (result['brand'] != Null)
          Opacity(
              opacity: 0.75,
              child: Text(result["brand"], style: TextStyle(fontSize: 16))),
        const SizedBox(
          height: 10,
        ),
        if (result['description'] != Null) Text(result["description"]),
        const SizedBox(
          height: 10,
        ),
      ]);
}
