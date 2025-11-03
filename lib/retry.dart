import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'https_client.dart';
import 'exception.dart';

/// A client that automatically retries failed requests.
class RetryClient {
  final HTTPSClient _client;
  final int _maxRetries;
  final Duration _initialDelay;
  final double _delayMultiplier;

  /// Creates a retry client.
  ///
  /// [maxRetries] is the maximum number of retries (default: 3).
  /// [initialDelay] is the initial delay before the first retry (default: 500ms).
  /// [delayMultiplier] is the multiplier for the delay after each retry (default: 1.5).
  RetryClient(
    this._client, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
    double delayMultiplier = 1.5,
  })  : _maxRetries = maxRetries,
        _initialDelay = initialDelay,
        _delayMultiplier = delayMultiplier;

  /// Makes a GET request with automatic retries.
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> get(
    Object url, {
    Map<String, String>? headers,
  }) async {
    return _retry(() => _client.get(url, headers: headers));
  }

  /// Makes a POST request with automatic retries.
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> post(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _retry(() => _client.post(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        ));
  }

  /// Makes a PUT request with automatic retries.
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> put(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _retry(() => _client.put(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        ));
  }

  /// Makes a DELETE request with automatic retries.
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> delete(
    Object url, {
    Map<String, String>? headers,
  }) async {
    return _retry(() => _client.delete(url, headers: headers));
  }

  /// Makes a PATCH request with automatic retries.
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> patch(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _retry(() => _client.patch(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        ));
  }

  /// Downloads a file from the specified [url] to a temporary location with automatic retries.
  /// The [url] can be either a String or a Uri object.
  /// 
  /// Returns the path to the downloaded file.
  Future<String> download(
    Object url,
    String fileName, {
    Map<String, String>? headers,
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    return _retry(() => _client.download(
          url,
          fileName,
          headers: headers,
          onProgress: onProgress,
        ));
  }

  /// Executes the request with retry logic.
  Future<T> _retry<T>(Future<T> Function() request) async {
    int attempt = 0;
    Duration delay = _initialDelay;

    while (true) {
      try {
        return await request();
      } catch (error, stackTrace) {
        attempt++;
        
        if (attempt > _maxRetries) {
          // If it's already an HTTPSException, rethrow it
          if (error is HTTPSException) {
            Error.throwWithStackTrace(error, stackTrace);
          } else {
            // Wrap other errors in HTTPSException
            Error.throwWithStackTrace(
              HTTPSException(
                message: 'Request failed after $_maxRetries retries: ${error.toString()}',
                originalError: error,
              ),
              stackTrace,
            );
          }
        }

        // Check if we should retry based on the error
        if (!_shouldRetry(error)) {
          // If it's already an HTTPSException, rethrow it
          if (error is HTTPSException) {
            Error.throwWithStackTrace(error, stackTrace);
          } else {
            // Wrap other errors in HTTPSException
            Error.throwWithStackTrace(
              HTTPSException(
                message: 'Request failed and is not retryable: ${error.toString()}',
                originalError: error,
              ),
              stackTrace,
            );
          }
        }

        // Wait before retrying
        await Future.delayed(delay);
        delay = Duration(
            milliseconds: (delay.inMilliseconds * _delayMultiplier).round());
      }
    }
  }

  /// Determines if a request should be retried based on the error.
  bool _shouldRetry(Object error) {
    // Retry on network errors or server errors (5xx)
    if (error is HTTPSException) {
      // Retry on network connectivity issues or server errors (5xx)
      if (error.statusCode != null) {
        return error.statusCode! >= 500 && error.statusCode! < 600;
      }
      // Retry on network connectivity issues
      return error.message.contains('Failed to send') || 
             error.message.contains('Connection') ||
             error.message.contains('Network');
    }
    // Retry on network connectivity issues
    return error.toString().contains('Failed to send') || 
           error.toString().contains('Connection') ||
           error.toString().contains('Network');
  }
}