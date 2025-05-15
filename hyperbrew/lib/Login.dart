import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'JogadorModel.dart';
import 'JogadorDataBase.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _nomeController = TextEditingController();
  bool _isLogin = true;

  Future<void> _salvarJogador(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    final jogador = Jogador(nome: nome);
    final id = await JogadorDatabase.instance.create(jogador);
    await prefs.setInt('jogador_id', id);
    await prefs.setString('jogador_nome', nome);
  }

  Future<void> _verificarLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      _showErro("Digite um nome.");
      return;
    }

    final jogadores = await JogadorDatabase.instance.readAll();
    final jogadorExistente = jogadores.firstWhere(
      (j) => j.nome.toLowerCase() == nome.toLowerCase(),
      orElse: () => Jogador(id: -1, nome: ''),
    );

    if (_isLogin) {
      if (jogadorExistente.id != -1) {
        await prefs.setInt('jogador_id', jogadorExistente.id!);
        await prefs.setString('jogador_nome', jogadorExistente.nome);
        _navegarParaHome();
      } else {
        _showErro("Nome não encontrado.");
      }
    } else {
      if (jogadorExistente.id == -1) {
        await _salvarJogador(nome);
        _navegarParaHome();
      } else {
        _showErro("Este nome já está em uso.");
      }
    }
  }

  void _showErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _navegarParaHome() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('jogador_id') ?? -1;
    final nome = prefs.getString('jogador_nome') ?? '';

    if (id != -1 && nome.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Home(jogadorId: id, jogadorNome: nome),
        ),
      );
    } else {
      _showErro("Erro ao carregar dados do jogador.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A31),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLogin ? "Entrar" : "Cadastrar",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _verificarLogin,
                child: Text(_isLogin ? "Entrar" : "Cadastrar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3A3A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Ainda não tem conta? Cadastre-se"
                      : "Já tem conta? Entrar",
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
