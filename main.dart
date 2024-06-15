import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(InspiringQuotesApp());

class InspiringQuotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inspiring Quotes',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey, 
          foregroundColor: Colors.white,
          elevation: 5,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentQuote = "";
  final List<String> favoriteQuotes = [];

  @override
  void initState() {
    super.initState();
    fetchRandomQuote();
  }

  Future<void> fetchRandomQuote() async {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final String quote = data[0]['q'] ?? "No quote available";
      setState(() {
        currentQuote = quote;
      });
    } else {
      setState(() {
        currentQuote = "Failed to fetch quote";
      });
    }
  }

  void shareQuote() {
    Share.share(currentQuote);
  }

  void addToFavorites() {
    if (!favoriteQuotes.contains(currentQuote)) {
      setState(() {
        favoriteQuotes.add(currentQuote);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote added to favorites.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote already in favorites.'),
        ),
      );
    }
  }

  void shareFavoriteQuotes() {
    if (favoriteQuotes.isNotEmpty) {
      Share.share('My Favorite Quotes:\n\n${favoriteQuotes.join('\n')}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No favorite quotes to share.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspiring Quotes'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: navigateToFavoriteQuotes,
          ),
        ],
      ),
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Color.fromARGB(255, 111, 169, 198)])
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentQuote,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: fetchRandomQuote,
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 117, 118, 104), 
                        onPrimary: Colors.white, // Text color
                        elevation: 10, // Remove button shadow
                      ),
                      child: Text('Next Quote'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: shareQuote,
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 117, 118, 104), // 
                        onPrimary: Colors.white, // Text color
                        elevation: 10,// Remove button shadow
                      ),
                      child: Text('Share'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addToFavorites,
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 117, 118, 104), 
                        onPrimary: Colors.white, // Text color
                        elevation: 10, // Remove button shadow
                      ),
                      child: Text('Add to Favorites'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: shareFavoriteQuotes,
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 117, 118, 104), 
                        onPrimary: Colors.white, // Text color
                        elevation: 10, // Remove button shadow
                      ),
                      child: Text('Share Favorites'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToFavoriteQuotes() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteQuotesScreen(favoriteQuotes),
      ),
    );
  }
}

class FavoriteQuotesScreen extends StatelessWidget {
  final List<String> favoriteQuotes;

  FavoriteQuotesScreen(this.favoriteQuotes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Quotes'),
      ),
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Color.fromARGB(255, 111, 169, 198)])
        ),
        child: ListView.builder(
          itemCount: favoriteQuotes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                favoriteQuotes[index],
                style: TextStyle(color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.share(favoriteQuotes[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Pass the index of the quote to be deleted back to the previous screen
                      Navigator.of(context).pop(index);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
