import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'DetalhesFicha.dart';
import 'PlayerProfile.dart';
import 'NotesPage.dart';
import 'SettingsPage.dart';
import 'DiceRoller.dart';
import 'CreateFicha.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _fichas = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _carregarFichas();
  }

  Future<void> _carregarFichas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fichasJson = prefs.getStringList('fichas') ?? [];

    List<Map<String, dynamic>> fichas = fichasJson.map<Map<String, dynamic>>((jsonStr) {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }).toList();

    setState(() {
      _fichas = fichas;
    });
  }

  Future<void> _salvarFichas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fichasJson = _fichas.map((f) => jsonEncode(f)).toList();
    await prefs.setStringList('fichas', fichasJson);
  }

  void _editarFichaModal(Map<String, dynamic> ficha, int index) {
    final nomeCtrl = TextEditingController(text: ficha["nome"] ?? '');
    final classeCtrl = TextEditingController(text: ficha["classe"] ?? '');
    final racaCtrl = TextEditingController(text: ficha["raca"] ?? '');
    String? novaImagem = ficha["imagem"]?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2A31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Editar Ficha", style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setModalState(() => novaImagem = picked.path);
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: (novaImagem != null && File(novaImagem!).existsSync())
                      ? FileImage(File(novaImagem!))
                      : const AssetImage('images/avatar.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _input("Nome", nomeCtrl),
              _input("Classe", classeCtrl),
              _input("Raça", racaCtrl),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _fichas[index]["nome"] = nomeCtrl.text;
                    _fichas[index]["classe"] = classeCtrl.text;
                    _fichas[index]["raca"] = racaCtrl.text;
                    _fichas[index]["imagem"] = novaImagem;
                  });
                  await _salvarFichas();
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
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
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
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex != 2) return null;
    return AppBar(
      title: const Text(
        'Hyperbrew',
        style: TextStyle(color: Color(0xFFFF3A3A), fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF2A2A31),
      iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(3.0),
        child: Divider(
          color: Color(0xFFFF3A3A),
          thickness: 3,
          height: 3,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFFEAF8FF)),
          onSelected: (value) {
            if (value == 'perfil') setState(() => _selectedIndex = 0);
            if (value == 'config') setState(() => _selectedIndex = 4);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'perfil', child: Text("Perfil do Jogador")),
            const PopupMenuItem(value: 'config', child: Text("Configurações")),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const PlayerProfile(),
      const NotesPage(),
      _buildFichasView(),
      const DiceRoller(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2A2A31),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.note, color: Color(0xFF6F7684)),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.casino, color: Color(0xFF6F7684)),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFF3A3A),
              foregroundColor: const Color(0xFFEAF8FF),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateFicha()),
                );
                await _carregarFichas();
              },
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFF3A3A),
              foregroundColor: const Color(0xFFEAF8FF),
              onPressed: () => setState(() => _selectedIndex = 2),
              child: const Icon(Icons.play_arrow),
            ),
    );
  }

  Widget _buildFichasView() {
    return _fichas.isEmpty
        ? const Center(child: Text("Nenhuma ficha criada ainda.", style: TextStyle(color: Colors.black54)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _fichas.length,
            itemBuilder: (context, i) {
              final ficha = _fichas[i];
              final imagemPath = ficha["imagem"];
              final temImagemValida = imagemPath != null && File(imagemPath).existsSync();

              return Card(
                color: const Color(0xFF2A2A31),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: temImagemValida
                        ? FileImage(File(imagemPath))
                        : const AssetImage('images/avatar.jpg') as ImageProvider,
                  ),
                  title: Text(
                    ficha["nome"] ?? "Sem nome",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${ficha["classe"] ?? "Classe indefinida"} - ${ficha["raca"] ?? "Raça indefinida"}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFFEAF8FF)),
                    onSelected: (value) {
                      if (value == 'editar') {
                        _editarFichaModal(ficha, i);
                      } else if (value == 'ver') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetalhesFicha(ficha: ficha),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'ver', child: Text("Visualizar")),
                      const PopupMenuItem(value: 'editar', child: Text("Editar")),
                    ],
                  ),
                ),
              );
            },
          );
  }
}