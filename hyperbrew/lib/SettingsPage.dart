import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Importe Google Sign-In
import 'LoginPage.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool modoEscuro = false;

  void _confirmarAcao(String titulo, String mensagem, VoidCallback onConfirmar) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('confirm'.tr()),
            onPressed: () {
              Navigator.pop(context);
              onConfirmar();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _limparFichas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fichas');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("clear_fichas".tr())));
  }

  Future<void> _limparNotas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('fichas') ?? [];

    List<Map<String, dynamic>> fichas =
        jsonList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    for (var ficha in fichas) {
      ficha.remove("notas");
    }

    List<String> novaLista = fichas.map((f) => jsonEncode(f)).toList();
    await prefs.setStringList('fichas', novaLista);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("clear_notas".tr())));
  }

  Future<void> _resetarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nome');
    await prefs.remove('nickname');
    await prefs.remove('sistema');
    await prefs.remove('avatarPath');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("reset_profile".tr())));
  }

  // Novo método para logout
  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut(); // Desloga do Google
      await FirebaseAuth.instance.signOut(); // Desloga do Firebase
      // Redireciona para a tela de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deslogado com sucesso!")));
    } catch (e) {
      print("Erro ao deslogar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao deslogar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
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
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: modoEscuro,
            onChanged: (value) {
              setState(() => modoEscuro = value);
            },
            title: Text("dark_mode".tr(), style: const TextStyle(color: Color(0xFF2A2A31))),
            activeColor: const Color(0xFF6F7684),
          ),
          const Divider(color: Color(0xFF6F7684)),
          ListTile(
            leading: const Icon(Icons.delete, color: Color(0xFF2A2A31)),
            title: Text("clear_fichas".tr(), style: const TextStyle(color: Color(0xFF2A2A31))),
            onTap: () {
              _confirmarAcao("clear_fichas".tr(), "clear_fichas".tr(), _limparFichas);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sticky_note_2, color: Color(0xFF2A2A31)),
            title: Text("clear_notas".tr(), style: const TextStyle(color: Color(0xFF2A2A31))),
            onTap: () {
              _confirmarAcao("clear_notas".tr(), "clear_notas".tr(), _limparNotas);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove, color: Color(0xFF2A2A31)),
            title: Text("reset_profile".tr(), style: const TextStyle(color: Color(0xFF2A2A31))),
            onTap: () {
              _confirmarAcao("reset_profile".tr(), "reset_profile".tr(), _resetarPerfil);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF2A2A31)),
            title: Text("select_language".tr(), style: const TextStyle(color: Color(0xFF2A2A31))),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF2A2A31),
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("Português", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        context.setLocale(const Locale('pt'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text("English", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        context.setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF6F7684)),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFFF3A3A)), // Ícone de logout
            title: const Text("Sair", style: TextStyle(color: Color(0xFFFF3A3A))),
            onTap: () {
              _confirmarAcao("Sair", "Tem certeza que deseja sair?", _signOut); // Chamada para a função de logout
            },
          ),
        ],
      ),
    );
  }
}