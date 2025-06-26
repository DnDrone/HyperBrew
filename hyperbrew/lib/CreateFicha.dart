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
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:permission_handler/permission_handler.dart'; // Importe permission_handler


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


  // O método _salvarFichaLocal não é mais necessário, pois estamos salvando no SQLite e gerando PDF
  // Future<void> _salvarFichaLocal() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> fichas = prefs.getStringList('fichas') ?? [];

  //   Map<String, String> novaFicha = {
  //     'nome': _nomeController.text,
  //     'classe': _classeController.text,
  //     'raca': _racaController.text,
  //   };

  //   fichas.add(jsonEncode(novaFicha));
  //   await prefs.setStringList('fichas', fichas);
  // }

Future<void> _gerarPdfESalvar() async {
  // Obter o ID do usuário logado
  final currentUser = FirebaseAuth.instance.currentUser;
  final String? currentUserId = currentUser?.uid;

  // Se não houver usuário logado, exiba uma mensagem e retorne
  if (currentUserId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, faça login para criar e salvar uma ficha.')),
    );
    return;
  }

  // --- Começa a lógica de solicitação de permissão de armazenamento ---
  // Esta lógica é aplicada para Android e iOS, embora o iOS geralmente gerencie
  // permissões de diretório de documentos do app automaticamente.
  if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
    var status = await Permission.storage.status; // Verifica o status atual da permissão de armazenamento
    if (!status.isGranted) { // Se a permissão não foi concedida
      status = await Permission.storage.request(); // Solicita a permissão ao usuário
      if (!status.isGranted) { // Se a permissão ainda não foi concedida após a solicitação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de armazenamento negada. Não foi possível salvar o PDF.')),
        );
        return; // Retorna, impedindo o salvamento do PDF
      }
    }
  }
  // --- Termina a lógica de solicitação de permissão ---

  final novaFicha = Ficha(
    nome: _nomeController.text,
    classe: _classeController.text,
    raca: _racaController.text,
    imagemPath: '', // Mantenha vazio se a imagem não for selecionada aqui (ou adicione lógica para seleção de imagem)
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
    userId: currentUserId, // Atribui o ID do usuário logado à ficha
  );

  // Salvar a ficha no banco de dados SQLite
  final fichaCriada = await FichaDatabase.instance.create(novaFicha);

  // Gerar e salvar o PDF usando o PdfService
  final pdfFile = await PdfService.gerarPdfFicha(fichaCriada);

  // Exibir uma mensagem de sucesso para o usuário
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Ficha salva em DB (id=${fichaCriada.id}) e PDF em ${pdfFile.path}',
      ),
    ),
  );

  Navigator.pop(context); // Volta para a tela anterior após salvar
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
     body: SingleChildScrollView( // Permite rolagem se o conteúdo for muito grande
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Campos de texto para as propriedades da ficha
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
        const SizedBox(height: 20), // Espaçamento
        // Botão para salvar a ficha e gerar o PDF
        ElevatedButton(
          onPressed: _gerarPdfESalvar, // Chama o método para gerar PDF e salvar
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6F7684),
            foregroundColor: Colors.white,
          ),
          child: const Text("Salvar PDF e Ficha"),
        ),
      ],
    ),
  ),
),

    );
  }

  // Widget auxiliar para construir campos de texto
  Widget _buildCampo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF2A2A31)), // Estilo do texto de entrada
        decoration: InputDecoration(
          labelText: label, // Rótulo do campo
          labelStyle: const TextStyle(color: Color(0xFF2A2A31)), // Estilo do rótulo
          enabledBorder: const OutlineInputBorder( // Borda quando o campo não está focado
            borderSide: BorderSide(color: Color(0xFF2A2A31)),
          ),
          focusedBorder: const OutlineInputBorder( // Borda quando o campo está focado
            borderSide: BorderSide(color: Color(0xFF2A2A31), width: 2),
          ),
        ),
      ),
    );
  }
}
