// Importerer nødvendige pakker fra Flutter
import 'package:flutter/material.dart';

// Definerer en stateless widget kaldet BasePage
class BasePage extends StatelessWidget {
  // Deklarerer to final variabler til at gemme titlen og child widget
  final String title;
  final Widget child;

  // Konstruktør for BasePage-klassen
  const BasePage({super.key, required this.title, required this.child});

  // Overrider build-metoden for at definere widgettræet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Definerer appbar for siden med en titel og en menu-knap
      appBar: AppBar(
        title: Text(title), // Viser sidens titel
        leading: Builder(
          // Brug af en Builder for at sikre korrekt kontekst for Scaffold
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Ikon for menu-knappen
            onPressed: () => Scaffold.of(context).openDrawer(), // Åbner skuffen, når knappen trykkes
          ),
        ),
      ),
      // Definerer en skuffe (drawer) med navigationsmuligheder
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Header for skuffen
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple, // Baggrundsfarve for headeren
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white, // Tekstfarve for menu header
                  fontSize: 24, // Skriftstørrelse for menu header
                ),
              ),
            ),
            // Menu punkt for at navigere til startskærmen
            ListTile(
              leading: const Icon(Icons.home), // Ikon for startskærmen
              title: const Text('Home'), // Tekst for startskærmen
              onTap: () {
                Navigator.pop(context); // Lukker skuffen
                Navigator.pushReplacementNamed(context, '/'); // Navigerer til startskærmen
              },
            ),
            // Menu punkt for at navigere til joke listen
            ListTile(
              leading: const Icon(Icons.list), // Ikon for joke listen
              title: const Text('Joke List'), // Tekst for joke listen
              onTap: () {
                Navigator.pop(context); // Lukker skuffen
                Navigator.pushReplacementNamed(context, '/joke_list'); // Navigerer til joke listen
              },
            ),
            // Menu punkt for at navigere til tilføj joke skærmen
            ListTile(
              leading: const Icon(Icons.add), // Ikon for tilføj joke
              title: const Text('Add Joke'), // Tekst for tilføj joke
              onTap: () {
                Navigator.pop(context); // Lukker skuffen
                Navigator.pushReplacementNamed(context, '/add_joke'); // Navigerer til tilføj joke skærmen
              },
            ),
            // Menu punkt for at vise en dialog med "Om" information
            ListTile(
              leading: const Icon(Icons.info), // Ikon for "Om" sektionen
              title: const Text('About'), // Tekst for "Om" sektionen
              onTap: () {
                Navigator.pop(context); // Lukker skuffen
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Viser en dialog med "Om" information
                    return AlertDialog(
                      title: const Text('About'),
                      content: const Text('This is a Flutter Joke App.'),
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
              },
            ),
          ],
        ),
      ),
      // Definerer kroppens widget, som er bestemt af child argumentet
      body: child,
    );
  }
}
