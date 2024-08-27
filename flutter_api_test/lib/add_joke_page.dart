// Importerer nødvendige pakker fra Dart og Flutter
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importerer lokal BasePage
import 'base_page.dart';

// Definerer en stateful widget kaldet AddJokePage
class AddJokePage extends StatefulWidget {
  // Konstruktør for AddJokePage klassen
  const AddJokePage({super.key});

  @override
  _AddJokePageState createState() => _AddJokePageState();
}

// State-klasse for AddJokePage som håndterer logikken og tilstanden
class _AddJokePageState extends State<AddJokePage> {
  // Tekstcontrollers til at fange brugerinput fra tekstfelter
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();

  // Asynkron metode til at tilføje en joke ved at sende en POST-anmodning til API'et
  Future<void> _addJoke() async {
    // Tjekker om alle felter er udfyldt
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      // Viser en besked hvis felter mangler
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // URL til API-endepunktet for at tilføje en joke
    final url =
        Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes');
    // Headers og body for POST-anmodningen
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'title': _titleController.text,
      'content': _contentController.text,
      'category': _categoryController.text,
    });

    try {
      // Udfører POST-anmodningen
      final response = await http.post(url, headers: headers, body: body);

      // Tjekker om anmodningen var succesfuld (statuskode 201)
      if (response.statusCode == 201) {
        // Tjekker om konteksten stadig er monteret
        if (!mounted) return;
        // Viser en succesbesked
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joke added successfully!')),
        );
        // Rydder input felterne
        _titleController.clear();
        _contentController.clear();
        _categoryController.clear();
      } else {
        // Kaster en undtagelse hvis anmodningen fejler
        throw Exception('Failed to add joke');
      }
    } catch (e) {
      // Håndterer fejl under API-kaldet
      if (!mounted) return;
      // Viser en fejlbesked i en dialog
      _showDialog(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  // Metode til at vise en dialog med en given titel og indhold
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title), // Titel på dialogen
          content: Text(content), // Indhold af dialogen
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Lukker dialogen når 'OK' trykkes
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Overrider build-metoden for at definere widgettræet
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Add Joke', // Titel for siden
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Tekstfelt for titlen
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            // Tekstfelt for indholdet af joken
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            // Tekstfelt for kategorien af joken
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20), // Plads mellem tekstfelterne og knappen
            // Knap til at tilføje joken
            ElevatedButton(
              onPressed: _addJoke, // Kald på _addJoke metoden når knappen trykkes
              child: const Text('Add Joke'),
            ),
          ],
        ),
      ),
    );
  }
}
