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

    Navigator.pop(context); // Volta pra home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5D3A9B),
      appBar: AppBar(
        title: const Text("Criar Ficha", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4d346b),
        iconTheme: const IconThemeData(color: Colors.white),
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
              child: const Text("Salvar PDF e Ficha", style: TextStyle(color: Color(0xFF5D3A9B))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
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
    );
  }
}
