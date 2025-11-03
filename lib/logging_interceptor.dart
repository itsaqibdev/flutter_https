import 'package:http/http.dart' as http;
import 'interceptors.dart';

/// An interceptor that logs HTTP requests and responses.
class LoggingInterceptor extends Interceptor {
  final bool _logRequests;
  final bool _logResponses;
  final bool _logErrors;

  /// Creates a logging interceptor.
  ///
  /// [logRequests] whether to log outgoing requests.
  /// [logResponses] whether to log incoming responses.
  /// [logErrors] whether to log errors.
  LoggingInterceptor({
    bool logRequests = true,
    bool logResponses = true,
    bool logErrors = true,
  })  : _logRequests = logRequests,
        _logResponses = logResponses,
        _logErrors = logErrors;

  @override
  Future<void> onRequest(http.BaseRequest request) async {
    if (_logRequests) {
      print('--> ${request.method} ${request.url}');
      request.headers.forEach((key, value) {
        print('  $key: $value');
      });
      if (request is http.Request && request.body.isNotEmpty) {
        print('  Body: ${request.body}');
      }
      print('--> END ${request.method}');
    }
  }

  @override
  Future<void> onResponse(http.Response response) async {
    if (_logResponses) {
      print('<-- ${response.statusCode} ${response.request?.url ?? ''}');
      response.headers.forEach((key, value) {
        print('  $key: $value');
      });
      print('  Body: ${response.body}');
      print('<-- END HTTP');
    }
  }

  @override
  Future<void> onError(Object error) async {
    if (_logErrors) {
      print('<-- ERROR');
      print('  $error');
      print('<-- END ERROR');
    }
  }
}