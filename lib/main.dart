import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinityfree_bypasser/infinityfree_bypasser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfinityFree Bypasser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'InfinityFree Bypasser'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();

  final InfinityfreeBypasser _bypasser = InfinityfreeBypasser();

  final Dio _dio = Dio();

  bool isLoading = false;
  String responseText = '';

  Future<void> _bypass() async {
    String url = _urlController.text;

    // Bypass the URL
    await _bypasser.bypass(url);

    // Check if bypassing failed
    if (_bypasser.cookie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bypass failed!'),
        ),
      );
      return;
    }

    // Bypass done; Now you can use the cookie
    // print(_bypasser.cookie);

    // Now you can make the request with the cookie
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Cookie': _bypasser.cookie,
          },
          responseType: ResponseType.plain,
        ),
      );

      setState(() {
        responseText = response.data.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request failed!'),
        ),
      );
    }
  }

  void _doBypass() async {
    setState(() {
      responseText = '';
      isLoading = true;
    });
    await _bypass();
    setState(() {
      isLoading = false;
    });
  }

  String _renderResponseText() {
    try {
      // If JSON, pretty print it
      return const JsonEncoder.withIndent('  ').convert(json.decode(responseText));
    } catch (e) {
      // If not JSON, return the plain text
      return responseText;
    }
  }

  bool _validateUrl() {
    return Uri.tryParse(_urlController.text)?.isAbsolute ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : FilledButton(
                    onPressed: _validateUrl() ? _doBypass : null,
                    child: const Text('Bypass'),
                  ),
            const SizedBox(height: 20),
            responseText.isEmpty
                ? const Text(
                    '[Response will appear here]',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                : Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _renderResponseText(),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
