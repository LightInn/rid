import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    dotenv.load().then((dotenv) =>


    {

    openAI = OpenAI.instance.build(
    token: dotenv.env['TOKEN'],
    baseOption: HttpSetup(
    receiveTimeout: const Duration(seconds: 5),
    connectTimeout: const Duration(seconds: 5)),
    isLogger: true);


    }


    );

    initPlatformState();
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final handler = ShareHandlerPlatform.instance;
    shared = await handler.getInitialSharedMedia();

    handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      setState(() {
        this.shared = media;
      });
    });

    if (true) {
      // todo remettre   shared?.content?.startsWith('http') == false
      // Fetch the content from the URL
      final response = await http.get(
        // Uri.parse(shared!.content!),
        Uri.parse(
            "https://www.lequipe.fr/Basket/Actualites/New-york-stoppe-les-lakers-philadelphie-intraitable-face-a-washington/1385588"),
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

        var joined = _usefulParagraphs?.join(" \n ");

        final request = ChatCompleteText(messages: [
          Map.of({"role": "user", "content": 'Hello!'})
        ], maxToken: 200, model: kChatGptTurbo0301Model);

        openAI.onChatCompletion(request: request).then((value) =>
        {
          setState(() {
            _synthese = value?.choices[0].message.content;
          })
        });
      }
    }

    if (!mounted) return;
    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              _pageTitle.toString() == "null" ? "rid" : _pageTitle.toString()),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Text(
                  "Shared to conversation identifier: ${shared
                      ?.conversationIdentifier}"),
              const SizedBox(height: 10),
              Text("Shared text: ${shared?.content}"),
              const SizedBox(height: 10),
              _synthese != null
                  ? Column(
                children: [
                  Text("Page title: $_pageTitle"),
                  const SizedBox(height: 10),
                  Text(_synthese!)
                ],
              )
                  : const SizedBox.shrink(),
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
