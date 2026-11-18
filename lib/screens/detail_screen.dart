import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import '../models/item.dart';
import '../services/favorite_service.dart';

class DetailScreen extends StatefulWidget {
  final String type;
  final int id;
  const DetailScreen({super.key, required this.type, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Item? item;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final data = await getItemDetail(widget.type, widget.id); // by id
      setState(() {
        item = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Gagal memuat detail.';
      });
    }
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _openWeb() async {
    try {
      final ok = await launchUrl(Uri.parse(item!.url),
          mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('cannot launch');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak bisa membuka situs'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleFav() async {
    final nowFav = await FavoriteService.instance.toggle(item!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              nowFav ? 'Ditambahkan ke favorite' : 'Dihapus dari favorite')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          if (item != null)
            // Ikon hati ikut berubah kalau favourite diubah dari mana pun
            ListenableBuilder(
              listenable: FavoriteService.instance,
              builder: (context, _) {
                final isFav =
                    FavoriteService.instance.isFavorite(item!.type, item!.id);
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white),
                  onPressed: _toggleFav,
                );
              },
            ),
        ],
      ),
      floatingActionButton: item == null
          ? null
          : FloatingActionButton(
              tooltip: 'Buka Web',
              onPressed: _openWeb,
              child: const Icon(Icons.open_in_new),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        item!.imageUrl,
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 240,
                          color: Colors.grey.shade300,
                          child: const Center(
                              child: Icon(Icons.broken_image, size: 64)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item!.title,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(item!.newsSite,
                                style: TextStyle(color: Colors.grey.shade700)),
                            Text(_formatDate(item!.publishedAt),
                                style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 16),
                            Text(item!.summary,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 80), // ruang untuk FAB
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
