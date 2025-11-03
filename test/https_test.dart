import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_https/flutter_https.dart';

void main() {
  group('HTTPS Client Tests', () {
    test('HTTPS client can be instantiated', () {
      final client = HTTPSClient();
      expect(client, isNotNull);
      client.close();
    });

    test('Interceptor can be added and removed', () {
      final client = HTTPSClient();
      final interceptor = LoggingInterceptor();
      
      client.addInterceptor(interceptor);
      // The client should now have one interceptor
      // Note: We can't directly test the private _interceptors list
      
      client.removeInterceptor(interceptor);
      // The client should now have zero interceptors
      
      client.close();
    });
  });
}