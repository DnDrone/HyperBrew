
import 'dart:io';
import 'package:flutter/material.dart';
import 'FichaModel.dart'; // Importa a classe Ficha

class DetalhesFicha extends StatelessWidget {
  final Ficha ficha;

  const DetalhesFicha({super.key, required this.ficha});

  @override
  Widget build(BuildContext context) {
    final String imagemPath = ficha.imagemPath;
    final bool imagemValida = imagemPath.isNotEmpty && File(imagemPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        title: Text(
          ficha.nome,
          style: const TextStyle(
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
      body: Container(
        color: const Color(0xFFEAF8FF),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imagemValida
                    ? Image.file(File(imagemPath), height: 150, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 150, color: Color(0xFF2A2A31)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              ficha.descricao ?? "Sem descrição",
              style: const TextStyle(fontSize: 18, color: Color(0xFF2A2A31)),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF6F7684)),
            const Text("Status",
                style: TextStyle(fontSize: 20, color: Color(0xFF2A2A31), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatus("Força", ficha.forca),
            _buildStatus("Destreza", ficha.destreza),
            _buildStatus("Constituição", ficha.constituicao),
            _buildStatus("Inteligência", ficha.inteligencia),
            _buildStatus("Sabedoria", ficha.sabedoria),
            _buildStatus("Carisma", ficha.carisma),
            const Divider(color: Color(0xFF6F7684)),
            const SizedBox(height: 10),
            const Text("Equipamentos",
                style: TextStyle(fontSize: 20, color: Color(0xFF2A2A31), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._buildEquipamentos(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(String nome, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nome, style: const TextStyle(color: Color(0xFF2A2A31))),
          Text(valor.toString(), style: const TextStyle(color: Color(0xFF2A2A31))),
        ],
      ),
    );
  }

  List<Widget> _buildEquipamentos() {
    if (ficha.equipamentos.isNotEmpty) {
      return ficha.equipamentos
          .map<Widget>((item) => Text("- $item", style: const TextStyle(color: Color(0xFF2A2A31))))
          .toList();
    } else {
      return [const Text("Nenhum equipamento", style: TextStyle(color: Color(0xFF2A2A31)))];
    }
  }
}
