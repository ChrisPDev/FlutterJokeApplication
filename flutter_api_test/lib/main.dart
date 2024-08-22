import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'joke_list_page.dart';
import 'add_joke_page.dart';
import 'base_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BasePage(
              title: 'Flutter Joke App',
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _fetchJokeAndShowDialog(context),
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
        '/joke_list': (context) => const JokeListPage(),
        '/add_joke': (context) => const AddJokePage(),
      },
    );
  }

  Future<void> _fetchJokeAndShowDialog(BuildContext context) async {
    final url = Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/random');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final String jokeTitle = data['title'] ?? 'No title';
        final String jokeContent = data['content'] ?? 'No content';

        if (!context.mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(jokeTitle),
              content: Text(jokeContent),
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
      } else {
        throw Exception('Failed to load joke');
      }
    } catch (e) {
      if (!context.mounted) return;

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
}
