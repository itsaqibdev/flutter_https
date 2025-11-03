import 'package:http/http.dart' as http;

/// Abstract class for intercepting HTTP requests and responses.
abstract class Interceptor {
  /// Called before a request is sent.
  Future<void> onRequest(http.BaseRequest request) async {}

  /// Called after a response is received.
  Future<void> onResponse(http.Response response) async {}

  /// Called when an error occurs.
  Future<void> onError(Object error) async {}
}