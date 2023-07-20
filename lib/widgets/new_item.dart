import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/category.dart';
import 'package:shopping_app/models/category_model.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_app/models/grocerry_model.dart';

class NewItem extends StatefulWidget {
  const NewItem({
    super.key,
  });

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _name = " ";
  var _quantity = 1;
  var _selectedCategory = categories[Categories.fruit];
  bool _isSending = true;
  void saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      setState(() {
        _isSending = false;
      });
      final url = Uri.https('shopping-list-5e21f-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: json.encode({
            'name': _name,
            'quantity': _quantity,
            'category': _selectedCategory!.title
          }));
      final resid = json.decode(response.body);

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resid.toString(),
          name: _name,
          quantity: _quantity,
          category: _selectedCategory!));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                  prefixIcon: Icon(Icons.person),
                ),
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please fill correctly";
                  } else {
                    return null;
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLength: 5,
                      decoration:
                          const InputDecoration(label: Text("Quantity")),
                      initialValue: _quantity.toString(),
                      validator: (value) {
                        if (int.tryParse(value!) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Please fill correctly";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _quantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButton(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: category.value.colors,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(category.value.title)
                              ]),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(onPressed: () {}, child: const Text("Back")),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(onPressed: saveItem, child: const Text("Add"))
              ])
            ],
          )),
    );

    if (_isSending == false) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text("Add New Item"),
        ),
        body: content);
  }
}
