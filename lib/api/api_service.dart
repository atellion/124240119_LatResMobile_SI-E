import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

// type = 'articles' | 'blogs' | 'reports'
Future<List<Item>> getItems(String type) async {
  final response = await http.get(Uri.parse('$baseUrl/$type/?limit=30'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => Item.fromApi(type, e as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load $type');
  }
}

// Detail diakses berdasarkan id: /v4/{menu}/{id}/
Future<Item> getItemDetail(String type, int id) async {
  final response = await http.get(Uri.parse('$baseUrl/$type/$id/'));
  if (response.statusCode == 200) {
    return Item.fromApi(type, jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load detail');
  }
}
