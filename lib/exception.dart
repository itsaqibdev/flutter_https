/// Custom exception class for HTTPS package errors
class HTTPSException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalError;
  final StackTrace? stackTrace;

  HTTPSException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('HTTPSException: $message');
    if (statusCode != null) {
      buffer.write(' (Status Code: $statusCode)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal Error: $originalError');
    }
    return buffer.toString();
  }
}