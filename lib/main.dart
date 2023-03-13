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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch the content from the URL
    final response = await http.get(
      Uri.parse(shared!.content!),
      // Uri.parse(
      //     "https://www.leparisien.fr/info-paris-ile-de-france-oise/transports/greve-la-ratp-prevoit-un-trafic-quasi-normal-mercredi-sauf-pour-le-rer-tres-pertube-13-03-2023-NDGVJI4U3FDNTB4APJ7BIYFQFA.php"),
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
        fontFamily: 'Georgia',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
          displayMedium: TextStyle(
              fontSize: 18.0, fontFamily: 'Montserrat', color: Colors.white),
        ),
        splashColor: Colors.yellow,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              _pageTitle.toString() == "null" ? "rid" : _pageTitle.toString()),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 10),
              _synthese != null
                  ? Column(
                      children: [
                        Text("Page title: $_pageTitle",
                            style: Theme.of(context).textTheme.displayLarge),
                        const SizedBox(height: 10),
                        Text(_synthese!,
                            style: Theme.of(context).textTheme.displayMedium)
                      ],
                    )
                  : _isLoading
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox.shrink(),
              Text(_call.toString()),

              // ...
            ],
          ),
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
    shared = await handler.getInitialSharedMedia();
    await handler.sharedMediaStream.listen(_handleSharedMediaChange);
  }
}
