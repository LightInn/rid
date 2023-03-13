import 'dart:developer';
import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OpenAI openAI;

  late bool _call;

  @override
  void initState() {
    super.initState();
    _call = false;
    initOpenAI();
  }

  @override
  void dispose() {
    openAI.close();
    super.dispose();
  }

  SharedMedia? shared;
  String? _urlContent;
  String? _pageTitle;
  List<String>? _usefulParagraphs;
  String? _synthese;
  bool _isLoading = false;
  List<String>? _listImages;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch the content from the URL
    final response = await http.get(
      Uri.parse(shared!.content!),
      headers: {'Content-Type': 'text/html;'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _urlContent = response.body;
        final document = html.parse(_urlContent!);
        final titleElement = document.querySelector('title');
        if (titleElement != null) {
          _pageTitle = titleElement.text;
        }

        // Récupérer tous les éléments <img>
        final imgElements = document.querySelectorAll('img');
        _listImages = [];
        // Extraire l'URL de chaque image et les ajouter à la liste
        for (final img in imgElements) {
          log("img: ${img.attributes['src']}");
          final src = img.attributes['src'];
          if (src != null) {
            _listImages?.add(src);
          }
        }

        final contentType = response.headers['content-type'];
        if (contentType != null) {
          final charsetMatch =
              RegExp('charset=([\\w-]+)').firstMatch(contentType);
          if (charsetMatch != null) {
            final charset = charsetMatch.group(1);
            final encoder = Encoding.getByName(charset);
            _usefulParagraphs = document
                .querySelectorAll('p')
                .map((p) => p.text.trim())
                .toList();
          }
        }
      });

      if (_usefulParagraphs != null) {
        var joined = _usefulParagraphs?.isNotEmpty == true
            ? _usefulParagraphs!.join(" \n ")
            : '';

        final request = ChatCompleteText(messages: [
          Map.of({
            "role": "user",
            "content":
                'Ton rôle est de synthétiser des articles de presse. Je vais te donner le contenu d\'une page web traitant d\'un sujet d\'actualité et tu dois me le résumer en quelques phrases en ne gardant que l\'essentiel, sans te répéter. Contenu :"' +
                    joined! +
                    '"'
          })
        ], maxToken: 1000, model: kChatGptTurbo0301Model);

        openAI.onChatCompletion(request: request).then((value) => {
              setState(() {
                _synthese = value?.choices[0].message.content;
                _isLoading = value?.choices[0] != null ? false : true;
              })
            });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;

      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
          displayMedium: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        splashColor: Colors.yellow,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              _pageTitle.toString() == "null" ? "Rid" : _pageTitle.toString()),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 10),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : _synthese != null && _synthese != ""
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    _pageTitle.toString(),
                                    style: const TextStyle(
                                      fontSize: 26.0,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    _synthese!,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Text('No data'),

                  // ...
                ],
              ),
            ),
            Center(
              child: Text(
                "Images : ",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _listImages == null
                  ? SizedBox(
                      width: 150,
                      child: Image.network(
                          "https://static.vecteezy.com/system/resources/previews/010/313/693/original/emoji-feel-good-smile-happy-file-png.png"),
                    )
                  : ListView.builder(
                      itemCount: _listImages?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: 150,
                          child: Image.network(_listImages![index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSharedMediaChange(SharedMedia? media) async {
    setState(() {
      _call = true;
      shared = media;
    });
    if (shared?.content?.startsWith('http') == true) {
      initPlatformState();
    }
  }

  Future<void> initOpenAI() async {
    await dotenv.load();
    openAI = OpenAI.instance.build(
        token: dotenv.env['TOKEN'],
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 60),
            connectTimeout: const Duration(seconds: 60)),
        isLogger: true);

    final handler = await ShareHandlerPlatform.instance;
    handler.sharedMediaStream.listen(_handleSharedMediaChange);
    shared = await handler.getInitialSharedMedia();
    if (shared?.content?.startsWith('http') == true) {
      initPlatformState();
    }
  }
}
