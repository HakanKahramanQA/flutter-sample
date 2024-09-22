import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:hello_world/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('network logs flutter integration test', () {
    for (int i = 1; i <= 10; i++) {
    testWidgets('API call test for valid IP address $i',
            (tester) async {
          app.main();
          await tester.pumpAndSettle();

          final String customHeader = 'test$i';
          final String url = 'https://ipinfo.io/ip?$customHeader';
          final response = await http.get(
              Uri.parse("https://ipinfo.io/ip"),
            headers: {
              'Custom-Header': customHeader,
            },
          );
          final Finder fab = find.byTooltip('Increment');
          bool isValidIpAddress(String ip) {
            final RegExp ipRegex = RegExp(
              r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
              r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
            );
            return ipRegex.hasMatch(ip);
          }
          expect(response.statusCode, 200);
          expect(isValidIpAddress(response.body), isTrue, reason: 'Response is not a valid IP address for test case $i');
          await tester.tap(fab);
          await Future.delayed(Duration(seconds: 1));
          expect(find.text('1'), findsOneWidget);

        });
    }
  });
}

