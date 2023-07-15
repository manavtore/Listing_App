// ignore_for_file: camel_case_types, non_constant_identifier_names
import 'dart:convert';
import 'package:challenges/data/data.dart';
import 'package:challenges/models/category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class new_item extends StatefulWidget {
  const new_item({super.key});

  @override
  State<new_item> get createState => _new_itemState();
}

class _new_itemState extends State<new_item> {
  final _FormKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    if (_FormKey.currentState!.validate()) {
      _FormKey.currentState!.save();
      final url = Uri.https('flutterprep-ebc4e-default-rtdb.firebaseio.com',
          'Shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          }));

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
              key: _FormKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length == 1 ||
                          value.trim().length > 50) {
                        return 'Must be between 1 to 50 charecter long';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            label: Text('Quantity'),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: _enteredQuantity.toString(),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return 'Must be a number';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredQuantity = int.parse(value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField(
                            value: _selectedCategory,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                  value: category.value,
                                  child: Row(children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(category.value.title),
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
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            _FormKey.currentState!.reset();
                          },
                          child: const Text('Reset')),
                      ElevatedButton(
                          onPressed: _saveItem, child: const Text('Add Item'))
                    ],
                  )
                ],
              ))),
    );
  }
}
