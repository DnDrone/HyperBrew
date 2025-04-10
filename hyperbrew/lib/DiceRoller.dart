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
    _audioPlayer.play(AssetSource('sounds/dice_roll.mp3'));

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
        backgroundColor: const Color(0xFF6F7684),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        title: const Text(
          "Rolador de Dados",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3.0),
          child: Divider(
            color: Color(0xFFFF3A3A),
            thickness: 3,
            height: 3,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Último resultado",
              style: TextStyle(color: Colors.black87, fontSize: 16),
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
                      color: Color(0xFF2A2A31),
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
