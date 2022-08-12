import 'package:flutter/material.dart';
import '../productInfoUI/productInfoUI.dart';
import '../EditProductInfo/EditProductInfo.dart';

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
                  productInfoUI(context, result),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                          icon: const Icon(
                            Icons.edit_note_rounded,
                            size: 24.0,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditProductInfoPage(
                                  result, "Save Item", (item) {}),
                            );
                          },
                          label: const Text("Edit")),
                      const SizedBox(
                        width: 10,
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
