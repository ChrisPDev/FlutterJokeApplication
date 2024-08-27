// Importerer nødvendige pakker fra Flutter og tredjepart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Til HTTP-anmodninger
import 'dart:convert'; // Til JSON-dekodning

// Importerer lokale sider
import 'joke_list_page.dart';
import 'add_joke_page.dart';
import 'base_page.dart';

// Hovedfunktion som starter appen
void main() {
  runApp(const MyApp());
}

// Definerer hovedapplikationsklassen, som er en stateless widget
class MyApp extends StatelessWidget {
  // Konstruktør for MyApp klassen
  const MyApp({super.key});

  // Overrider build-metoden til at definere widgettræet
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // Titel på applikationen
      theme: ThemeData( // Definerer applikationens tema
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Initiale rute for applikationen
      initialRoute: '/',
      // Definerer ruter for navigation
      routes: {
        '/': (context) => BasePage(
              title: 'Flutter Joke App',
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _fetchJokeAndShowDialog(context), // Henter og viser en joke, når knappen trykkes
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(50),
                  ),
                  child: const Text(
                    '😂',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
        '/joke_list': (context) => const JokeListPage(), // Rute til jokes liste
        '/add_joke': (context) => const AddJokePage(), // Rute til at tilføje en joke
      },
    );
  }

  // Asynkron metode til at hente en joke fra API og vise den i en dialog
  Future<void> _fetchJokeAndShowDialog(BuildContext context) async {
    // URL til at hente en tilfældig joke
    final url = Uri.parse(
        'https://flutterjokeapplication.onrender.com/api/Jokes/random');

    try {
      // Udfører GET anmodning til API'et
      final response = await http.get(url);

      // Kontrollerer om anmodningen var succesfuld
      if (response.statusCode == 200) {
        // Dekoder JSON-responsen
        final data = json.decode(response.body);

        // Ekstraherer joke detaljer fra responsen
        final String jokeTitle = data['title'] ?? 'No title';
        final String jokeContent = data['content'] ?? 'No content';
        final int jokeId = data['id'];
        final String jokeCategory = data['category'] ?? 'No category';

        // Kontrollerer om konteksten stadig er gyldig
        if (!context.mounted) return;

        // Viser dialog med joke information
        _showDialog(
          context,
          jokeTitle,
          '$jokeContent\n\nID: $jokeId, Category: $jokeCategory',
        );
      } else {
        // Smider en undtagelse, hvis anmodningen fejler
        throw Exception('Failed to load joke');
      }
    } catch (e) {
      // Håndterer eventuelle fejl ved API-kaldet

      // Kontrollerer om konteksten stadig er gyldig
      if (!context.mounted) return;

      // Viser fejlmeddelelse i en dialog
      _showDialog(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  // Metode til at vise en dialog i appen
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
                // Lukker dialogen, når knappen trykkes
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
