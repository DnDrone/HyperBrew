import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'CreateFicha.dart';
import 'DetalhesFicha.dart';
import 'PlayerProfile.dart';
import 'NotesPage.dart';
import 'SettingsPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _fichas = [];
  int _selectedIndex = 0;

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
    final nomeCtrl = TextEditingController(text: ficha["nome"]?.toString() ?? '');
    final classeCtrl = TextEditingController(text: ficha["classe"]?.toString() ?? '');
    final racaCtrl = TextEditingController(text: ficha["raca"]?.toString() ?? '');
    String? novaImagem = ficha["imagem"]?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF4d346b),
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
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4d346b),
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

  Widget _fichasPage() {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A9B),
      body: _fichas.isEmpty
          ? const Center(child: Text("Nenhuma ficha criada ainda.", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _fichas.length,
              itemBuilder: (context, i) {
                final ficha = _fichas[i];
                final imagemPath = ficha["imagem"]?.toString();
                final temImagemValida = imagemPath != null && File(imagemPath).existsSync();

                return Card(
                  color: const Color(0xFF4d346b),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: temImagemValida
                          ? FileImage(File(imagemPath))
                          : const AssetImage('images/avatar.jpg') as ImageProvider,
                    ),
                    title: Text(
                      ficha["nome"]?.toString() ?? "Sem nome",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${ficha["classe"]?.toString() ?? "Classe indefinida"} - ${ficha["raca"]?.toString() ?? "Raça indefinida"}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'editar') {
                          _editarFichaModal(ficha, i);
                        } else if (value == 'ver') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalhesFicha(
                                ficha: {
                                  "nome": (ficha["nome"] ?? "Sem nome").toString(),
                                  "descricao":
                                      "${(ficha["classe"] ?? "Classe indefinida").toString()} - ${(ficha["raca"] ?? "Raça indefinida").toString()}",
                                  "imagem": (ficha["imagem"] ?? "").toString(),
                                  "forca": int.tryParse(ficha["forca"]?.toString() ?? "") ?? 10,
                                  "destreza": int.tryParse(ficha["destreza"]?.toString() ?? "") ?? 10,
                                  "constituicao": int.tryParse(ficha["constituicao"]?.toString() ?? "") ?? 10,
                                  "inteligencia": int.tryParse(ficha["inteligencia"]?.toString() ?? "") ?? 10,
                                  "sabedoria": int.tryParse(ficha["sabedoria"]?.toString() ?? "") ?? 10,
                                  "carisma": int.tryParse(ficha["carisma"]?.toString() ?? "") ?? 10,
                                  "equipamentos": (ficha["equipamentos"] is List)
                                      ? ficha["equipamentos"]
                                      : ['Espada curta', 'Armadura de couro'],
                                },
                              ),
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
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4d346b),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateFicha()),
          ).then((_) => _carregarFichas());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _fichasPage(),
      const PlayerProfile(),
      const NotesPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF5D3A9B),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF4d346b),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset('images/logo.jpeg', height: 80),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: const <Widget>[
          Icon(Icons.folder_shared, size: 30),
          Icon(Icons.person, size: 30),
          Icon(Icons.note, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) _carregarFichas();
          });
        },
        color: const Color(0xFF4d346b),
        backgroundColor: const Color(0xFF5D3A9B),
        buttonBackgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
