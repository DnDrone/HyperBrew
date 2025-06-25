import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instância do Firebase Auth
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instância do Google SignIn

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

      UserCredential userCredential = await _auth.signInWithCredential(credential); // Faz o login com as credenciais do Google
      return userCredential;
    } catch (e) {
      print("Erro durante o Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao entrar com o Google: $e')),
      );
      return null;
    }
  }

  void _handleSignIn() async {
    UserCredential? userCredential = await _signInWithGoogle();
    if (userCredential != null) {
      // Navega para a página Home após login bem-sucedido
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A2A31),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/avatar.jpg', height: 120), // Ou o logo do seu app
              const SizedBox(height: 30),
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
              const Text(
                "Faça login para gerenciar suas fichas de personagem e sessões.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F7684),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _handleSignIn,
                icon: Image.asset('images/google_logo.png', height: 24), // Você precisará de um asset com o logo do Google
                label: const Text("Entrar com Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F7684),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}