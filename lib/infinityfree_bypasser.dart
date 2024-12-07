/*
============================== Sample Response (when Cookie not appeared) ==============================
<html>

<body>
    <script type="text/javascript" src="/aes.js"></script>
    <script>
        function toNumbers(d){var e=[];d.replace(/(..)/g,function(d){e.push(parseInt(d,16))});return e}function toHex(){for(var d=[],d=1==arguments.length&&arguments[0].constructor==Array?arguments[0]:arguments,e="",f=0;f<d.length;f++)e+=(16>d[f]?"0":"")+d[f].toString(16);return e.toLowerCase()}var a=toNumbers("f655ba9d09a112d4968c63579db590b4"),b=toNumbers("98344c2eee86c3994890592585b49f80"),c=toNumbers("063773702db3e21280d5e740ea12dd26");document.cookie="__test="+toHex(slowAES.decrypt(c,2,a,b))+"; expires=Thu, 31-Dec-37 23:55:55 GMT; path=/"; location.href="http://jewellerytrial.infinityfreeapp.com/server/public/api/test/?i=1";
    </script><noscript>This site requires Javascript to work, please enable Javascript in your browser or use a browser
        with Javascript support</noscript>
</body>

</html>
========================================================================================================
*/

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';

class InfinityfreeBypasser {
  final Dio dio = Dio();

  Map<String, String> variables = {};

  String? cookie;

  Future<void> bypass(String baseUrl) async {
    if (cookie != null) return;
    await _calculateCookie(baseUrl);
  }

  Future<void> _calculateCookie(String baseUrl) async {
    try {
      // Make the Dio Request (without cookie) to get the script content
      final response = await dio.get(baseUrl);

      // Check if script is present in the response
      RegExp scriptRegExp = RegExp(r'<script[^>]*>(.*?)</script>', dotAll: true);
      RegExpMatch? scriptMatch = scriptRegExp.firstMatch(response.data);

      if (scriptMatch == null) return;

      // Extract hex values of a, b, and c
      for (String varName in ['a', 'b', 'c']) {
        RegExp varRegExp = RegExp('$varName=toNumbers\\("([0-9a-fA-F]+)"\\)');
        RegExpMatch? varMatch = varRegExp.firstMatch(response.data);
        if (varMatch != null) {
          String hexString = varMatch.group(1)!;
          variables[varName] = hexString;
        }
      }

      _generateByPassCookie();
    } catch (e) {
      print(e);
    }
  }

  void _generateByPassCookie() {
    // final a = _toNumbers('f655ba9d09a112d4968c63579db590b4');
    // final b = _toNumbers('98344c2eee86c3994890592585b49f80');
    // final c = _toNumbers('690d244f9be9f2f15b50e07bc5c342f7');

    if (variables.containsKey('a') == false || variables.containsKey('b') == false || variables.containsKey('c') == false) return;

    final a = _toNumbers(variables['a']!);
    final b = _toNumbers(variables['b']!);
    final c = _toNumbers(variables['c']!);

    final key = Key(Uint8List.fromList(a));
    final iv = IV(Uint8List.fromList(b));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: null));

    final decrypted = encrypter.decryptBytes(Encrypted(Uint8List.fromList(c)), iv: iv);

    final cookieValue = _toHex(decrypted).toLowerCase();

    cookie = '__test=$cookieValue';
  }

  List<int> _toNumbers(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  String _toHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
