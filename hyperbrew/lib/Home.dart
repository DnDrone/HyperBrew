// lib/pages/Home.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'FichaModel.dart';
import 'FichaDataBase.dart';
import 'CreateFicha.dart';
import 'DetalhesFicha.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Ficha> _fichas = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _carregarFichas();
  }

  Future<void> _carregarFichas() async {
    final all = await FichaDatabase.instance.readAllFichas();
    setState(() => _fichas = all);
  }

  Future<void> _deletarFicha(int id) async {
    await FichaDatabase.instance.delete(id);
    await _carregarFichas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        title: const Text(
          'Hyperbrew',
          style: TextStyle(color: Color(0xFFFF3A3A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3.0),
          child: Divider(color: Color(0xFFFF3A3A), thickness: 3, height: 3),
        ),
      ),
      body: _buildFichasView(),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }

  Widget _buildFichasView() {
    if (_fichas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma ficha criada ainda.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fichas.length,
      itemBuilder: (context, i) {
        final ficha = _fichas[i];
        final hasImage = ficha.imagemPath.isNotEmpty && File(ficha.imagemPath).existsSync();

        return Card(
          color: const Color(0xFF2A2A31),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: hasImage
                  ? FileImage(File(ficha.imagemPath))
                  : const AssetImage('images/avatar.jpg') as ImageProvider,
            ),
            title: Text(
              ficha.nome,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${ficha.classe} - ${ficha.raca}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFFEAF8FF)),
              onSelected: (value) async {
                if (value == 'ver') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesFicha(ficha: ficha),
                    ),
                  );
                } else if (value == 'excluir') {
                  await _deletarFicha(ficha.id!);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'ver', child: Text('Visualizar')),
                PopupMenuItem(value: 'excluir', child: Text('Excluir')),
              ],
            ),
          ),
        );
      },
    );
  }
}
