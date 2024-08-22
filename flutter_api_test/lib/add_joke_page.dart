import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_page.dart';

class AddJokePage extends StatefulWidget {
  const AddJokePage({super.key});

  @override
  _AddJokePageState createState() => _AddJokePageState();
}

class _AddJokePageState extends State<AddJokePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();

  Future<void> _addJoke() async {
    final url = Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'title': _titleController.text,
      'content': _contentController.text,
      'category': _categoryController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joke added successfully!')),
        );
        _titleController.clear();
        _contentController.clear();
        _categoryController.clear();
      } else {
        throw Exception('Failed to add joke');
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Add Joke',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addJoke,
              child: const Text('Add Joke'),
            ),
          ],
        ),
      ),
    );
  }
}
