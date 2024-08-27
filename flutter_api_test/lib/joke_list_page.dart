// Importerer nødvendige pakker og filer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_page.dart';
import 'update_joke_page.dart';

// Definerer en stateful widget, JokeListPage, der viser en liste af jokes
class JokeListPage extends StatefulWidget {
  const JokeListPage({super.key});

  @override
  State<JokeListPage> createState() => _JokeListPageState();
}

// State-klassen for JokeListPage, som håndterer tilstanden og logikken
class _JokeListPageState extends State<JokeListPage> {
  // Liste til at gemme jokes hentet fra API'et
  List<Map<String, dynamic>> _jokes = [];

  // Boolean værdi for at spore sorteringsordenen (alfabetisk eller efter ID)
  bool _isSortedAlphabetically = false;

  // TextEditingController til at styre input i søgefeltet
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJokes(); // Henter jokes, når siden initialiseres
  }

  // Asynkron metode til at hente jokes fra API'et
  Future<void> _fetchJokes({bool sorted = false}) async {
    final url = sorted
        ? Uri.parse(
            'https://flutterjokeapplication.onrender.com/api/Jokes/sorted')
        : Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _jokes = List<Map<String, dynamic>>.from(data); // Opdaterer jokes listen
        });
      } else {
        throw Exception('Failed to load jokes');
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  // Asynkron metode til at slette en joke fra API'et
  Future<void> _deleteJoke(int id) async {
    final url =
        Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        setState(() {
          _jokes.removeWhere((joke) => joke['id'] == id); // Fjerner joke fra listen
        });
        _showDialog(context, 'Success', 'Joke deleted successfully.');
      } else {
        throw Exception(
            'Failed to delete joke. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  // Asynkron metode til at søge efter en joke ved ID
  Future<void> _searchJokeById() async {
    final String id = _searchController.text;
    if (id.isEmpty) {
      return;
    }

    final url =
        Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String jokeTitle = data['title'] ?? 'No title';
        final String jokeContent = data['content'] ?? 'No content';
        final String jokeCategory = data['category'] ?? 'No category';

        if (!mounted) return;

        _showDialog(
          context,
          jokeTitle,
          '$jokeContent\n\nID: $id, Category: $jokeCategory',
        );
      } else {
        throw Exception('Failed to load joke');
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  // Metode til at skifte sorteringsorden og hente jokes igen baseret på den nye sorteringsorden
  void _toggleSortOrder() {
    setState(() {
      _isSortedAlphabetically = !_isSortedAlphabetically;
    });
    _fetchJokes(sorted: _isSortedAlphabetically);
  }

  // Metode til at vise detaljer om en specifik joke
  Future<void> _showJokeDetail(int id) async {
    final url =
        Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String jokeTitle = data['title'] ?? 'No title';
        final String jokeContent = data['content'] ?? 'No content';
        final String jokeCategory = data['category'] ?? 'No category';

        if (!mounted) return;

        _showDialog(
          context,
          jokeTitle,
          '$jokeContent\n\nID: $id, Category: $jokeCategory',
        );
      } else {
        throw Exception('Failed to load joke');
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  // Metode til at vise flere muligheder for en joke, såsom at opdatere eller slette
  Future<void> _showAdditionalOptions(
      int id, String title, String content, String category) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateJokePage(
          jokeId: id,
          initialTitle: title,
          initialContent: content,
          initialCategory: category,
        ),
      ),
    );

    if (result == true) {
      _fetchJokes();
    }
  }

  // Metode til at vise en dialog for at bekræfte sletning af en joke
  Future<void> _showDeleteOptions(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Joke'),
          content: const Text('Are you sure you want to delete this joke?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Lukker dialogen
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteJoke(id); // Kald på _deleteJoke metoden
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Metode til at vise en dialog med en given titel og indhold
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Lukker dialogen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Bygger widget-træet for denne side
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Joke List',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by ID',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _searchJokeById(), // Udfører søgning ved indsendelse
            ),
          ),
          // Knap til at skifte sorteringsorden
          ElevatedButton(
            onPressed: _toggleSortOrder,
            child: Text(
                _isSortedAlphabetically ? 'Sort by ID' : 'Sort Alphabetically'),
          ),
          // Viser en loading indikator, hvis listen er tom
          if (_jokes.isEmpty) const Center(child: CircularProgressIndicator()),
          // Viser listen af jokes
          Expanded(
            child: ListView.builder(
              itemCount: _jokes.length,
              itemBuilder: (context, index) {
                final joke = _jokes[index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(joke['title'] ?? 'No title'),
                      Text(
                        'ID: ${joke['id']}, Category: ${joke['category']}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Knap til at redigere en joke
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAdditionalOptions(
                          joke['id'],
                          joke['title'] ?? 'No title',
                          joke['content'] ?? 'No content',
                          joke['category'] ?? 'No category',
                        ),
                      ),
                      // Knap til at slette en joke
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteOptions(joke['id']),
                      ),
                    ],
                  ),
                  // Tryk på en joke for at se detaljer
                  onTap: () => _showJokeDetail(joke['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
