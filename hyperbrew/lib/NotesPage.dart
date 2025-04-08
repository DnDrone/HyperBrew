import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotesFichaPage.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> _fichas = [];

  @override
  void initState() {
    super.initState();
    _carregarFichas();
  }

  Future<void> _carregarFichas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('fichas') ?? [];
    setState(() {
      _fichas = jsonList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A9B),
      appBar: AppBar(
        title: const Text("Notas de Sessão", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4d346b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _fichas.isEmpty
          ? const Center(child: Text("Nenhuma ficha criada ainda.", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              itemCount: _fichas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, i) {
                final ficha = _fichas[i];
                return Card(
                  color: const Color(0xFF4d346b),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: ficha["imagem"] != null
                          ? FileImage(File(ficha["imagem"]))
                          : const AssetImage('images/avatar.jpg') as ImageProvider,
                    ),
                    title: Text(ficha["nome"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${ficha["classe"]} - ${ficha["raca"]}", style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotesFichaPage(ficha: ficha, index: i),
                        ),
                      ).then((_) => _carregarFichas());
                    },
                  ),
                );
              },
            ),
    );
  }
}
