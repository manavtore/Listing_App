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
  String? error;
  late Future<List<GroceryItem>> _LoadedItems;

  @override
  @override
  void initState() {
    super.initState();
    _LoadedItems = Loaditem();
  }

  Future<List<GroceryItem>> Loaditem() async {
    final url = Uri.https(
        'flutterprep-ebc4e-default-rtdb.firebaseio.com', 'Shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Error loading items');
    }

    if (response.body == 'null') {
      return [];
    }
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
    }
    return Loadeditems;
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

    // void removeItem(GroceryItem item) async {
    //   final url = Uri.https('flutterprep-ebc4e-default-rtdb.firebaseio.com',
    //       'Shopping-list/${item.id}.json');

    //   http.delete(url);
    //   setState(() {
    //     _groceryItems.remove(item);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        future: _LoadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No Groceries found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              {
                return Dismissible(
                  onDismissed: (direction) {
                    removeItem(snapshot.data![index]);
                  },
                  key: ValueKey(snapshot.data![index].id),
                  child: ListTile(
                    title: Text(snapshot.data![index].name),
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: snapshot.data![index].category.color,
                    ),
                    trailing: Text(snapshot.data![index].quantity.toString()),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  void removeItem(GroceryItem item) async {
    final index = groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutterprep-ebc4e-default-rtdb.firebaseio.com',
        'Shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }
}
