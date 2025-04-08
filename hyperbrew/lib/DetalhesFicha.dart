import 'package:flutter/material.dart';

class DetalhesFicha extends StatelessWidget {
  final Map<String, dynamic> ficha;

  const DetalhesFicha({super.key, required this.ficha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ficha["titulo"]),
        backgroundColor: Color(0xFF4d346b),
      ),
      body: Container(
        color: Color(0xFF5D3A9B),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Imagem
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  ficha["imagem"],
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Descrição geral
            Text(
              ficha["descricao"],
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white70),

            // Status fictícios (pode vir de um banco depois)
            const Text("Status",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatus("Força", 14),
            _buildStatus("Destreza", 12),
            _buildStatus("Constituição", 16),
            _buildStatus("Inteligência", 10),
            _buildStatus("Sabedoria", 11),
            _buildStatus("Carisma", 13),

            const Divider(color: Colors.white70),
            const SizedBox(height: 10),

            // Equipamentos
            const Text("Equipamentos",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("- Espada curta\n- Armadura de couro\n- Poção de cura",
                style: TextStyle(color: Colors.white)),
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
          Text(nome, style: const TextStyle(color: Colors.white)),
          Text(valor.toString(), style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
