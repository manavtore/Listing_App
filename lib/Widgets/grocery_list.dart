// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:challenges/Widgets/new_item.dart';
import 'package:challenges/data/data.dart';
import 'package:challenges/models/grocery_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/dummy_items.dart';

class Grocerylist extends StatefulWidget {
  const Grocerylist({super.key});

  @override
  State<Grocerylist> get createState => _GrocerylistState();
}

class _GrocerylistState extends State<Grocerylist> {
  List<GroceryItem> _groceryItems = [];
  var isloading = true;

  @override
  void initState() {
    super.initState();
    Loaditem();
  }

  void Loaditem() async {
    final url = Uri.https(
        'flutterprep-ebc4e-default-rtdb.firebaseio.com', 'Shopping-list.json');
    final response = await http.get(url);

    final Map<String, dynamic> Listdata = json.decode(response.body);

    final List<GroceryItem> Loadeditems = [];

    for (final item in Listdata.entries) {
      final category = categories.entries
          .firstWhere(
              (CatItem) => CatItem.value.title == item.value['category'])
          .value;
      Loadeditems.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category),
      );
      setState(() {
        isloading = false;
        _groceryItems = Loadeditems;
      });
    }
  }

  void _addItem() async {
    final NewItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const new_item()));

    if (NewItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(NewItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Groceries found'),
    );
    if (isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          {
            return Dismissible(
              onDismissed: (direction) {
                // removeItem(_groceryItems[index]);
              },
              key: ValueKey(_groceryItems[index].id),
              child: ListTile(
                title: Text(_groceryItems[index].name),
                leading: Container(
                  width: 50,
                  height: 50,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(groceryItems[index].quantity.toString()),
              ),
            );
          }
        },
      );
    } else {
      content;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Your Groceries',
        ),
        actions: [
          IconButton.filled(
            color: Colors.black,
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }
}
