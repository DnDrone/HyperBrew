import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'CreateFicha.dart';
import 'DiceRoller.dart';
import 'PlayerProfile.dart';
import 'NotesPage.dart';
import 'SettingsPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _fichas = [];

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
    final nomeCtrl = TextEditingController(text: ficha["nome"]);
    final classeCtrl = TextEditingController(text: ficha["classe"]);
    final racaCtrl = TextEditingController(text: ficha["raca"]);
    String? novaImagem = ficha["imagem"];

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
                  backgroundImage: novaImagem != null
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

  @override
  Widget build(BuildContext context) {
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
      drawer: Drawer(
        backgroundColor: const Color(0xFF4d346b),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4d346b)),
              child: Center(
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Criar Ficha', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateFicha()));
                _carregarFichas();
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino, color: Colors.white),
              title: const Text('Rolador de Dados', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DiceRoller()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Perfil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerProfile()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.note, color: Colors.white),
              title: const Text('Notas de Sessão', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Configurações', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
          ],
        ),
      ),
      body: _fichas.isEmpty
          ? const Center(child: Text("Nenhuma ficha criada.", style: TextStyle(color: Colors.white, fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _fichas.length,
              itemBuilder: (context, i) {
                final ficha = _fichas[i];
                return Card(
                  color: const Color(0xFF4d346b),
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          CircleAvatar(
                            backgroundImage: ficha["imagem"] != null
                                ? FileImage(File(ficha["imagem"]))
                                : const AssetImage('images/avatar.jpg') as ImageProvider,
                            radius: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ficha["nome"] ?? "Sem Nome",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text("Classe: ${ficha["classe"]}, Raça: ${ficha["raca"]}",
                            style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: const Color(0xFF4d346b),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (_) => Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: ficha["imagem"] != null
                                              ? FileImage(File(ficha["imagem"]))
                                              : const AssetImage('images/avatar.jpg') as ImageProvider,
                                          radius: 50,
                                        ),
                                        const SizedBox(height: 15),
                                        Text("Nome: ${ficha["nome"]}",
                                            style: const TextStyle(color: Colors.white, fontSize: 18)),
                                        Text("Classe: ${ficha["classe"]}",
                                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                                        Text("Raça: ${ficha["raca"]}",
                                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                                        const Divider(color: Colors.white30, height: 30),
                                        Text("Status: Vida 100, Mana 50",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("Equipamentos: Espada, Armadura",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("Habilidades: Corte Rápido, Cura Mágica",
                                            style: const TextStyle(color: Colors.white70)),
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _editarFichaModal(ficha, i);
                                          },
                                          icon: const Icon(Icons.edit),
                                          label: const Text("Editar"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Color(0xFF4d346b),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Ver Detalhes"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF4d346b),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
