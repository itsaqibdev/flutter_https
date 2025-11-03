import 'package:flutter_https/flutter_https.dart';

void main() async {
  // Add a logging interceptor
  https.addInterceptor(LoggingInterceptor());
  
  try {
    // Make a GET request using static methods with string URL
    final response = await https.get('https://jsonplaceholder.typicode.com/posts/1');
    
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    
    print('\n' + '='*50 + '\n');
    
    // Download a file with progress reporting
    print('Downloading file...');
    final filePath = await https.download(
      'https://httpbin.org/json',
      'example.json',
      onProgress: (received, total) {
        if (total > 0) {
          final progress = (received / total * 100).toStringAsFixed(2);
          print('Progress: $progress%');
        }
      },
    );
    
    print('Downloaded file to: $filePath');
    
    // List downloaded files
    print('\nDownloaded files:');
    final files = https.listDownloadedFiles();
    files.forEach((name, path) {
      print('  $name: $path');
    });
    
    // Get a specific downloaded file
    final examplePath = https.getDownloadedFile('example.json');
    print('\nPath of example.json: $examplePath');
    
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
  } finally {
    // Clean up all downloaded files
    final count = await https.deleteAllDownloadedFiles();
    print('Cleaned up $count downloaded files');
  }
}