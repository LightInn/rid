import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';

import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  ChatGPTApi _api = ChatGPTApi(
      sessionToken:
          "eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIn0..6yszwOMNdmbewTfS._apejOfRnbB5PtLTtqlnqhYn10Mbicy3PAYtoef6VbWthlarREDgATnQJwBE8hMNPiYOtHiz_UciCP9U_Utcpn440_ekkE2FZPKuPqStFRPyfikPJ_r4aHfs_5wzdMs6uheWU86nsgL9s_wmeyNuEW-6ONa8tV3aNWct1eMQ1eQp6bAPDepKMDga3bYZ-hK3_rbdRbBJb70bz9agSvfT4AB9og1jhs_BSAjsAcFgusYvJYOmhmConRsP1Xmu05v-bH1eR8TJtastoFsqHWj9HVFlofZA4BvRn9ZtxgtI_uzSBB90_YLt3I074XI7keA_OQWdyaTW4LVWn7EzAVmu7rFJvE39rfLOuX1Wb7i5XjKE8SlN54HIerjLx79yxW3my0Xz60o-3_ojGhQoRZdxZSs8xSjn3CwZANFzllY165Nru3GRXXeOVbNUmr4CARVYMDbxZ5ySm3Dkt58dkPLSpA0ZkobYgZ2P01vv1afJHcZvoYu5SM-PMXzO5QflhM9fc9FDNdH1VzTxoByhVHEmQG6CDvVHewoZ-agAg2S6-lDPKW9VHPzVxUT07b5Z8Xp-xYn6ZZBKJYbaAZA9JYa73VUtWRSxdt7QNtBdCJ8bqTqIIDNv7evX5QN_7X7Lc_JacadL3p5T6jOrgdGJ0pDS7ESJ1IzMHv3azbVDxgLYTUe-LFOCE-FKQAXcCy4v9aYuDbgRh4STm4eNXK6pUJEmC6qRtHP9mSaV5iLh0j9O5r259wT11kgFWoQ0nTC0UPYaFipnItiF09JAqxK-3VVrQ_T96AstnV5xQgpjeQG6gZirk9mknM7yK6JeYKO2bz6U0JACUu6pDadl4H3EMKWDrMGwcvnI40oHmJJ5VEXF7E6mh62Am8kZvcbAzpQZNxStEDK4JMXB1Tz5VrB3kSdCvNxGZZz9gpUKEra9V-IAlIaZAVN6zyPVuN0jxcp-ylSZlwim2kN-H66fHhTC1lFPCFe5wAjiLyFt7ou0gbt0SS_KKPall8dF8eR_OR2CV6-yr-sHhafKCMrooS4ZrISkwWhV9GPB6HsUevDvv-BF6wa4gIB9QqIrXjcGX0wFYujp75pIUBqoRbv9kgyxExyO_OOB4moHNYrJlFhEbHmuJZ2o4GRrukTwHalFhayLA68DOWvtPxm5hVPxvkr0MyUDbcHSkMgFTRJ6ZKgKKyeR-t8OEamBw_Tl-qvBDjtRTU193DdL1Hxqdatx865aMY6QO2lGnL-CoWU2S8A29WYrXD7CdyAurF0zY_YoJgrmWirK_ZTZoWe11UnBSp7jtTrSyoxAH_VQU0WTk7hYJ2apa8bZZ23nlzLKTgeolDLuLjh1X-lQd8f_VniyYsm3F3hjMedDpDc3GdcqjPce_gmrHV9FpSscAmSLixyHu6AZzX3niCbNZbfocedYs26rwXNW9q_SJ37GKbkTBZEQS_gC4BXWCmDvcfpNYHcbTXOqgOlw-pIRgKS8mP_0vGoXtrLSrjXZJVCFFGp-ihS_g60JmmgikibSfX3xKDI4Qgl6yMINJ4hUlkJMTh60fFpWjiSP4Hq04fh7gFBJg_Ff8cvG9v8oBcLml8XlDG46XkMBHIPsPWHFUG_gUmvCQRsidrGmw1xngaoUUF2zDw-GYz-QpQUaoos0lFdGwDtkU506s6fCJifaIlBnV_OZDkgN8svo_YgAZa4Hv7Pcf2Txy8YouJcjdQw7vPQUZI5KgmETYOSHy4MUYMnR-I9uegHgAY6RS58-isIgF6oXvlAU1qh6813TCqE1lNWhP5BuIHXAovnGas6mYEIpQgsTj_gDobHchGcTpLvUvJkY_tFKm9UF5Y7VDuXvJSrtVCYJmEf6lMFVtnrhYrIB1n4FZUz7hDGSiDNostAFbz0LAqWL4nEbF7VhCoyaBFfjBncs5-mMMotXhGsWeTR6PARTbePuAmiJBDFARll2Vz_-Uv9LQ9g-jzLZTJqIm1Z3J1iF12zRGwbngvAD2NwjsCS-aWFbHSpr9PTDByx9Wd_GZPtkDk6lRK7pBoghkNnzCET4G3Ndrx9lVeolflfQo-U7bps0Ks2r1n99RwUk__7vmPkpcFhWDnzlmho7nUfvMOZq3JRhzYa2XwsHAYuhbt3AWdoCD3OWQK7evO17La0MJIUBioxodfHS7K0N4qWUiwt148vjUxVicZrdI15BsX-wxWh4ihNXpX2JRMwsuDIruS_KDfUjUqQ5NKB4_Asa9WZCutouNypFwRB8vYcWdHcB3tBrIHBBweXZhxUpByW5ydjwax-EznJ9XQUxPADP5Wn5FIrEWqam8wxldfQXS1uGsV97ndzuwCxM-Zhm2Q0a6j5elHJhx29LlI9hKvcOtw34DpoTmTOgMgwhDphUI2OWmZXxS7-FQU8tFrfgvufGeIy8V30Yp9X8rU80PSZ1qAt3sMBumAQgg9J1lwsZpw4zqUgW7Q10XcKMyAbw4YaV-Z0Zrf2lgfDTRVvIsX-ekZM_mppKlk5R8vFr08jSf7jdF7dSig_zLeBLAXSfrVVu.yYgV1yUh9GS107xdtchOCg",
      clearanceToken: "CH_SK5w5fspfD0dim42ZOW0W56GocGv6b3.W_1JGIEc-1678091740-0-1-b07c3ef0.a6034129.24f3f25c-250");
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
        Uri.parse("https://www.lequipe.fr/Basket/Actualites/New-york-stoppe-les-lakers-philadelphie-intraitable-face-a-washington/1385588"),
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

        _api
            .sendMessage(
              joined!,
              conversationId: "",
              parentMessageId: "",
            )
            .then((value) => {
                  setState(() {
                    _synthese = value.message;
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
                  "Shared to conversation identifier: ${shared?.conversationIdentifier}"),
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
