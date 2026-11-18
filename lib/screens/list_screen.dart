import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

class ListScreen extends StatefulWidget {
  final String title; // News / Blog / Reports
  final String type; // articles / blogs / reports
  const ListScreen({super.key, required this.title, required this.type});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Item> items = [];
  bool isLoading = true;
  String? error;
  String? selectedAuthor; // null = tidak ada filter aktif

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await getItems(widget.type);
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Gagal memuat data. Periksa koneksi internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Daftar chip diambil dari author (news_site) unik yang ada di data
    final authors = items.map((e) => e.newsSite).toSet().toList()..sort();
    final shown = selectedAuthor == null
        ? items
        : items.where((e) => e.newsSite == selectedAuthor).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoriteScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: fetchItems, child: const Text('Coba lagi')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        itemCount: authors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final a = authors[i];
                          return FilterChip(
                            label: Text(a),
                            selected: selectedAuthor == a,
                            // klik lagi chip yang aktif = matikan filter
                            onSelected: (v) =>
                                setState(() => selectedAuthor = v ? a : null),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, i) {
                          final item = shown[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                      type: item.type, id: item.id),
                                ),
                              ),
                              leading: SizedBox(
                                width: 64,
                                height: 64,
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  // exception handling bila gambar gagal dimuat
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                              title: Text(item.title,
                                  maxLines: 3, overflow: TextOverflow.ellipsis),
                              subtitle: Text(item.newsSite),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
