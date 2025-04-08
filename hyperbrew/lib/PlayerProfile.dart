import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile extends StatefulWidget {
  const PlayerProfile({super.key});

  @override
  State<PlayerProfile> createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {
  String nome = "Felipe Vilhena";
  String nickname = "DungeonFelipe";
  String sistema = "D&D 5e";
  int totalFichas = 0;
  String? avatarPath;

  final nomeController = TextEditingController();
  final nicknameController = TextEditingController();
  final sistemaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final fichas = prefs.getStringList('fichas') ?? [];

    setState(() {
      nome = prefs.getString('nome') ?? nome;
      nickname = prefs.getString('nickname') ?? nickname;
      sistema = prefs.getString('sistema') ?? sistema;
      avatarPath = prefs.getString('avatarPath');
      totalFichas = fichas.length;

      nomeController.text = nome;
      nicknameController.text = nickname;
      sistemaController.text = sistema;
    });
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', nomeController.text);
    await prefs.setString('nickname', nicknameController.text);
    await prefs.setString('sistema', sistemaController.text);

    setState(() {
      nome = nomeController.text;
      nickname = nicknameController.text;
      sistema = sistemaController.text;
    });

    Navigator.pop(context);
  }

  Future<void> _selecionarAvatar() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarPath', imagem.path);
      setState(() {
        avatarPath = imagem.path;
      });
    }
  }

  void _abrirEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF4d346b),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Editar Perfil", style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            _input("Nome", nomeController),
            _input("Nickname", nicknameController),
            _input("Sistema favorito", sistemaController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarDados,
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
        title: const Text("Perfil do Jogador", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4d346b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _selecionarAvatar,
              child: CircleAvatar(
                backgroundImage: avatarPath != null ? FileImage(File(avatarPath!)) : const AssetImage('images/avatar.jpg') as ImageProvider,
                radius: 60,
              ),
            ),
            const SizedBox(height: 20),

            // Nome e nickname
            Text(
              nome,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("@$nickname", style: const TextStyle(color: Colors.white70)),

            const SizedBox(height: 20),
            const Divider(color: Colors.white30),

            _infoItem("Sistema favorito", sistema),
            _infoItem("Fichas criadas", "$totalFichas"),
            _infoItem("Classe mais usada", "Guerreiro"),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _abrirEditor,
              icon: const Icon(Icons.edit),
              label: const Text("Editar Perfil"),
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

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}
