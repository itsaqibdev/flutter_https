import 'package:http/http.dart' as http;
import 'interceptors.dart';

/// An interceptor that adds common headers to all requests
class HeaderInterceptor extends Interceptor {
  final Map<String, String> _headers;

  /// Creates a header interceptor with the specified headers
  HeaderInterceptor(Map<String, String> headers) : _headers = Map.unmodifiable(headers);

  @override
  Future<void> onRequest(http.BaseRequest request) async {
    _headers.forEach((key, value) {
      request.headers[key] = value;
    });
  }
}