# Flutter HTTPS

[![Pub](https://img.shields.io/pub/v/flutter_https.svg)](https://pub.dev/packages/flutter_https)
[![License](https://img.shields.io/github/license/itsaqibdev/flutter_https)](https://github.com/itsaqibdev/flutter_https/blob/main/LICENSE)

A powerful and easy-to-use HTTP client for Dart and Flutter.
It includes advanced features like interceptors, retry handling, logging, file downloading, and temporary file management — all wrapped in a clean and simple API.

## 🌟 Features

- **Simple API** – Easy to use, beginner-friendly network calls
- **Interceptors** – Customize or inspect requests, responses, and errors
- **Retry System** – Automatic retries with optional delay/backoff
- **Logging** – Built-in request and response logs for debugging
- **Header Control** – Add common headers automatically
- **Direct URL Support** – Use plain string URLs without extra parsing
- **File Downloading** – Download files with real-time progress updates
- **Downloaded File Management** – List, access, and delete downloaded files
- **Temporary Files** – Create and manage temp files easily
- **Strong Error Handling** – Clear custom exceptions with detailed info

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_https: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:flutter_https/flutter_https.dart';

void main() async {
  // Simple GET request
  final response = await https.get('https://jsonplaceholder.typicode.com/posts/1');
  print('Response: ${response.body}');
}
```

## 📋 Feature Documentation

### 1. HTTP Requests

Make HTTP requests with simplified URL handling.

#### Basic Requests

```dart
import 'package:flutter_https/flutter_https.dart';

// GET request
final response = await https.get('https://api.example.com/users');

// POST request
final postResponse = await https.post(
  'https://api.example.com/users',
  body: {'name': 'John', 'email': 'john@example.com'},
);

// PUT request
final putResponse = await https.put(
  'https://api.example.com/users/1',
  body: {'name': 'John Doe', 'email': 'john.doe@example.com'},
);

// DELETE request
final deleteResponse = await https.deleteRequest('https://api.example.com/users/1');

// PATCH request
final patchResponse = await https.patch(
  'https://api.example.com/users/1',
  body: {'name': 'John Smith'},
);
```

#### With Headers

```dart
import 'package:flutter_https/flutter_https.dart';

final response = await https.get(
  'https://api.example.com/users',
  headers: {
    'Authorization': 'Bearer your-token',
    'Content-Type': 'application/json',
  },
);
```

#### Usage Scenarios
- ✅ Online: API calls to RESTful services
- ✅ Offline: Will fail gracefully (handle with retry mechanism)
- 📱 Mobile apps, web apps, desktop apps

### 2. File Download

Download files with progress reporting to temporary locations.

```dart
import 'package:flutter_https/flutter_https.dart';

// Simple download
final filePath = await https.download('https://example.com/file.zip', 'my_file.zip');

// Download with progress
final filePath = await https.download(
  'https://example.com/largefile.zip',
  'large_file.zip',
  onProgress: (received, total) {
    if (total > 0) {
      final progress = (received / total * 100).toStringAsFixed(2);
      print('Download progress: $progress% ($received/$total bytes)');
    } else {
      print('Downloaded $received bytes');
    }
  },
);

print('File downloaded to: $filePath');
```

#### Usage Scenarios
- ✅ Online: Downloading images, documents, assets
- ❌ Offline: Will fail (no internet connection)
- 📱 Mobile apps (downloading app content, images, etc.)
- 🌐 Web apps (downloading resources)
- 💻 Desktop apps (downloading updates, assets)

### 3. Downloaded File Management

Manage downloaded files with ease.

```dart
import 'package:flutter_https/flutter_https.dart';

// Download files
await https.download('https://example.com/file1.zip', 'file1.zip');
await https.download('https://example.com/file2.zip', 'file2.zip');

// List all downloaded files
final downloadedFiles = https.listDownloadedFiles();
print('Downloaded files:');
downloadedFiles.forEach((name, path) {
  print('  $name: $path');
});

// Get a specific downloaded file
final filePath = https.getDownloadedFile('file1.zip');
if (filePath != null) {
  print('file1.zip is at: $filePath');
}

// Delete a specific downloaded file
final deleted = await https.deleteDownloadedFile('file1.zip');
print('Deleted file1.zip: $deleted');

// Delete all downloaded files
final count = await https.deleteAllDownloadedFiles();
print('Deleted $count downloaded files');
```

#### Usage Scenarios
- ✅ Online: Managing downloaded content
- ✅ Offline: Managing previously downloaded content
- 📱 Mobile apps (managing offline content, cache)
- 🌐 Web apps (managing downloaded resources)
- 💻 Desktop apps (managing local assets)

### 4. Temporary File Management

Create and manage temporary files.

```dart
import 'package:flutter_https/flutter_https.dart';

// Create temporary files
final configPath = await https.createTempFile('config.txt', 'api_key=12345');
final dataPath = await https.createTempFile('data.json', '{"user": "john"}');

// List all temporary files
final tempFiles = https.listTempFiles();
print('Temporary files:');
tempFiles.forEach((name, path) {
  print('  $name: $path');
});

// Get a specific temporary file
final tempFilePath = https.getTempFilePath('config.txt');
if (tempFilePath != null) {
  print('config.txt is at: $tempFilePath');
}

// Delete a specific temporary file
final deleted = await https.deleteTempFile('config.txt');
print('Deleted config.txt: $deleted');

// Delete all temporary files
final count = await https.deleteAllTempFiles();
print('Deleted $count temporary files');
```

#### Usage Scenarios
- ✅ Online: Storing temporary data during network operations
- ✅ Offline: Storing temporary app data
- 📱 Mobile apps (temporary cache, session data)
- 🌐 Web apps (temporary storage)
- 💻 Desktop apps (temporary files, logs)

### 5. Interceptors

Add interceptors to process requests, responses, and errors.

#### Built-in Interceptors

```dart
import 'package:flutter_https/flutter_https.dart';

// Logging interceptor
https.addInterceptor(LoggingInterceptor());

// Header interceptor
https.addInterceptor(HeaderInterceptor({
  'Authorization': 'Bearer your-token',
  'Content-Type': 'application/json',
  'User-Agent': 'MyApp/1.0',
}));

// Make a request (interceptors will be applied automatically)
final response = await https.get('https://api.example.com/users');
```

#### Custom Interceptor

```dart
import 'package:flutter_https/flutter_https.dart';
import 'package:http/http.dart' as http;

class AuthInterceptor extends Interceptor {
  final String token;

  AuthInterceptor(this.token);

  @override
  Future<void> onRequest(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $token';
    print('Added authorization header to request');
  }

  @override
  Future<void> onResponse(http.Response response) async {
    print('Received response with status: ${response.statusCode}');
  }

  @override
  Future<void> onError(Object error) async {
    print('Request failed with error: $error');
  }
}

// Use custom interceptor
https.addInterceptor(AuthInterceptor('your-token'));
```

#### Usage Scenarios
- ✅ Online: Adding authentication headers, logging
- ✅ Offline: Error handling
- 📱 Mobile apps (auth, logging, error handling)
- 🌐 Web apps (auth, logging)
- 💻 Desktop apps (auth, logging, monitoring)

### 6. Retry Mechanism

Automatically retry failed requests with exponential backoff.

```dart
import 'package:flutter_https/flutter_https.dart';

// Using retry with static client
final baseClient = HTTPSClient();
final client = RetryClient(
  baseClient,
  maxRetries: 3,
  initialDelay: Duration(milliseconds: 500),
  delayMultiplier: 2.0,
);

// This will automatically retry up to 3 times on failure
final response = await client.get('https://api.example.com/users');

// Don't forget to close the base client
baseClient.close();
```

#### Usage Scenarios
- ✅ Online: Handling intermittent network issues
- ❌ Offline: Will eventually fail after retries
- 📱 Mobile apps (unstable connections)
- 🌐 Web apps (network resilience)
- 💻 Desktop apps (network resilience)

### 7. Instance-based Clients

Create multiple clients with different configurations.

```dart
import 'package:flutter_https/flutter_https.dart';

// Create clients with different configurations
final apiClient = HTTPSClient();
apiClient.addInterceptor(HeaderInterceptor({
  'Authorization': 'Bearer api-token',
  'Content-Type': 'application/json',
}));

final publicClient = HTTPSClient();
publicClient.addInterceptor(LoggingInterceptor());

// Use different clients for different purposes
final apiResponse = await apiClient.get('https://api.example.com/users');
final publicResponse = await publicClient.get('https://public.example.com/data');

// Don't forget to close clients
apiClient.close();
publicClient.close();
```

#### Usage Scenarios
- ✅ Online: Different API endpoints with different auth
- ✅ Offline: Different local configurations
- 📱 Mobile apps (multiple API services)
- 🌐 Web apps (different backend services)
- 💻 Desktop apps (multiple services)

### 8. Error Handling

Comprehensive error handling with custom exceptions that provide detailed information.

#### Basic Error Handling

```dart
import 'package:flutter_https/flutter_https.dart';

try {
  final response = await https.get('https://api.example.com/users');
  print('Status: ${response.statusCode}');
} on HTTPSException catch (e) {
  // Handle HTTPS-specific exceptions
  print('HTTPS Error: ${e.message}');
  if (e.statusCode != null) {
    print('Status Code: ${e.statusCode}');
  }
  if (e.originalError != null) {
    print('Original Error: ${e.originalError}');
  }
} catch (e) {
  // Handle other exceptions
  print('Unexpected Error: $e');
}
```

#### Advanced Error Handling

```dart
import 'package:flutter_https/flutter_https.dart';

try {
  final response = await https.get('https://api.example.com/users');
  
  // Handle different status codes
  if (response.statusCode == 200) {
    print('Success: ${response.body}');
  } else if (response.statusCode == 404) {
    print('Resource not found');
  } else if (response.statusCode >= 500) {
    print('Server error, might want to retry');
  }
} on HTTPSException catch (e) {
  // Handle different types of HTTPS errors
  if (e.statusCode != null) {
    switch (e.statusCode) {
      case 401:
        print('Unauthorized - check your credentials');
        break;
      case 403:
        print('Forbidden - you do not have permission');
        break;
      case 404:
        print('Not found - the resource does not exist');
        break;
      case 500:
      case 502:
      case 503:
        print('Server error - might be temporary');
        break;
      default:
        print('HTTP Error: ${e.message}');
    }
  } else {
    // Network or other errors
    print('Network Error: ${e.message}');
  }
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

#### Custom Error Handling with Retry Logic

```dart
import 'package:flutter_https/flutter_https.dart';

Future<http.Response> getDataWithRetry(String url, {int maxRetries = 3}) async {
  final baseClient = HTTPSClient();
  final client = RetryClient(baseClient, maxRetries: maxRetries);
  
  try {
    return await client.get(url);
  } on HTTPSException catch (e) {
    // Custom handling based on error type
    if (e.statusCode != null && e.statusCode! >= 500) {
      print('Server error (${e.statusCode}), consider retrying');
    } else if (e.message.contains('Failed to send')) {
      print('Network connectivity issue, check connection');
    }
    rethrow;
  } finally {
    baseClient.close();
  }
}

// Usage
try {
  final response = await getDataWithRetry('https://api.example.com/users');
  print('Data: ${response.body}');
} on HTTPSException catch (e) {
  print('Failed to get data after retries: ${e.message}');
}
```

#### Error Handling Scenarios
- ✅ Online: Network errors, HTTP status errors
- ✅ Offline: Connection failures
- 📱 Mobile apps (network issues, server errors)
- 🌐 Web apps (HTTP errors, CORS issues)
- 💻 Desktop apps (network errors, file system errors)

## 🛠️ Usage Scenarios Summary

| Feature | Online | Offline | Mobile | Web | Desktop |
|---------|--------|---------|--------|-----|---------|
| HTTP Requests | ✅ | ❌ | ✅ | ✅ | ✅ |
| File Download | ✅ | ❌ | ✅ | ✅ | ✅ |
| File Management | ✅ | ✅ | ✅ | ✅ | ✅ |
| Temp File Management | ✅ | ✅ | ✅ | ✅ | ✅ |
| Interceptors | ✅ | ✅ | ✅ | ✅ | ✅ |
| Retry Mechanism | ✅ | ❌ | ✅ | ✅ | ✅ |
| Instance Clients | ✅ | ✅ | ✅ | ✅ | ✅ |
| Error Handling | ✅ | ✅ | ✅ | ✅ | ✅ |

## 👨‍💻 Author

**Saqib** - [itsaqibdev.me](https://itsaqibdev.me) - [Fiverr](https://www.fiverr.com/itsaqibdev)

## 🏗️ Built With

- Inspired by and built on top of the [http](https://pub.dev/packages/http) package
- Enhanced with additional features for better developer experience

## 📄 License

MIT License

Copyright (c) 2025 itsaqibdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.