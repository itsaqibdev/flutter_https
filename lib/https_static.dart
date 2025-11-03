import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'interceptors.dart';
import 'https_client.dart';
import 'exception.dart';

/// Static HTTP methods for easy access
class https {
  static final HTTPSClient _client = HTTPSClient();
  static final Map<String, String> _downloadedFiles = {};
  static final Map<String, String> _tempFiles = {};

  /// Makes a GET request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  static Future<http.Response> get(
    Object url, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _toUri(url);
      return _client.get(uri, headers: headers);
    } catch (e) {
      if (e is HTTPSException) {
        rethrow;
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to make GET request to $url: ${e.toString()}',
            originalError: e,
          ),
          StackTrace.current,
        );
      }
    }
  }

  /// Makes a POST request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  static Future<http.Response> post(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final uri = _toUri(url);
      return _client.post(uri, headers: headers, body: body, encoding: encoding);
    } catch (e) {
      if (e is HTTPSException) {
        rethrow;
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to make POST request to $url: ${e.toString()}',
            originalError: e,
          ),
          StackTrace.current,
        );
      }
    }
  }

  /// Makes a PUT request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  static Future<http.Response> put(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final uri = _toUri(url);
      return _client.put(uri, headers: headers, body: body, encoding: encoding);
    } catch (e) {
      if (e is HTTPSException) {
        rethrow;
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to make PUT request to $url: ${e.toString()}',
            originalError: e,
          ),
          StackTrace.current,
        );
      }
    }
  }

  /// Makes a DELETE request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  static Future<http.Response> deleteRequest(
    Object url, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _toUri(url);
      return _client.delete(uri, headers: headers);
    } catch (e) {
      if (e is HTTPSException) {
        rethrow;
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to make DELETE request to $url: ${e.toString()}',
            originalError: e,
          ),
          StackTrace.current,
        );
      }
    }
  }

  /// Makes a PATCH request to the specified [url].
  /// The [url] can be either a String or a Uri object.
  static Future<http.Response> patch(
    Object url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final uri = _toUri(url);
      return _client.patch(uri, headers: headers, body: body, encoding: encoding);
    } catch (e) {
      if (e is HTTPSException) {
        rethrow;
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to make PATCH request to $url: ${e.toString()}',
            originalError: e,
          ),
          StackTrace.current,
        );
      }
    }
  }

  /// Downloads a file from the specified [url] to a temporary location.
  /// The [url] can be either a String or a Uri object.
  /// 
  /// Returns the path to the downloaded file.
  static Future<String> download(
    Object url,
    String fileName, {
    Map<String, String>? headers,
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    try {
      // Create a temporary file path
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/$fileName';
      
      final uri = _toUri(url);
      await _client.download(uri, fileName, headers: headers, onProgress: onProgress);
      
      // Track the downloaded file
      _downloadedFiles[fileName] = filePath;
      
      return filePath;
    } catch (e) {
      if (e is HTTPSException) {
        rethrow;
      } else {
        Error.throwWithStackTrace(
          HTTPSException(
            message: 'Failed to download file from $url: ${e.toString()}',
            originalError: e,
          ),
          StackTrace.current,
        );
      }
    }
  }

  /// Creates a temporary file with the specified [name] and [content].
  /// The file will be stored in the system's temporary directory with proper permissions.
  /// 
  /// Returns the full path to the created temporary file.
  static Future<String> createTempFile(String name, [String content = '']) async {
    try {
      final tempDir = await Directory.systemTemp.createTemp('https_');
      final filePath = '${tempDir.path}/$name';
      
      // Create the file with proper permissions (readable and writable)
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(content);
      
      // Track the temporary file
      _tempFiles[name] = filePath;
      
      return filePath;
    } catch (e) {
      Error.throwWithStackTrace(
        HTTPSException(
          message: 'Failed to create temporary file $name: ${e.toString()}',
          originalError: e,
        ),
        StackTrace.current,
      );
    }
  }

  /// Deletes a temporary file with the specified [name].
  /// 
  /// Returns true if the file was deleted, false if it didn't exist.
  static Future<bool> deleteTempFile(String name) async {
    try {
      if (_tempFiles.containsKey(name)) {
        final filePath = _tempFiles[name]!;
        final file = File(filePath);
        
        if (await file.exists()) {
          await file.delete();
          _tempFiles.remove(name);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      Error.throwWithStackTrace(
        HTTPSException(
          message: 'Failed to delete temporary file $name: ${e.toString()}',
          originalError: e,
        ),
        StackTrace.current,
      );
    }
  }

  /// Deletes all temporary files created by this package.
  /// 
  /// Returns the number of files deleted.
  static Future<int> deleteAllTempFiles() async {
    try {
      int count = 0;
      
      // Create a copy of the keys to avoid concurrent modification
      final names = List<String>.from(_tempFiles.keys);
      
      for (final name in names) {
        final result = await deleteTempFile(name);
        if (result) {
          count++;
        }
      }
      
      return count;
    } catch (e) {
      Error.throwWithStackTrace(
        HTTPSException(
          message: 'Failed to delete all temporary files: ${e.toString()}',
          originalError: e,
        ),
        StackTrace.current,
      );
    }
  }

  /// Gets the path of a temporary file with the specified [name].
  /// 
  /// Returns the file path or null if the file doesn't exist.
  static String? getTempFilePath(String name) {
    return _tempFiles[name];
  }

  /// Lists all temporary files created by this package.
  /// 
  /// Returns a map of file names to their paths.
  static Map<String, String> listTempFiles() {
    return Map<String, String>.from(_tempFiles);
  }

  /// Gets the path of a downloaded file with the specified [fileName].
  /// 
  /// Returns the file path or null if the file doesn't exist.
  static String? getDownloadedFile(String fileName) {
    return _downloadedFiles[fileName];
  }

  /// Lists all downloaded files.
  /// 
  /// Returns a map of file names to their paths.
  static Map<String, String> listDownloadedFiles() {
    return Map<String, String>.from(_downloadedFiles);
  }

  /// Deletes a downloaded file with the specified [fileName].
  /// 
  /// Returns true if the file was deleted, false if it didn't exist.
  static Future<bool> deleteDownloadedFile(String fileName) async {
    try {
      if (_downloadedFiles.containsKey(fileName)) {
        final filePath = _downloadedFiles[fileName]!;
        final file = File(filePath);
        
        if (await file.exists()) {
          await file.delete();
          _downloadedFiles.remove(fileName);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      Error.throwWithStackTrace(
        HTTPSException(
          message: 'Failed to delete downloaded file $fileName: ${e.toString()}',
          originalError: e,
        ),
        StackTrace.current,
      );
    }
  }

  /// Deletes all downloaded files.
  /// 
  /// Returns the number of files deleted.
  static Future<int> deleteAllDownloadedFiles() async {
    try {
      int count = 0;
      
      // Create a copy of the keys to avoid concurrent modification
      final names = List<String>.from(_downloadedFiles.keys);
      
      for (final name in names) {
        final result = await deleteDownloadedFile(name);
        if (result) {
          count++;
        }
      }
      
      return count;
    } catch (e) {
      Error.throwWithStackTrace(
        HTTPSException(
          message: 'Failed to delete all downloaded files: ${e.toString()}',
          originalError: e,
        ),
        StackTrace.current,
      );
    }
  }

  /// Adds an interceptor to the client.
  static void addInterceptor(Interceptor interceptor) {
    _client.addInterceptor(interceptor);
  }

  /// Removes an interceptor from the client.
  static void removeInterceptor(Interceptor interceptor) {
    _client.removeInterceptor(interceptor);
  }

  /// Converts a String or Uri to a Uri object
  static Uri _toUri(Object url) {
    if (url is String) {
      return Uri.parse(url);
    } else if (url is Uri) {
      return url;
    } else {
      throw ArgumentError('URL must be a String or Uri');
    }
  }
}