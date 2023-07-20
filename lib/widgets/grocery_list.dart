import 'package:flutter/material.dart';
import 'package:shopping_app/data/category.dart';
import 'package:shopping_app/models/grocerry_model.dart';
import 'package:shopping_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

List<GroceryItem> groceryItems = [];
bool _isLoading = true;

class _GroceryListState extends State<GroceryList> {
  @override
  void initState() {
    loadItem();
    super.initState();
  }

  void loadItem() async {
    final url = Uri.https('shopping-list-5e21f-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      final Map<String, dynamic> listdata = json.decode(response.body);
      List<GroceryItem> localList = [];
      for (final item in listdata.entries) {
        final category = categories.entries.firstWhere(
            (catItem) => catItem.value.title == item.value['category']);
        localList.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value));
      }
      setState(() {
        groceryItems = localList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void removeItem(GroceryItem grocery) {
      final url = Uri.https('shopping-list-5e21f-default-rtdb.firebaseio.com',
          'shopping-list/${grocery.id}.json');
      http.delete(url);
      setState(() {
        groceryItems.remove(grocery);
        Navigator.of(context).pop();
      });
    }

    Widget content = const Center(
      child: Text(
        "Nothing To Show",
        style: TextStyle(fontSize: 25),
      ),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: groceryItems.length,
          itemBuilder: (context, index) {
            return InkWell(
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        content: const Text(
                          "Delete Item",
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                removeItem(groceryItems[index]);
                              },
                              child: const Text("Delete"))
                        ],
                      );
                    });
              },
              child: ListTile(
                title: Text(groceryItems[index].name),
                leading: Container(
                  height: 24,
                  width: 24,
                  color: groceryItems[index].category.colors,
                ),
                trailing: Text("${groceryItems[index].quantity}"),
              ),
            );
          });
    }

    void addNewItem() async {
      final x = await Navigator.push<GroceryItem>(context,
          MaterialPageRoute(builder: (context) {
        return const NewItem();
      }));

      setState(() {
        if (x == null) {
          return;
        } else {
          groceryItems.add(x);
        }
      });
    }

    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: const Text("Your Groceries"),
            actions: [
              IconButton(onPressed: addNewItem, icon: const Icon(Icons.add))
            ]),
        body: content);
  }
}
