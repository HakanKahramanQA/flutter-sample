// Basic Usage flutter_system_proxy.dart

import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:hello_world/main.dart' as app;


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
  group('Integration tests', () {
    for (int i = 1; i <= 3; i++) {
      testWidgets('Click GPS button and verify the coordinates are generated $i', (
          WidgetTester tester) async {
        // Launch the app
        app.main();
        await tester.pumpAndSettle();

        // Find the GPS button by its tooltip
        final Finder gpsButton = find.byTooltip('GPS');

        // Tap the GPS button
        await tester.tap(gpsButton);
        await tester.pumpAndSettle();

        // Add a delay to ensure the location is fetched
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Verify the location text is updated
        expect(find.textContaining('Lat:'), findsOneWidget);
        expect(find.textContaining('Lon:'), findsOneWidget);
        await Future.delayed(const Duration(seconds: 5));
      });
    }

  });
}



