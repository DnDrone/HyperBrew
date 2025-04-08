import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  int _result = 0;
  String _currentDice = "d20";
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _rollDice(String dice) {
    setState(() => _currentDice = dice);

    int sides = int.parse(dice.substring(1));

    // 🔊 Toca som imediatamente ao clicar
    _audioPlayer.play(AssetSource('sounds/dice_roll.mp3'));

    // 🔄 Roda a animação
    _controller.forward(from: 0).then((_) {
      setState(() {
        _result = _random.nextInt(sides) + 1;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _diceButton(String label) {
    return ElevatedButton(
      onPressed: () => _rollDice(label),
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4d346b),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A9B),
      appBar: AppBar(
        title: const Text("Rolador de Dados", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4d346b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Último resultado",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _rotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotation.value,
                  child: Text(
                    _result > 0 ? '$_result' : '-',
                    style: const TextStyle(
                      fontSize: 60,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _diceButton("d4"),
                _diceButton("d6"),
                _diceButton("d8"),
                _diceButton("d10"),
                _diceButton("d12"),
                _diceButton("d20"),
                _diceButton("d100"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
