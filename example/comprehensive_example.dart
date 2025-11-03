import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_https/flutter_https.dart';

/// A custom interceptor that adds an authorization header to requests
class AuthInterceptor extends Interceptor {
  final String token;

  AuthInterceptor(this.token);

  @override
  Future<void> onRequest(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $token';
    print('Added authorization header to request');
  }
}

void main() async {
  print('=== HTTPS Package Example ===\n');
  
  // Example 1: Basic usage
  print('1. Basic Usage:');
  await basicUsage();
  
  print('\n' + '='*50 + '\n');
  
  // Example 2: Using interceptors
  print('2. Using Interceptors:');
  await usingInterceptors();
  
  print('\n' + '='*50 + '\n');
  
  // Example 3: Using retry mechanism
  print('3. Using Retry Mechanism:');
  await usingRetry();
  
  print('\n' + '='*50 + '\n');
  
  // Example 4: Downloading files
  print('4. Downloading Files:');
  await downloadingFiles();
  
  print('\n' + '='*50 + '\n');
  
  // Example 5: Downloaded file management
  print('5. Downloaded File Management:');
  await downloadedFileManagement();
  
  print('\n' + '='*50 + '\n');
  
  // Example 6: Error handling
  print('6. Error Handling:');
  await errorHandling();
  
  // Clean up all downloaded files at the end
  final deletedCount = await https.deleteAllDownloadedFiles();
  print('\nCleaned up $deletedCount downloaded files');
}

Future<void> basicUsage() async {
  try {
    // Now you can use string URLs directly!
    final response = await https.get('https://jsonplaceholder.typicode.com/posts/1');
    
    print('Status: ${response.statusCode}');
    print('Body: ${response.body.substring(0, 100)}...');
  } on HTTPSException catch (e) {
    print('HTTPS Error: ${e.message}');
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> usingInterceptors() async {
  // Add interceptors
  https.addInterceptor(LoggingInterceptor());
  https.addInterceptor(AuthInterceptor('your-token-here'));
  
  try {
    // String URLs work with interceptors too
    final response = await https.get('https://jsonplaceholder.typicode.com/posts/1');
    
    print('Status: ${response.statusCode}');
  } on HTTPSException catch (e) {
    print('HTTPS Error: ${e.message}');
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> usingRetry() async {
  final baseClient = HTTPSClient();
  final client = RetryClient(
    baseClient,
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 500),
  );
  
  try {
    // Works with instance-based clients too
    final response = await client.get('https://jsonplaceholder.typicode.com/posts/1');
    
    print('Status: ${response.statusCode}');
  } on HTTPSException catch (e) {
    print('HTTPS Error: ${e.message}');
  } catch (e) {
    print('Error: $e');
  } finally {
    baseClient.close();
  }
}

Future<void> downloadingFiles() async {
  try {
    // Download a file with progress reporting
    final filePath = await https.download(
      'https://httpbin.org/json',
      'downloaded_file.json',
      onProgress: (received, total) {
        if (total > 0) {
          final progress = (received / total * 100).toStringAsFixed(2);
          print('Download progress: $progress% ($received/$total bytes)');
        } else {
          print('Downloaded $received bytes');
        }
      },
    );
    
    print('Download completed: $filePath');
    
    // Read and display the downloaded file
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      print('File content: ${content.substring(0, 50)}...');
    }
  } on HTTPSException catch (e) {
    print('HTTPS Error: ${e.message}');
  } catch (e) {
    print('Download error: $e');
  }
}

Future<void> downloadedFileManagement() async {
  try {
    // Download multiple files
    print('Downloading files...');
    final path1 = await https.download('https://httpbin.org/json', 'data1.json');
    final path2 = await https.download('https://httpbin.org/json', 'data2.json');
    
    print('Downloaded data1.json to: $path1');
    print('Downloaded data2.json to: $path2');
    
    // List all downloaded files
    print('\nListing downloaded files:');
    final downloadedFiles = https.listDownloadedFiles();
    downloadedFiles.forEach((name, path) {
      print('  $name -> $path');
    });
    
    // Get a specific downloaded file
    final data1Path = https.getDownloadedFile('data1.json');
    print('\nPath of data1.json: $data1Path');
    
    // Delete a specific downloaded file
    final deleted = await https.deleteDownloadedFile('data1.json');
    print('\nDeleted data1.json: $deleted');
    
    // List remaining files
    print('Remaining downloaded files:');
    final remainingFiles = https.listDownloadedFiles();
    remainingFiles.forEach((name, path) {
      print('  $name -> $path');
    });
  } on HTTPSException catch (e) {
    print('HTTPS Error: ${e.message}');
  } catch (e) {
    print('Downloaded file management error: $e');
  }
}

Future<void> errorHandling() async {
  print('Demonstrating error handling:');
  
  try {
    // This will likely fail (invalid URL)
    await https.get('https://invalid-domain-that-does-not-exist-12345.com/api');
  } on HTTPSException catch (e) {
    print('Caught HTTPSException:');
    print('  Message: ${e.message}');
    if (e.statusCode != null) {
      print('  Status Code: ${e.statusCode}');
    }
    if (e.originalError != null) {
      print('  Original Error: ${e.originalError}');
    }
  } catch (e) {
    print('Caught other exception: $e');
  }
  
  // Example with custom error handling
  try {
    final response = await https.get('https://httpbin.org/status/500');
    print('Status: ${response.statusCode}');
  } on HTTPSException catch (e) {
    if (e.statusCode == 500) {
      print('Server error (500) occurred, might want to retry');
    } else {
      print('Other HTTPS error: ${e.message}');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}