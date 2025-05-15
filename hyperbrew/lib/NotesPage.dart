import 'package:flutter/material.dart';
import 'FichaDataBase.dart';  // importe sua classe do banco
import 'FichaModel.dart';     // modelo da ficha
import 'NotesFichaPage.dart';
import 'dart:io';

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
    _carregarFichas();
  }

  Future<void> _carregarFichas() async {
    final fichas = await FichaDatabase.instance.readAllFichas();
    setState(() {
      _fichas = fichas;
    });
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
          ? const Center(
              child: Text(
                "Nenhuma ficha criada ainda.",
                style: TextStyle(color: Color(0xFF2A2A31)),
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
                      // Aqui você pode mostrar um alerta para o usuário informando que a ficha não está salva ainda
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
                      // Se o id não for nulo, navegue normalmente passando os dados
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
