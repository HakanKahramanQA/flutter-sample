// import 'dart:io';
//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:hello_world/main.dart' as app;
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   group('network logs flutter integration test', () {
//     for (int i = 1; i <= 5; i++) {
//     testWidgets('API call test for valid IP address $i',
//             (tester) async {
//           app.main();
//           await tester.pumpAndSettle();
//           final String customHeader = 'test$i';
//           final String url = 'https://ipinfo.io/ip?$customHeader';
//           final response = await http.get(
//               Uri.parse("https://ipinfo.io/ip"),
//             headers: {
//               'Custom-Header': customHeader,
//             },
//           );
//           final Finder fab = find.byTooltip('Increment');
//           bool isValidIpAddress(String ip) {
//             final RegExp ipRegex = RegExp(
//               r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
//               r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
//             );
//             return ipRegex.hasMatch(ip);
//           }
//           expect(response.statusCode, 200);
//           print("******************");
//           print(response.statusCode);
//           print(response.body);
//           print(HttpHeaders.requestHeaders);
//           print("******************");
//           expect(isValidIpAddress(response.body), isTrue, reason: 'Response is not a valid IP address for test case $i');
//           await tester.tap(fab);
//           await Future.delayed(Duration(seconds: 1));
//           expect(find.text('1'), findsOneWidget);
//
//         });
//     }
//   });
// }
//

// import 'dart:io';
//
// import 'package:dio/adapter.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:dio/dio.dart';
// import 'package:hello_world/main.dart' as app;
// import 'package:flutter_system_proxy/flutter_system_proxy.dart';
//
//
//
//
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//
//   group('network logs flutter integration test', () {
//     for (int i = 1; i <= 5; i++) {
//       testWidgets('API call test for valid IP address $i', (tester) async {
//         app.main();
//         await tester.pumpAndSettle();
//
//         final String customHeader = 'test$i';
//         final String url = 'https://ipinfo.io/ip?$customHeader';
//
//         // Initialize Dio
//         var dio = Dio();
//         // Set up proxy settings using FlutterSystemProxy
//         var proxy = await FlutterSystemProxy.findProxyFromEnvironment(url);
//         (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//             (HttpClient client) {
//           client.findProxy = (uri) {
//             return proxy;
//           };
//           return client;
//         };
//
//         try {
//           // Make the GET request using Dio
//           final response = await dio.get(
//             url,
//             options: Options(
//               headers: {
//                 'Custom-Header': customHeader,
//               },
//             ),
//           );
//
//           final Finder fab = find.byTooltip('Increment');
//
//           // Function to validate IP address format
//           bool isValidIpAddress(String ip) {
//             final RegExp ipRegex = RegExp(
//               r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
//               r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
//             );
//             return ipRegex.hasMatch(ip);
//           }
//
//           // Validate the response status
//           expect(response.statusCode, 200);
//
//           // Log the response
//           print("******************");
//           print(response.statusCode);
//           print(response.data);
//           print(response.requestOptions.headers);
//           print("******************");
//
//           // Validate the IP address format
//           expect(isValidIpAddress(response.data.trim()), isTrue,
//               reason: 'Response is not a valid IP address for test case $i');
//
//           // Interaction with the app
//           await tester.tap(fab);
//           await Future.delayed(Duration(seconds: 1));
//           expect(find.text('1'), findsOneWidget);
//         } catch (e) {
//           print('Error occurred: $e');
//           fail('API call failed for test case $i');
//         }
//       });
//     }
//   });
// }


import 'dart:io';
import 'dart:typed_data';

import 'package:dio/adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:hello_world/main.dart' as app;
import 'package:flutter_system_proxy/flutter_system_proxy.dart';

// Create a custom adapter that resolves proxies based on URLs
class MyAdapter extends HttpClientAdapter {
  final DefaultHttpClientAdapter _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    var uri = options.uri;

    // Resolve the proxy using FlutterSystemProxy
    var proxy =
    await FlutterSystemProxy.findProxyFromEnvironment(uri.toString());

    _adapter.onHttpClientCreate = (HttpClient client) {
      client.findProxy = (uri) {
        return proxy;
      };
    };

    // Proceed with the request
    return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}

Dio getDio(){
  var dio = Dio();
  dio.httpClientAdapter = MyAdapter();
  return dio;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('network logs flutter integration test', () {
    for (int i = 1; i <= 5; i++) {
      testWidgets('API call test for valid IP address $i', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final String customHeader = 'test$i';
        final String url = 'https://ipinfo.io/ip?$customHeader';

        // Initialize Dio with MyAdapter
        var dio = getDio(); // Use the custom adapter

        try {
          // Make the GET request using Dio
          final response = await dio.get(
            url,
            options: Options(
              headers: {
                'Custom-Header': customHeader,
              },
            ),
          );

          final Finder fab = find.byTooltip('Increment');

          // Function to validate IP address format
          bool isValidIpAddress(String ip) {
            final RegExp ipRegex = RegExp(
              r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
              r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
            );
            return ipRegex.hasMatch(ip);
          }

          // Validate the response status
          expect(response.statusCode, 200);

          // Log the response
          print("******************");
          print(response.statusCode);
          print(response.data);
          print(response.requestOptions.headers);
          print("******************");

          // Validate the IP address format
          expect(isValidIpAddress(response.data.trim()), isTrue,
              reason: 'Response is not a valid IP address for test case $i');

          // Interaction with the app
          await tester.tap(fab);
          await Future.delayed(Duration(seconds: 1));
          expect(find.text('1'), findsOneWidget);
        } catch (e) {
          print('Error occurred: $e');
          fail('API call failed for test case $i');
        }
      });
    }
  });
}




