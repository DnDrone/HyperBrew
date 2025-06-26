import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';
// A LoginPage não é mais a tela inicial, então sua importação aqui não é estritamente necessária
// mas a mantemos para referência se você quiser ter uma LoginPage separada para navegação.
// import 'LoginPage.dart';

// Para sqflite_common_ffi, necessário para desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

// Certifique-se de que este import existe se você usou 'flutterfire configure'
import 'firebase_options.dart';


void main() async {
  // Inicialização do sqflite_common_ffi para plataformas desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Garante que os widgets do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Garante que o EasyLocalization esteja inicializado para suporte a múltiplos idiomas
  await EasyLocalization.ensureInitialized();
  
  // Inicialização do Firebase Core com as opções da plataforma atual
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Se a inicialização do Firebase falhar, imprime o erro no console
    print("Erro na inicialização do Firebase: $e");
    // Você pode adicionar um AlertDialog ou uma tela de erro aqui para avisar o usuário
  }

  // Inicia o aplicativo Flutter com EasyLocalization para gerenciar o idioma
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt')], // Define os idiomas suportados
      path: 'assets/translations', // Caminho para os arquivos de tradução
      fallbackLocale: const Locale('pt'), // Idioma de fallback
      child: const MyApp(), // O widget raiz do seu aplicativo
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug"
      locale: context.locale, // Define o locale atual do aplicativo
      supportedLocales: context.supportedLocales, // Define os locales suportados
      localizationsDelegates: context.localizationsDelegates, // Delega a localização para EasyLocalization
      // O aplicativo sempre começará na Home.
      // A lógica de login/logout será gerenciada dentro da Home ou SettingsPage,
      // acessando o estado de autenticação do Firebase.
      home: const Home(),
    );
  }
}

