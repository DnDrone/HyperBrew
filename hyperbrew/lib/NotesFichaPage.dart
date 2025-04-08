import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesFichaPage extends StatefulWidget {
  final Map<String, dynamic> ficha;
  final int index;

  const NotesFichaPage({super.key, required this.ficha, required this.index});

  @override
  State<NotesFichaPage> createState() => _NotesFichaPageState();
}

class _NotesFichaPageState extends State<NotesFichaPage> {
  List<Map<String, dynamic>> _notas = [];

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  void _carregarNotas() {
    final lista = widget.ficha["notas"] as List<dynamic>? ?? [];
    _notas = lista.cast<Map<String, dynamic>>();
  }

  Future<void> _salvarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> fichasJson = prefs.getStringList('fichas') ?? [];

    final fichas = fichasJson.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    fichas[widget.index]["notas"] = _notas;

    final novaLista = fichas.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('fichas', novaLista);
  }

  void _abrirEditor({Map<String, dynamic>? nota, int? index}) {
    final tituloCtrl = TextEditingController(text: nota?["titulo"]);
    final descCtrl = TextEditingController(text: nota?["descricao"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF4d346b),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nova Nota", style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            _input("Título", tituloCtrl),
            _input("Descrição", descCtrl, maxLines: 4),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final novaNota = {
                  "titulo": tituloCtrl.text,
                  "descricao": descCtrl.text,
                  "data": DateTime.now().toIso8601String(),
                };

                setState(() {
                  if (index != null) {
                    _notas[index] = novaNota;
                  } else {
                    _notas.insert(0, novaNota);
                  }
                });

                await _salvarNotas();
                Navigator.pop(context);
              },
              child: const Text("Salvar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4d346b),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  String _formatarData(String iso) {
    final data = DateTime.parse(iso);
    return "${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A9B),
      appBar: AppBar(
        title: Text("Notas: ${widget.ficha["nome"]}", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4d346b),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _abrirEditor(),
          )
        ],
      ),
      body: _notas.isEmpty
          ? const Center(child: Text("Sem notas ainda.", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              itemCount: _notas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, i) {
                final nota = _notas[i];
                return Card(
                  color: const Color(0xFF4d346b),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(nota["titulo"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nota["descricao"], style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(_formatarData(nota["data"]), style: const TextStyle(color: Colors.white30, fontSize: 12)),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'editar') {
                          _abrirEditor(nota: nota, index: i);
                        } else if (value == 'excluir') {
                          setState(() => _notas.removeAt(i));
                          await _salvarNotas();
                        }
                      },
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'editar', child: Text("Editar")),
                        const PopupMenuItem(value: 'excluir', child: Text("Excluir")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
