import 'package:flutter/material.dart';
import 'package:football_news/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:football_news/screens/menu.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _content = "";
  String _category = "update"; // default
  String _thumbnail = "";
  bool _isFeatured = false; // default

  final List<String> _categories = [
    'transfer',
    'update',
    'exclusive',
    'match',
    'rumor',
    'analysis',
  ];

  Future<void> _submitForm(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    final body = jsonEncode({
      "title": _title,
      "content": _content,
      "thumbnail": _thumbnail,
      "category": _category,
      "is_featured": _isFeatured,
    });

    // TODO: Ganti URL sesuai backend kalian. Tambahkan trailing slash.
    // Untuk Chrome (desktop): http://localhost:8000/
    // Untuk Android emulator: http://10.0.2.2:8000/
    const String url = "http://[Your_APP_URL]/create-flutter/";

    // Kirim request ke server (jika backend tersedia). Tangani response.
    Map<String, dynamic>? response;
    try {
      response = await request.postJson(url, body);
    } catch (e) {
      response = null;
    }

    // Tampilkan dialog berisi input yang dimasukkan dan hasil jika ada
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        final success = response != null &&
            (response['status'] == 'success' || response['status'] == true);
        return AlertDialog(
          title:
              Text(success ? 'Berita berhasil disimpan' : 'Informasi Berkas'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul: $_title'),
                const SizedBox(height: 4),
                Text('Isi: ${_content.length > 200 ? _content.substring(0, 200) + '...' : _content}'),
                const SizedBox(height: 4),
                Text('Kategori: $_category'),
                const SizedBox(height: 4),
                Text('Thumbnail: ${_thumbnail.isNotEmpty ? _thumbnail : 'Tidak ada'}'),
                const SizedBox(height: 4),
                Text('Unggulan: ${_isFeatured ? "Ya" : "Tidak"}'),
                const SizedBox(height: 8),
                if (response != null) ...[
                  const Divider(),
                  Text('Server response:'),
                  Text(response.toString(), style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // close dialog
                // Reset form
                _formKey.currentState!.reset();
                setState(() {
                  _category = "update";
                  _isFeatured = false;
                  _title = "";
                  _content = "";
                  _thumbnail = "";
                });

                if (success) {
                  // optional: navigate back to home
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                } else {
                  // show snackbar if server failed or unreachable
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(response == null
                            ? 'Gagal menghubungi server.'
                            : (response['message'] ?? 'Something went wrong')),
                      ),
                    );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add News Form',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    hintText: "Judul Berita",
                    labelText: "Judul Berita",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Judul tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Content ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _content,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Isi Berita",
                    labelText: "Isi Berita",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _content = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Isi berita tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _category,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat[0].toUpperCase() + cat.substring(1)),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue ?? "update";
                    });
                  },
                ),
              ),

              // === Thumbnail URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _thumbnail,
                  decoration: InputDecoration(
                    hintText: "URL Thumbnail (opsional)",
                    labelText: "URL Thumbnail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value ?? "";
                    });
                  },
                ),
              ),

              // === Is Featured ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwitchListTile(
                  title: const Text("Tandai sebagai Berita Unggulan"),
                  value: _isFeatured,
                  onChanged: (bool value) {
                    setState(() {
                      _isFeatured = value;
                    });
                  },
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () => _submitForm(request),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}