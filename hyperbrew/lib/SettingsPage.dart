import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Importe Google Sign-In
import 'LoginPage.dart'; // Importe LoginPage para navegação de logout

class SettingsPage extends StatefulWidget {
  // Adicione os parâmetros para receber o ID e nome do usuário
  // Eles são opcionais, pois o usuário pode não estar logado
  final String? userId;
  final String? userName;

  const SettingsPage({super.key, this.userId, this.userName});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  // Função para confirmar ações com um AlertDialog
  void _confirmarAcao(String titulo, String mensagem, VoidCallback onConfirmar) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            child: Text('cancel'.tr()), // Botão de cancelar traduzível
            onPressed: () => Navigator.pop(context), // Fecha o AlertDialog
          ),
          TextButton(
            child: Text('confirm'.tr()), // Botão de confirmar traduzível
            onPressed: () {
              Navigator.pop(context); // Fecha o AlertDialog
              onConfirmar(); // Executa a ação confirmada
            },
          ),
        ],
      ),
    );
  }

  // Função para limpar as fichas do usuário (específicas do ID se logado)
  Future<void> _limparFichas() async {
    final prefs = await SharedPreferences.getInstance();
    // Usa o userId como sufixo para a chave, se disponível
    final String fichasKey = widget.userId != null ? 'fichas_${widget.userId}' : 'fichas';
    await prefs.remove(fichasKey); // Remove os dados das fichas
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("clear_fichas".tr())));
  }

  // Função para limpar as notas do usuário (específicas do ID se logado)
  Future<void> _limparNotas() async {
    final prefs = await SharedPreferences.getInstance();
    // Usa o userId como sufixo para a chave, se disponível
    final String fichasKey = widget.userId != null ? 'fichas_${widget.userId}' : 'fichas';
    List<String> jsonList = prefs.getStringList(fichasKey) ?? [];

    List<Map<String, dynamic>> fichas =
        jsonList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    // Remove a chave "notas" de cada ficha
    for (var ficha in fichas) {
      ficha.remove("notas");
    }

    List<String> novaLista = fichas.map((f) => jsonEncode(f)).toList();
    await prefs.setStringList(fichasKey, novaLista); // Salva de volta as fichas sem as notas

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("clear_notas".tr())));
  }

  // Função para resetar o perfil do usuário (específico do ID se logado)
  Future<void> _resetarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    // Adiciona o sufixo de ID do usuário às chaves para garantir reset por usuário
    final String idSuffix = widget.userId != null ? '_${widget.userId}' : '';

    await prefs.remove('nome$idSuffix');
    await prefs.remove('nickname$idSuffix');
    await prefs.remove('sistema$idSuffix');
    await prefs.remove('avatarPath$idSuffix');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("reset_profile".tr())));
  }

  // Função para realizar o logout do Firebase e Google Sign-In
  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut(); // Desloga do Google
      await FirebaseAuth.instance.signOut(); // Desloga do Firebase
      // Redireciona para a tela de login, limpando a pilha de navegação
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
    // Obtém o usuário atual do Firebase para exibir informações e controlar o botão de login/logout
    final currentUser = FirebaseAuth.instance.currentUser;
    // Prioriza os dados passados pelo construtor, senão usa os do currentUser
    final displayUserId = widget.userId ?? currentUser?.uid;
    final displayUserName = widget.userName ?? currentUser?.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF), // Cor de fundo do Scaffold
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A2A31), // Cor de fundo da AppBar
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)), // Cor dos ícones da AppBar
        bottom: const PreferredSize( // Linha divisória na parte inferior da AppBar
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
          // Seção para exibir informações do usuário logado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Usuário Logado:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A31)),
                ),
                SizedBox(height: 8),
                // Exibe o nome do usuário ou "Não Logado"
                if (displayUserName != null && displayUserName.isNotEmpty)
                  Text(
                    displayUserName,
                    style: TextStyle(fontSize: 16, color: Color(0xFF6F7684)),
                  )
                else
                  Text(
                    "Não Logado",
                    style: TextStyle(fontSize: 16, color: Color(0xFF6F7684)),
                  ),
                // Exibe o ID do usuário apenas se estiver logado
                if (displayUserId != null && displayUserId.isNotEmpty && displayUserName != "Não Logado")
                  Text(
                    "ID: ${displayUserId}",
                    style: TextStyle(fontSize: 14, color: Color(0xFF6F7684)),
                  ),
              ],
            ),
          ),
          // Opção de Modo Escuro
          const Divider(color: Color(0xFF6F7684)),
          // Opções de Limpeza de Dados
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
          // Opção de Seleção de Idioma
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
          // Botão de Login/Logout
          ListTile(
            leading: displayUserId != null && displayUserId.isNotEmpty
                ? const Icon(Icons.logout, color: Color(0xFFFF3A3A)) // Ícone de logout se logado
                : const Icon(Icons.login, color: Color(0xFF2A2A31)), // Ícone de login se não logado
            title: displayUserId != null && displayUserId.isNotEmpty
                ? const Text("Sair", style: TextStyle(color: Color(0xFFFF3A3A)))
                : const Text("Entrar", style: TextStyle(color: Color(0xFF2A2A31))),
            onTap: () {
              if (displayUserId != null && displayUserId.isNotEmpty) {
                // Se o usuário está logado, mostra confirmação de logout
                _confirmarAcao("Sair", "Tem certeza que deseja sair?", _signOut);
              } else {
                // Se não está logado, navega para a LoginPage
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

