import 'dart:io';
import 'package:flutter/material.dart';

class DetalhesFicha extends StatelessWidget {
  final Map<String, dynamic> ficha;

  const DetalhesFicha({super.key, required this.ficha});

  @override
  Widget build(BuildContext context) {
    final String nome = ficha["nome"]?.toString() ?? "Sem nome";
    final String descricao = ficha["descricao"]?.toString() ?? "";
    final String imagemPath = ficha["imagem"]?.toString() ?? "";
    final bool imagemValida = imagemPath.isNotEmpty && File(imagemPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(nome),
        backgroundColor: const Color(0xFF4d346b),
      ),
      body: Container(
        color: const Color(0xFF5D3A9B),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Imagem
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imagemValida
                    ? Image.file(File(imagemPath), height: 150, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 150, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Descrição geral
            Text(
              descricao,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white70),

            const Text("Status",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatus("Força", ficha["forca"]),
            _buildStatus("Destreza", ficha["destreza"]),
            _buildStatus("Constituição", ficha["constituicao"]),
            _buildStatus("Inteligência", ficha["inteligencia"]),
            _buildStatus("Sabedoria", ficha["sabedoria"]),
            _buildStatus("Carisma", ficha["carisma"]),

            const Divider(color: Colors.white70),
            const SizedBox(height: 10),

            const Text("Equipamentos",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._buildEquipamentos(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(String nome, dynamic valor) {
    int numero = int.tryParse(valor?.toString() ?? "") ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nome, style: const TextStyle(color: Colors.white)),
          Text(numero.toString(), style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  List<Widget> _buildEquipamentos() {
    if (ficha["equipamentos"] is List) {
      final equipamentos = ficha["equipamentos"] as List;
      return equipamentos
          .map<Widget>((item) => Text("- ${item.toString()}", style: const TextStyle(color: Colors.white)))
          .toList();
    } else {
      return [const Text("Nenhum equipamento", style: TextStyle(color: Colors.white))];
    }
  }
}
