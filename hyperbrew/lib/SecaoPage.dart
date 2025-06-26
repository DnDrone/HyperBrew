// lib/SecaoPage.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'FichaModel.dart';
import 'FichaDataBase.dart';
import 'PdfService.dart';


class SecaoPage extends StatefulWidget {
  const SecaoPage({super.key});

  @override
  State<SecaoPage> createState() => _SecaoPageState();
}

class _SecaoPageState extends State<SecaoPage> {
  final _ID = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A31),
        iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
        title: const Text(
          "Entrar em Seção",
          style: TextStyle(
            color: Color(0xFFFF3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: Divider(
            color: Color(0xFFFF3A3A),
            thickness: 5,
            height: 3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildCampo("Id de seção", _ID),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A31),
                  foregroundColor: const Color(0xFFEAF8FF),
                ),
                child: const Text("Buscar seção", style: TextStyle(color: Color(0xFFFF3A3A))),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildCampo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF2A2A31)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF2A2A31)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A2A31)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A2A31), width: 2),
          ),
        ),
      ),
    );
  }
}
