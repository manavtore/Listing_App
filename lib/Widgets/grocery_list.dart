import 'package:challenges/Widgets/new_item.dart';
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
  final List<GroceryItem> _groceryItems = [];

  void removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  void _addItem() async {
    // ignore: non_constant_identifier_names
    final New_item = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const new_item()));

    void Loaditem() async {
      final url = Uri.https('flutterprep-ebc4e-default-rtdb.firebaseio.com',
          'Shopping-list.json');
      final response = await http.get(url);
      print(response);
    }

    if (New_item == null) {
      return;
    }
    setState(() {
      _groceryItems.add(New_item);
    });
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
        body: _groceryItems.isEmpty
            ? const Center(
                child: Text('No Groceries found'),
              )
            : ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder: (context, index) {
                  {
                    return Dismissible(
                      onDismissed: (direction) {
                        removeItem(_groceryItems[index]);
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
              ));
  }
}
