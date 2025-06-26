import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Home.dart'; // A Home é para onde o usuário será redirecionado após o login

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instância do Firebase Auth
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instância do Google SignIn

  // Função para realizar o login com o Google
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); // Inicia o processo de login com Google
      if (googleUser == null) {
        // Usuário cancelou o login
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz o login com as credenciais do Google no Firebase Auth
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      // Captura e imprime erros durante o Google Sign-In
      print("Erro durante o Google Sign-In: $e");
      // Exibe uma SnackBar com a mensagem de erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao entrar com o Google: $e')),
      );
      return null;
    }
  }

  // Lida com o processo de login
  void _handleSignIn() async {
    UserCredential? userCredential = await _signInWithGoogle();
    if (userCredential != null) {
      // Navega de volta para a Home após login bem-sucedido.
      // pushReplacement remove a LoginPage da pilha de navegação,
      // então o botão Voltar não retornará a ela.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF), // Cor de fundo do Scaffold
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A2A31), // Cor de fundo da AppBar
        bottom: const PreferredSize( // Linha divisória na parte inferior da AppBar
          preferredSize: Size.fromHeight(3.0),
          child: Divider(
            color: Color(0xFFFF3A3A),
            thickness: 3,
            height: 3,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagem ou logo do aplicativo
              Image.asset('assets/images/profile.png', height: 200), // Certifique-se de que o caminho e o arquivo existem
              const SizedBox(height: 5),
              // Mensagem de boas-vindas
              const Text(
                "Bem-vindo ao Hyperbrew!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2A31),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Descrição
              const Text(
                "Faça login para gerenciar suas fichas de personagem e sessões.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F7684),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Botão de login com Google
              ElevatedButton(
                onPressed: _handleSignIn, // Chama a função de login
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F7684),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50), // Botão de largura total
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Borda arredondada
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Mantém o conteúdo centralizado
                  children: <Widget>[
                    const Text("Sign in with"),
                    const SizedBox(width: 8), // Espaçamento entre texto e ícone
                    Image.asset('assets/images/google_logo_white.png', height: 30), // Ícone do Google
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

