import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

// Satu sumber kebenaran untuk favourite. Halaman Detail dan Favourite sama-sama
// membaca & mengubah object ini; ChangeNotifier memberi tahu semua listener,
// sehingga kedua halaman otomatis ter-update.
class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  String _username = '';
  List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);
  String get _key => 'favorites_$_username'; // favourite per user

  Future<void> load(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _items = raw
        .map((s) => Item.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  bool isFavorite(String type, int id) =>
      _items.any((e) => e.type == type && e.id == id);

  // return true jika sekarang menjadi favourite, false jika dihapus
  Future<bool> toggle(Item item) async {
    final wasFav = isFavorite(item.type, item.id);
    if (wasFav) {
      _items.removeWhere((e) => e.type == item.type && e.id == item.id);
    } else {
      _items.add(item);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, _items.map((e) => jsonEncode(e.toJson())).toList());
    return !wasFav;
  }

  void clear() {
    _username = '';
    _items = [];
    notifyListeners();
  }
}
