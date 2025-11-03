import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_https/flutter_https.dart';

void main() {
  group('HTTPS Static Methods Tests', () {
    test('HTTPS static class can be used', () {
      // Just testing that the class exists and can be used
      expect(https, isNotNull);
    });

    test('Interceptor can be added to static client', () {
      final interceptor = LoggingInterceptor();
      
      // This should not throw
      https.addInterceptor(interceptor);
      https.removeInterceptor(interceptor);
    });
  });
}