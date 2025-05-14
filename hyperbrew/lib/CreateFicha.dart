// lib/CreateFicha.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'FichaModel.dart';
import 'FichaDataBase.dart';
import 'PdfService.dart';


class CreateFicha extends StatefulWidget {
  const CreateFicha({super.key});

  @override
  State<CreateFicha> createState() => _CreateFichaState();
}

class _CreateFichaState extends State<CreateFicha> {
  final _nomeController = TextEditingController();
  final _classeController = TextEditingController();
  final _racaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _forcaController = TextEditingController();
  final _destrezaController = TextEditingController();
  final _constituicaoController = TextEditingController();
  final _inteligenciaController = TextEditingController();
  final _sabedoriaController = TextEditingController();
  final _carismaController = TextEditingController();
  final _equipamentosController = TextEditingController(); 


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

Future<void> _gerarPdfESalvar() async {
  final novaFicha = Ficha(
    nome: _nomeController.text,
    classe: _classeController.text,
    raca: _racaController.text,
    imagemPath: '',
    descricao: _descricaoController.text,
    forca: int.tryParse(_forcaController.text) ?? 0,
    destreza: int.tryParse(_destrezaController.text) ?? 0,
    constituicao: int.tryParse(_constituicaoController.text) ?? 0,
    inteligencia: int.tryParse(_inteligenciaController.text) ?? 0,
    sabedoria: int.tryParse(_sabedoriaController.text) ?? 0,
    carisma: int.tryParse(_carismaController.text) ?? 0,
    equipamentos: _equipamentosController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(),
  );

  final fichaCriada = await FichaDatabase.instance.create(novaFicha);

  final pdfFile = await PdfService.gerarPdfFicha(fichaCriada);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Ficha salva em DB (id=${fichaCriada.id}) e PDF em ${pdfFile.path}',
      ),
    ),
  );

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
            _buildCampo("Descrição", _descricaoController),
            _buildCampo("Força", _forcaController),
            _buildCampo("Destreza", _destrezaController),
            _buildCampo("Constituição", _constituicaoController),
            _buildCampo("Inteligência", _inteligenciaController),
            _buildCampo("Sabedoria", _sabedoriaController),
            _buildCampo("Carisma", _carismaController),
            _buildCampo("Equipamentos (separados por vírgula)", _equipamentosController),

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
