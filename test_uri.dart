import 'dart:core';

void main() {
  final baseUrl = 'https://api.gr8rdesign.com';
  final path = 'public/Training/cat-sit.png';
  final uri = Uri.parse(baseUrl).resolve(path);
  print('Result: $uri');
}
