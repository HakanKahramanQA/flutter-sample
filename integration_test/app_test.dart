// Basic Usage flutter_system_proxy.dart

import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:hello_world/main.dart' as app;
import 'package:flutter_system_proxy/flutter_system_proxy.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  group('HTTP network logs flutter integration test', () {
    for (int i = 1; i <= 10; i++) {
      testWidgets('API call test for valid IP address $i', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final String customHeader = 'test$i';
        final String url = 'https://ipinfo.io/ip?$customHeader';

        // Initialize Dio
        Dio dio = Dio();

        // Set up proxy settings using FlutterSystemProxy
        var proxy = await FlutterSystemProxy.findProxyFromEnvironment(url);
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
            (HttpClient client) {
          client.findProxy = (uri) {
            return proxy;
          };
          return client;
        };

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
          await Future.delayed(const Duration(seconds: 1));
          expect(find.text('1'), findsOneWidget);
        } catch (e) {
          print('Error occurred: $e');
          fail('API call failed for test case $i');
        }
      });
    }
  });
}



