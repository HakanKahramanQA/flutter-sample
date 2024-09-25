import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
import 'package:flutter/foundation.dart'; // Add this for debugPrint
// import 'package:flutter_system_proxy/flutter_system_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:hello_world/main.dart' as app;
import 'package:pretty_http_logger/pretty_http_logger.dart';
// import 'package:http_middleware/http_middleware.dart';
// import 'package:http_logger/http_logger.dart';


// class LoggingInterceptor implements InterceptorContract {
//   @override
//   Future<RequestData> interceptRequest({required RequestData data}) async {
//     debugPrint("***** Request Interceptor *****");
//     debugPrint("Request to: ${data.url}");
//     debugPrint("Headers: ${data.headers}");
//     debugPrint("Body: ${data.body}");
//     debugPrint("******************************");
//     return data;
//   }
//
//   @override
//   Future<ResponseData> interceptResponse({required ResponseData data}) async {
//     debugPrint("***** Response Interceptor *****");
//     debugPrint("Response status: ${data.statusCode}");
//     debugPrint("Response body: ${data.body}");
//     debugPrint("*******************************");
//     return data;
//   }
// }

// import 'package:flutter_test/flutter_test.dart';
// import 'package:http_with_middleware/http_with_middleware.dart';
// import 'package:http_with_middleware/middleware.dart';
// import 'package:pretty_http_logger/pretty_http_logger.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Network logs Flutter integration test', () {
    for (int i = 1; i <=5; i++) {
      testWidgets('API call test for valid IP address $i', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final String customHeader = 'test$i';
        final String url = 'https://ipinfo.io/ip?$customHeader';

        // Set up HTTP client with logging middleware
        HttpWithMiddleware httpClient = HttpWithMiddleware.build(middlewares: [
          HttpLogger(logLevel: LogLevel.BODY),
        ]);

        try {
          // Perform the GET request
          var response = await httpClient.get(
            Uri.parse(url),
            headers: {
              'Custom-Header': customHeader,
            },
          );

          // Validate the response status
          expect(response.statusCode, 200);

          // Read response as plain text
          final String ipAddress = response.body.trim(); // Trim any whitespace
          print('Response Body: $ipAddress'); // Log the response body

          // Validate the IP address format
          expect(isValidIpAddress(ipAddress), isTrue, reason: 'Response is not a valid IP address for test case $i');

          // Interaction with the app, such as tapping a button
          final Finder fab = find.byTooltip('Increment');
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

// Function to validate IP address format
bool isValidIpAddress(String ip) {
  final RegExp ipRegex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
    r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
  final isValid = ipRegex.hasMatch(ip);
  if (!isValid) {
    print('Invalid IP Address: $ip');
  }
  return isValid;
}


    // testWidgets('http', (WidgetTester tester) async {
    //    await tester.runAsync(() async {
    //      final HttpClient client = HttpClient();
    //      final HttpClientRequest request =
    //          await client.getUrl(Uri.parse('https://ipinfo.io/ip'));
    //     final HttpClientResponse response = await request.close();
    //     print(response.statusCode);
    //     print(response);
    //   });
    // });
    //
    // testWidgets('http2', (WidgetTester tester) async {
    //   Dio dio = Dio();
    //   setUpAll(() async {
    //     HttpOverrides.global = null;
    //     var url = "https://www.browserstack.com/";
    //     var proxy = await
    //
    //     FlutterSystemProxy.findProxyFromEnvironment(url);
    //     (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //         (HttpClient client) {
    //       client.findProxy = (uri) {
    //         return proxy;
    //       };
    //       return null;
    //     };
    //   });
    // });

//   });
// }

// import 'package:dio/io.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_system_proxy/flutter_system_proxy.dart';
// import 'dart:io';
//
// import 'package:pretty_http_logger/pretty_http_logger.dart';
//
// void main() {
//   Dio dio = Dio();
//
//   setUpAll(() async {
//     HttpOverrides.global = null;
//
//     var url = "https://www.browserstack.com/";
//     var proxy = await FlutterSystemProxy.findProxyFromEnvironment(url);
//
//     dio.httpClientAdapter = IOHttpClientAdapter(
//       createHttpClient: () {
//         HttpClient client = HttpClient();
//         client.findProxy = (uri) {
//           return proxy;
//         };
//         return client;
//       },
//     );
//   });
//
//   testWidgets('http2', (WidgetTester tester) async {
//     // Perform the Dio HTTP request
//     var response = await dio.get('https://www.browserstack.com/');
//     expect(response.statusCode, 200);
//     print(response.data);
//
//     // Add your widget interaction tests here
//     // Example: await tester.pumpWidget(MyApp());
//     // await tester.tap(find.text('SomeText'));
//     // await tester.pump();
//   });
//
//   testWidgets('http3', (WidgetTester tester) async {
//     // Perform the Dio HTTP request
//
//
//     HttpWithMiddleware httpClient = HttpWithMiddleware.build(middlewares: [
//       HttpLogger(logLevel: LogLevel.BODY),
//     ]);
//     final String url = 'https://ipinfo.io/ip?test1';
//     var response = await httpClient.get(Uri.parse(url));
//     // var response = await dio.get('https://www.browserstack.com/');
//     expect(response.statusCode, 200);
//     // print(response.body);
//     // Add your widget interaction tests here
//     // Example: await tester.pumpWidget(MyApp());
//     // await tester.tap(find.text('SomeText'));
//     // await tester.pump();
//   });
//
// }





