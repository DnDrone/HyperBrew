import 'package:flutter/material.dart';
import 'FichaDataBase.dart';  // importe sua classe do banco
import 'FichaModel.dart';     // modelo da ficha
import 'NotesFichaPage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Ficha> _fichas = [];

  @override
  void initState() {
    super.initState();
    // Escuta mudanças no estado de autenticação para recarregar as fichas
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _carregarFichas(); // Recarrega as fichas se o usuário logar/deslogar
      } else {
        setState(() {
          _fichas = []; // Limpa as fichas se não houver usuário logado
        });
      }
    });
  }

  Future<void> _carregarFichas() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String? userId = currentUser?.uid;

    if (userId != null) {
      print('Carregando fichas para notas do usuário: $userId');
      final fichas = await FichaDatabase.instance.readAllFichas(userId);
      setState(() {
        _fichas = fichas;
      });
    } else {
      print('Nenhum usuário logado. Não carregando fichas para notas.');
      setState(() {
        _fichas = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        title: const Text(
          "Notas de Sessão",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3.0),
          child: Divider(
            color: Color(0xFFFF3A3A),
            thickness: 5,
            height: 3,
          ),
        ),
      ),
      body: _fichas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    FirebaseAuth.instance.currentUser == null
                        ? "Faça login para ver suas notas de fichas."
                        : "Nenhuma ficha criada ainda para notas.",
                    style: const TextStyle(color: Color(0xFF2A2A31)),
                    textAlign: TextAlign.center,
                  ),
                   if (FirebaseAuth.instance.currentUser == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()), // Assume LoginPage existe
                        ).then((_) => _carregarFichas());
                      },
                      child: const Text("Fazer Login"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A31),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _fichas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, i) {
                final ficha = _fichas[i];
                return Card(
                  color: const Color(0xFF2A2A31),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (ficha.imagemPath != null && ficha.imagemPath!.isNotEmpty)
                          ? FileImage(File(ficha.imagemPath!))
                          : const AssetImage('images/avatar.jpg') as ImageProvider,
                    ),
                    title: Text(
                      ficha.nome,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${ficha.classe} - ${ficha.raca}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                    onTap: () {
                      if (ficha.id == null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Erro'),
                            content: const Text('Esta ficha ainda não foi salva e não tem ID válido.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotesFichaPage(
                              fichaId: ficha.id!,
                              fichaNome: ficha.nome,
                            ),
                          ),
                        ).then((_) => _carregarFichas());
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
