import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences _prefs;

  TextEditingController _apiKeyController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    _prefs = await SharedPreferences.getInstance();

    final apiKey = await _prefs.getString('apiKey');

    if (apiKey != null && apiKey.isNotEmpty) {
      Navigator.of(context).pop();
    }
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
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your API key:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      hintText: 'API key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      final apiKey = _apiKeyController.text.trim();
                      if (apiKey.isNotEmpty) {
                        await _saveApiKey(apiKey);
                      }
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'You can get your API key from the following link:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () => launchUrl(
                        Uri.parse("https://platform.openai.com/account/api-keys")),
                    child: const Text(
                      'https://platform.openai.com/account/api-keys',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
