// Importerer nødvendige pakker
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Definerer en stateful widget, UpdateJokePage, der bruges til at opdatere en joke
class UpdateJokePage extends StatefulWidget {
  final int jokeId; // ID på den joke, der skal opdateres
  final String initialTitle; // Initial titel på jokeren
  final String initialContent; // Initial indhold af jokeren
  final String initialCategory; // Initial kategori af jokeren

  // Constructor til at initialisere værdierne
  const UpdateJokePage({
    super.key,
    required this.jokeId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialCategory,
  });

  @override
  _UpdateJokePageState createState() => _UpdateJokePageState();
}

// State-klassen for UpdateJokePage, som håndterer tilstanden og logikken
class _UpdateJokePageState extends State<UpdateJokePage> {
  // Teksteditorkontrollere til at styre input i tekstfelterne
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    // Initialiserer tekstkontrollere med de initiale værdier
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _categoryController = TextEditingController(text: widget.initialCategory);
  }

  // Asynkron metode til at opdatere en joke ved at sende en PUT-anmodning til API'et
  Future<void> _updateJoke() async {
    final url = Uri.parse(
        'https://flutterjokeapplication.onrender.com/api/Jokes/${widget.jokeId}'); // API endpoint
    final headers = {'Content-Type': 'application/json'}; // Header for HTTP anmodning
    final body = json.encode({
      'id': widget.jokeId,
      'createdAt': DateTime.now().toUtc().toIso8601String(), // Tidsstempel for oprettelse
      'updatedAt': DateTime.now().toUtc().toIso8601String(), // Tidsstempel for opdatering
      'title': _titleController.text, // Opdateret titel
      'content': _contentController.text, // Opdateret indhold
      'category': _categoryController.text, // Opdateret kategori
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 204) { // Hvis opdateringen var succesfuld
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joke updated successfully!')), // Viser succes besked
        );
        Navigator.of(context).pop(true); // Navigerer tilbage til forrige skærm med resultat true
      } else {
        throw Exception('Failed to update joke. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Viser en fejl dialog, hvis opdateringen fejler
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
    return Scaffold(
      appBar: AppBar(title: const Text('Update Joke')), // AppBar med titel
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tekstfelt til at redigere titel
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            // Tekstfelt til at redigere indhold
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            // Tekstfelt til at redigere kategori
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20), // Plads mellem tekstfelter og knap
            ElevatedButton(
              onPressed: _updateJoke, // Knap til at opdatere jokeren
              child: const Text('Update Joke'),
            ),
          ],
        ),
      ),
    );
  }
}
