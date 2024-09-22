import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:hello_world/main.dart' as app;

Future<String> executeGetRequestWithHeaders(String url, String customHeader) async {
  // Launch the app activity
  app.main();
  await Future.delayed(Duration(seconds: 2)); // Wait for the app to launch

  // Handle any pop-up dialog (replace with actual dialog handling if needed)
  try {
    // Add your dialog dismissal code here, if necessary
    await Future.delayed(Duration(seconds: 2)); // Wait for the dialog to dismiss
  } catch (e) {
    print("No pop-up found, continuing with test.");
  }

  // Make the HTTP GET request with headers
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Custom-Header': customHeader,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Unexpected response code: ${response.statusCode}');
  }

  return response.body; // Return the response body as a string
}

bool isValidIpAddress(String ip) {
  final RegExp ipRegex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
    r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
  return ipRegex.hasMatch(ip);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test 1', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');

      // Emulate a tap on the floating action button multiple times.
      for (int i = 0; i < 7; i++) {
        await tester.tap(fab);
        await Future.delayed(Duration(seconds: 2));
      }

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments correctly.
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('tap twice on the floating action button, verify counter', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');

      // Emulate a tap on the floating action button twice.
      await tester.tap(fab);
      await Future.delayed(Duration(seconds: 2));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify the counter increments by 2.
      expect(find.text('2'), findsOneWidget);
    });
    for (int i = 1; i <= 200; i++) {
      test('API call test for valid IP address $i', () async {
        final String customHeader = 'test$i';
        final String url = 'https://ipinfo.io/ip?$customHeader';
        final String response =
            await executeGetRequestWithHeaders(url, customHeader);

        // Assert the response is a valid IP address
        expect(isValidIpAddress(response), isTrue,
            reason: 'Response is not a valid IP address for test case $i');
      });
    }
  });
}
