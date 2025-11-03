import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_https/flutter_https.dart';

void main() {
  group('HTTPS String URL Tests', () {
    // These tests just check method signatures, not actual network calls
    test('Static methods accept string URLs', () {
      // This should not throw - just testing that the method signature accepts strings
      expect(() => https.get('https://example.com'), returnsNormally);
      expect(() => https.post('https://example.com'), returnsNormally);
      expect(() => https.put('https://example.com'), returnsNormally);
      expect(() => https.deleteRequest('https://example.com'), returnsNormally);
      expect(() => https.patch('https://example.com'), returnsNormally);
    });

    test('Instance methods accept string URLs', () {
      final client = HTTPSClient();
      
      // This should not throw - just testing that the method signature accepts strings
      expect(() => client.get('https://example.com'), returnsNormally);
      expect(() => client.post('https://example.com'), returnsNormally);
      expect(() => client.put('https://example.com'), returnsNormally);
      expect(() => client.delete('https://example.com'), returnsNormally);
      expect(() => client.patch('https://example.com'), returnsNormally);
      
      client.close();
    });

    test('RetryClient methods accept string URLs', () {
      final baseClient = HTTPSClient();
      final client = RetryClient(baseClient);
      
      // This should not throw - just testing that the method signature accepts strings
      expect(() => client.get('https://example.com'), returnsNormally);
      expect(() => client.post('https://example.com'), returnsNormally);
      expect(() => client.put('https://example.com'), returnsNormally);
      expect(() => client.delete('https://example.com'), returnsNormally);
      expect(() => client.patch('https://example.com'), returnsNormally);
      
      baseClient.close();
    });

    test('URL conversion works correctly', () {
      // Test with string URL
      expect(() => HTTPSClient.toUri('https://example.com'), returnsNormally);
      
      // Test with Uri object
      expect(() => HTTPSClient.toUri(Uri.parse('https://example.com')), returnsNormally);
      
      // Test with invalid type (should throw)
      expect(() => HTTPSClient.toUri(123), throwsA(isA<ArgumentError>()));
    });
  });

  group('HTTPS Download Tests', () {
    test('Static download method exists', () {
      // This should not throw - just testing that the method signature exists
      expect(
        () => https.download(
          'https://httpbin.org/json',
          'test.json',
        ),
        returnsNormally,
      );
    });

    test('Instance download method exists', () {
      final client = HTTPSClient();
      
      // This should not throw - just testing that the method signature exists
      expect(
        () => client.download(
          'https://httpbin.org/json',
          'test.json',
        ),
        returnsNormally,
      );
      
      client.close();
    });

    test('RetryClient download method exists', () {
      final baseClient = HTTPSClient();
      final client = RetryClient(baseClient);
      
      // This should not throw - just testing that the method signature exists
      expect(
        () => client.download(
          'https://httpbin.org/json',
          'test.json',
        ),
        returnsNormally,
      );
      
      baseClient.close();
    });
  });

  group('HTTPS Downloaded File Management Tests', () {
    setUp(() async {
      // Clean up any existing tracked files before each test
      await https.deleteAllDownloadedFiles();
    });
    
    tearDown(() async {
      // Clean up any tracked files after each test
      await https.deleteAllDownloadedFiles();
    });

    test('List downloaded files', () async {
      // Initially should be empty
      final files = https.listDownloadedFiles();
      expect(files.length, equals(0));
    });

    test('Get downloaded file returns null for non-existent file', () async {
      // Should return null for non-existent file
      final result = https.getDownloadedFile('non_existent.json');
      expect(result, isNull);
    });
  });

  group('HTTPS Exception Handling Tests', () {
    test('HTTPSException contains proper information', () {
      final exception = HTTPSException(
        message: 'Test error',
        statusCode: 404,
        originalError: Exception('Original error'),
      );
      
      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(404));
      expect(exception.originalError, isNotNull);
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('404'));
    });

    test('Invalid URL throws ArgumentError', () {
      expect(
        () => HTTPSClient.toUri(123),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}