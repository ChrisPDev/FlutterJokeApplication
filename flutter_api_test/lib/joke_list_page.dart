import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_page.dart';

class JokeListPage extends StatefulWidget {
  const JokeListPage({super.key});

  @override
  State<JokeListPage> createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  List<Map<String, dynamic>> _jokes = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isSortedAlphabetically = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJokes();  // Fetch jokes in default order (by ID)
  }

  Future<void> _fetchJokes({bool sorted = false, String? category}) async {
    Uri url;
    if (category != null) {
      url = Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/category/$category');
    } else {
      url = sorted
          ? Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/sorted')
          : Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes');
    }

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _jokes = List<Map<String, dynamic>>.from(data);
          if (_categories.isEmpty) {
            _categories = _extractCategories(_jokes);
          }
        });
      } else {
        throw Exception('Failed to load jokes');
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

  Future<void> _searchJokeById() async {
    final String id = _searchController.text;
    if (id.isEmpty) {
      return;
    }

    final url = Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String jokeTitle = data['title'] ?? 'No title';
        final String jokeContent = data['content'] ?? 'No content';
        final String jokeCategory = data['category'] ?? 'No category';

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jokeTitle),
                  Text(
                    'ID: $id, Category: $jokeCategory',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
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

  List<String> _extractCategories(List<Map<String, dynamic>> jokes) {
    final categories = jokes
        .map((joke) => joke['category']?.toString() ?? 'No category')
        .toSet()
        .toList();
    categories.sort(); // Sort categories alphabetically
    return categories;
  }

  void _toggleSortOrder() {
    setState(() {
      _isSortedAlphabetically = !_isSortedAlphabetically;
    });
    _fetchJokes(sorted: _isSortedAlphabetically);
  }

  Future<void> _showJokeDetail(int id) async {
    final url = Uri.parse('https://flutterjokeapplication.onrender.com/api/Jokes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final String jokeTitle = data['title'] ?? 'No title';
        final String jokeContent = data['content'] ?? 'No content';
        final String jokeCategory = data['category'] ?? 'No category';

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jokeTitle),
                  Text(
                    'ID: $id, Category: $jokeCategory',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
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
      title: 'Joke List',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Joke ID',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _searchJokeById,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _toggleSortOrder,
            child: Text(_isSortedAlphabetically ? 'Sort by ID' : 'Sort A-Z'),
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('Select Category'),
            items: _categories.map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
              _fetchJokes(category: newValue);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _jokes.length,
              itemBuilder: (context, index) {
                final joke = _jokes[index];
                return ListTile(
                  title: Text('${joke['title'] ?? 'No title'} (${joke['category'] ?? 'No category'})'),
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
