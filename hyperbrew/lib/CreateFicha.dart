// lib/CreateFicha.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class CreateFicha extends StatefulWidget {
  const CreateFicha({super.key});

  @override
  State<CreateFicha> createState() => _CreateFichaState();
}

class _CreateFichaState extends State<CreateFicha> {
  final _nomeController = TextEditingController();
  final _classeController = TextEditingController();
  final _racaController = TextEditingController();

  Future<void> _salvarFichaLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fichas = prefs.getStringList('fichas') ?? [];

    Map<String, String> novaFicha = {
      'nome': _nomeController.text,
      'classe': _classeController.text,
      'raca': _racaController.text,
    };

    fichas.add(jsonEncode(novaFicha));
    await prefs.setStringList('fichas', fichas);
  }

  void _gerarPdfESalvar() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Ficha de Personagem", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text("Nome: ${_nomeController.text}"),
            pw.Text("Classe: ${_classeController.text}"),
            pw.Text("Raça: ${_racaController.text}"),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${_nomeController.text}_ficha.pdf');
    await file.writeAsBytes(await pdf.save());

    await _salvarFichaLocal();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ficha salva e PDF gerado: ${file.path}'),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        title: const Text(
          "Criar Ficha",
          style: TextStyle(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCampo("Nome do personagem", _nomeController),
            _buildCampo("Classe", _classeController),
            _buildCampo("Raça", _racaController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _gerarPdfESalvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F7684),
                foregroundColor: Colors.white,
              ),
              child: const Text("Salvar PDF e Ficha"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF2A2A31)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF2A2A31)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A2A31)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A2A31), width: 2),
          ),
        ),
      ),
    );
  }
}
