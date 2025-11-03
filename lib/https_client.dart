import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'interceptors.dart';
import 'exception.dart';

/// An enhanced HTTP client with additional features like interceptors,
/// automatic retries, and simplified API.
class HTTPSClient {
  static final Map<String, String> _downloadedFiles = {};
  final http.Client _client;
  final List<Interceptor> _interceptors = [];

  /// Creates an HTTPS client with an optional underlying [http.Client].
  HTTPSClient({http.Client? client}) : _client = client ?? http.Client();

  /// Adds an interceptor to the client.
  void addInterceptor(Interceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Removes an interceptor from the client.
  void removeInterceptor(Interceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Makes a GET request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> get(
    Object url, {
    Map<String, String>? headers,
  }) async {
    final uri = _toUri(url);
    return _makeRequest('GET', uri, headers: headers);
  }

  /// Makes a POST request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> post(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = _toUri(url);
    return _makeRequest('POST', uri,
        headers: headers, body: body, encoding: encoding);
  }

  /// Makes a PUT request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> put(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = _toUri(url);
    return _makeRequest('PUT', uri,
        headers: headers, body: body, encoding: encoding);
  }

  /// Makes a DELETE request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> delete(
    Object url, {
    Map<String, String>? headers,
  }) async {
    final uri = _toUri(url);
    return _makeRequest('DELETE', uri, headers: headers);
  }

  /// Makes a PATCH request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  Future<http.Response> patch(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = _toUri(url);
    return _makeRequest('PATCH', uri,
        headers: headers, body: body, encoding: encoding);
  }

  /// Downloads a file from the specified [url] to a temporary location.
  /// The [url] can be either a String or a Uri object.
  /// 
  /// Returns the path to the downloaded file.
  Future<String> download(
    Object url,
    String fileName, {
    Map<String, String>? headers,
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    // Create a temporary file path
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/$fileName';
    
    final uri = _toUri(url);
    await _downloadToFile(uri, filePath, headers: headers, onProgress: onProgress);
    
    // Track the downloaded file
    HTTPSClient._downloadedFiles[fileName] = filePath;
    
    return filePath;
  }

  /// Downloads a file from the specified [url] to the [savePath].
  /// The [url] can be either a String or a Uri object.
  /// 
  /// Returns the number of bytes downloaded.
  Future<int> _downloadToFile(
    Uri url,
    String savePath, {
    Map<String, String>? headers,
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    // Create the request
    final request = http.Request('GET', url);
    
    // Apply headers
    if (headers != null) {
      request.headers.addAll(headers);
    }
    
    http.StreamedResponse response;
    try {
      // Execute pre-request interceptors
      for (var interceptor in _interceptors) {
        await interceptor.onRequest(request);
      }
      
      // Send the request
      response = await _client.send(request);
    } catch (e, stackTrace) {
      // Execute error interceptors
      for (var interceptor in _interceptors) {
        await interceptor.onError(e);
      }
      
      // Wrap and rethrow the error
      if (e is HTTPSException) {
        Error.throwWithStackTrace(e, stackTrace);
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to send request: ${e.toString()}',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    }
    
    // Get the total bytes
    final totalBytes = response.contentLength ?? 0;
    var bytesReceived = 0;
    
    // Create the file
    final file = File(savePath);
    await file.create(recursive: true);
    final sink = file.openWrite();
    
    try {
      // Listen to the response stream
      await response.stream.listen(
        (List<int> data) {
          bytesReceived += data.length;
          sink.add(data);
          
          // Report progress if callback is provided
          if (onProgress != null) {
            onProgress(bytesReceived, totalBytes);
          }
        },
        onError: (error) async {
          await sink.close();
          await file.delete();
          
          // Execute error interceptors
          for (var interceptor in _interceptors) {
            await interceptor.onError(error);
          }
          
          // Wrap and rethrow the error
          if (error is HTTPSException) {
            throw error;
          } else {
            throw HTTPSException(
              message: 'Error during download: ${error.toString()}',
              statusCode: response.statusCode,
              originalError: error,
            );
          }
        },
        onDone: () async {
          await sink.close();
          
          // Execute post-response interceptors
          final fakeResponse = http.Response('', response.statusCode,
              headers: response.headers,
              request: request);
          for (var interceptor in _interceptors) {
            await interceptor.onResponse(fakeResponse);
          }
          
          // Check for HTTP error status codes
          if (response.statusCode >= 400) {
            await file.delete();
            throw HTTPSException(
              message: 'HTTP request failed with status code: ${response.statusCode}',
              statusCode: response.statusCode,
            );
          }
        },
      ).asFuture<void>();
    } catch (e, stackTrace) {
      await sink.close();
      if (await file.exists()) {
        await file.delete();
      }
      
      // Execute error interceptors for non-stream errors
      if (e is! HTTPSException) {
        for (var interceptor in _interceptors) {
          await interceptor.onError(e);
        }
      }
      
      // Wrap and rethrow the error if it's not already an HTTPSException
      if (e is HTTPSException) {
        Error.throwWithStackTrace(e, stackTrace);
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Download failed: ${e.toString()}',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    }
    
    return bytesReceived;
  }

  /// Makes an HTTP request with the specified parameters.
  Future<http.Response> _makeRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    // Create the request
    var request = http.Request(method, url);
    
    // Apply headers
    if (headers != null) {
      request.headers.addAll(headers);
    }
    
    // Apply body
    if (body != null) {
      request.body = body is String ? body : jsonEncode(body);
    }
    
    // Apply encoding if provided
    if (encoding != null) {
      request.encoding = encoding;
    }
    
    http.StreamedResponse streamedResponse;
    try {
      // Execute pre-request interceptors
      for (var interceptor in _interceptors) {
        await interceptor.onRequest(request);
      }
      
      // Send the request
      streamedResponse = await _client.send(request);
    } catch (e, stackTrace) {
      // Execute error interceptors
      for (var interceptor in _interceptors) {
        await interceptor.onError(e);
      }
      
      // Wrap and rethrow the error
      if (e is HTTPSException) {
        Error.throwWithStackTrace(e, stackTrace);
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to send $method request to $url: ${e.toString()}',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    }
    
    // Convert to response
    http.Response response;
    try {
      response = await http.Response.fromStream(streamedResponse);
    } catch (e, stackTrace) {
      // Execute error interceptors
      for (var interceptor in _interceptors) {
        await interceptor.onError(e);
      }
      
      // Wrap and rethrow the error
      if (e is HTTPSException) {
        Error.throwWithStackTrace(e, stackTrace);
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to process response: ${e.toString()}',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    }
    
    // Check for HTTP error status codes
    if (response.statusCode >= 400) {
      final exception = HTTPSException(
        message: 'HTTP request failed with status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
      
      // Execute error interceptors
      for (var interceptor in _interceptors) {
        await interceptor.onError(exception);
      }
      
      throw exception;
    }
    
    // Execute post-response interceptors
    for (var interceptor in _interceptors) {
      await interceptor.onResponse(response);
    }
    
    return response;
  }

  /// Closes the client and frees up resources.
  void close() {
    _client.close();
  }

  /// Converts a String or Uri to a Uri object
  static Uri toUri(Object url) {
    if (url is String) {
      return Uri.parse(url);
    } else if (url is Uri) {
      return url;
    } else {
      throw ArgumentError('URL must be a String or Uri');
    }
  }

  /// Converts a String or Uri to a Uri object (private version)
  static Uri _toUri(Object url) {
    return toUri(url);
  }
}