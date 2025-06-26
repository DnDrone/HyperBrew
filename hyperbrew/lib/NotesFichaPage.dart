import 'package:flutter/material.dart';
import 'FichaDataBase.dart'; // Importe seu arquivo do banco
import 'FichaModel.dart';

class NotesFichaPage extends StatefulWidget {
  final int fichaId;
  final String fichaNome;

  const NotesFichaPage(
      {super.key, required this.fichaId, required this.fichaNome});

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

  Future<void> _carregarNotas() async {
    final notas = await FichaDatabase.instance.readNotas(widget.fichaId);
    setState(() {
      _notas = List<Map<String, dynamic>>.from(notas);
    });
  }

  Future<void> _salvarNota({Map<String, dynamic>? nota, int? index}) async {
    final titulo = nota?['titulo'] ?? '';
    final descricao = nota?['descricao'] ?? '';
    final data = DateTime.now().toIso8601String();

    if (index != null) {
      // Update
      final notaAtual = _notas[index];
      final id = notaAtual['id'] as int;
      await FichaDatabase.instance.updateNota(id, {
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
      });
      _notas[index] = {
        'id': id,
        'fichaId': widget.fichaId,
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
      };
    } else {
      // Create
      final id = await FichaDatabase.instance.createNota(widget.fichaId, {
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
      });
      _notas.insert(0, {
        'id': id,
        'fichaId': widget.fichaId,
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
      });
    }

    setState(() {});
  }

  Future<void> _excluirNota(int index) async {
    final id = _notas[index]['id'] as int;
    await FichaDatabase.instance.deleteNota(id);
    setState(() {
      _notas.removeAt(index);
    });
  }

  void _abrirEditor({Map<String, dynamic>? nota, int? index}) {
    final tituloCtrl = TextEditingController(text: nota?["titulo"]);
    final descCtrl = TextEditingController(text: nota?["descricao"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2A31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              index == null ? "Nova Nota" : "Editar Nota",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            _input("Título", tituloCtrl),
            _input("Descrição", descCtrl, maxLines: 4),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (tituloCtrl.text.trim().isEmpty)
                  return; // título obrigatório

                await _salvarNota(
                  nota: {
                    'titulo': tituloCtrl.text.trim(),
                    'descricao': descCtrl.text.trim(),
                  },
                  index: index,
                );
                Navigator.pop(context);
              },
              child: const Text("Salvar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F7684),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {int maxLines = 1}) {
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
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        title: Text(
          "Notas: ${widget.fichaNome}",
          style: const TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: Divider(
            color: Color(0xFFFF3A3A),
            thickness: 3,
            height: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFEAF8FF)),
            onPressed: () => _abrirEditor(),
          ),
        ],
      ),
      body: _notas.isEmpty
          ? const Center(
              child: Text("Sem notas ainda.",
                  style: TextStyle(color: Color(0xFF2A2A31))))
          : ListView.builder(
              itemCount: _notas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, i) {
                final nota = _notas[i];
                return Card(
                  color: const Color(0xFF2A2A31),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(nota["titulo"],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nota["descricao"] ?? '',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(_formatarData(nota["data"]),
                            style: const TextStyle(
                                color: Colors.white30, fontSize: 12)),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'editar') {
                          _abrirEditor(nota: nota, index: i);
                        } else if (value == 'excluir') {
                          await _excluirNota(i);
                        }
                      },
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'editar', child: Text("Editar")),
                        const PopupMenuItem(
                            value: 'excluir', child: Text("Excluir")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
