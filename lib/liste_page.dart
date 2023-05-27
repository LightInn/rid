import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ListePage extends StatefulWidget {
  const ListePage({Key? key}) : super(key: key);

  @override
  _ListePageState createState() => _ListePageState();
}

class _ListePageState extends State<ListePage> {
  late SharedPreferences _prefs;

  TextEditingController _apiKeyController = TextEditingController();

  bool _isLoading = false;
  var newsDictionary;

  @override
  void initState() {
    super.initState();
    _checkNewsDictionary();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkNewsDictionary() async {
    _isLoading = true;
    _prefs = await SharedPreferences.getInstance();

    final newsDictionary = _prefs.getString('newsDictionary') ?? '[]';

    this.newsDictionary = jsonDecode(newsDictionary);
    this._isLoading = false;
  }

  Future<void> _saveApiKey(String apiKey) async {
    setState(() {
      _isLoading = true;
    });

    await _prefs.setString('apiKey', apiKey);
    final prefs = await _prefs;
    await prefs.setBool('hasApiKey', true);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacementNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),

              // liste des news dans le dictionnaire

              child: ListView.builder(
                  itemCount: this.newsDictionary.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text('Titre de la news $index'),
                        subtitle: Text('Description du produit $index'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
