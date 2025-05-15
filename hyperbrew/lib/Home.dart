import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'DetalhesFicha.dart';
import 'PlayerProfile.dart';
import 'NotesPage.dart';
import 'SecaoPage.dart';
import 'SettingsPage.dart';
import 'DiceRoller.dart';
import 'CreateFicha.dart';
import 'FichaDataBase.dart';
import 'FichaModel.dart';

class CustomFabLocation1 extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(scaffoldGeometry.scaffoldSize.width/10, scaffoldGeometry.scaffoldSize.height - 150);
  }
}

class CustomFabLocation2 extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(scaffoldGeometry.scaffoldSize.width / 2 - scaffoldGeometry.floatingActionButtonSize.width / 2,
        scaffoldGeometry.scaffoldSize.height - 150);
  }
}

class CustomFabLocation3 extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width - scaffoldGeometry.scaffoldSize.width/10,
        scaffoldGeometry.scaffoldSize.height - 150);
  }
}

class TriangleNotchedShape extends NotchedShape {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) {
      return Path()..addRect(host);
    }

    final double notchWidth = guest.width;
    final double notchHeight = -guest.height / 2.5;

    final Path path = Path()
      ..moveTo(host.left, host.top)
      ..lineTo(guest.center.dx - notchWidth / 2, host.top)
      ..lineTo(guest.center.dx, host.top - notchHeight) // Triangle peak
      ..lineTo(guest.center.dx + notchWidth / 2, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();

    return path;
  }
}
class NotchedBackgroundPainter extends CustomPainter {
  Size middleOffset = const Size(0, 30);
  final Offset notchOffset;

  NotchedBackgroundPainter(this.notchOffset);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Color(0xFF6F7684);

    final path = Path()
      ..moveTo(0, size.height + 50)
      ..lineTo(size.width, size.height + 50)
      ..lineTo(size.width, size.height - 10 )
      ..lineTo(size.width / 2 + 40 + notchOffset.dx, size.height - 10 )
      ..quadraticBezierTo(
        size.width / 2 + notchOffset.dx,
        size.height + 30 + notchOffset.dy, // Move the notch downward
        size.width / 2 - 40 + notchOffset.dx,
        size.height -10,
      )
      ..lineTo(0, size.height - 10 )
      ..close();

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as NotchedBackgroundPainter).notchOffset != notchOffset;
  }

}

class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2A2A31)
      ..style = PaintingStyle.fill;

    final double width = size.width ;
    final double height = size.height ;

    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = (width < height ? width : height);

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (2 * pi / 8) * i;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _notchAnimation;
  List<Ficha> _fichas = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _carregarFichas();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize the animation with a dummy tween
    _notchAnimation = Tween<Offset>(
      begin: _notchOffset,
      end: _notchOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          _notchOffset = _notchAnimation.value;
        });
      });
  }

  void _animateToNewOffset(Offset newOffset) {
    // Update the animation range
    _notchAnimation = Tween<Offset>(
      begin: Offset(newOffset.dx, -31),
      end: newOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start the animation
    _controller.forward(from: 0);
  }

  Future<void> _carregarFichas() async {
    print('Carregando fichas...');
    final fichas = await FichaDatabase.instance.readAllFichas();
    print('Fichas carregadas: ${fichas.length}');
    setState(() {
      _fichas = fichas;
    });
  }

  Future<void> _atualizarFicha(Ficha ficha) async {
    await FichaDatabase.instance.update(ficha);
    await _carregarFichas();
  }

  void _editarFichaModal(Ficha ficha) {
    final nomeCtrl = TextEditingController(text: ficha.nome);
    final classeCtrl = TextEditingController(text: ficha.classe);
    final racaCtrl = TextEditingController(text: ficha.raca);
    String? novaImagem = ficha.imagemPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2A31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Editar Ficha", style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setModalState(() => novaImagem = picked.path);
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: (novaImagem != null && File(novaImagem!).existsSync())
                      ? FileImage(File(novaImagem!))
                      : const AssetImage('images/profile.jpeg') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _input("Nome", nomeCtrl),
              _input("Classe", classeCtrl),
              _input("Raça", racaCtrl),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  ficha.nome = nomeCtrl.text;
                  ficha.classe = classeCtrl.text;
                  ficha.raca = racaCtrl.text;
                  ficha.imagemPath = novaImagem ?? "";

                  await _atualizarFicha(ficha);  // Salva no banco
                  Navigator.pop(context);
                },
                child: const Text("Salvar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F7684),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex != 2) return null;
    return AppBar(
      title: const Text(
        'HYPERBREW',
        style: TextStyle(color: Color(0xFFFF3A3A), fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF2A2A31),
      iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(3.0),
        child: Divider(
          color: Color(0xFFFF3A3A),
          thickness: 5,
          height: 3,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFFEAF8FF)),
          onSelected: (value) {
            if (value == 'perfil') setState(() => _selectedIndex = 0);
            if (value == 'config') setState(() => _selectedIndex = 4);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'perfil', child: Text("Perfil do Jogador")),
            const PopupMenuItem(value: 'config', child: Text("Configurações")),
          ],
        )
      ],
    );
  }


  FloatingActionButtonLocation _currentLocation = CustomFabLocation2();
  Offset _notchOffset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const PlayerProfile(),
      const NotesPage(),
      _buildFichasView(),
      const DiceRoller(),
      const SettingsPage(),
    ];

    final List<IconData> _icon = [
      Icons.person,
      Icons.note,
      Icons.play_arrow,
      Icons.casino,
      Icons.settings,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned.fill(
            bottom: 0,
            top: 600,
            child: CustomPaint(
              painter: NotchedBackgroundPainter(_notchOffset),
            ),
          ),
          _selectedIndex == 2 ?
          Positioned(
            top: 520,
            left: 240,
            width: 100,
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F7684),
                  foregroundColor: const Color(0xFFEAF8FF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateFicha()),
                  );
                  await _carregarFichas();
                },
                child: const Icon(Icons.add_rounded, color: Color(0xFFFF3A3A), size: 30,))
          ): const SizedBox(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: const Color(0xFF2A2A31),
        shape: TriangleNotchedShape(),
        notchMargin: 5.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _selectedIndex == 1 ? const SizedBox(width: 50) :
            IconButton(
              icon: const Icon(Icons.note, color: Color(0xFF6F7684)),
              onPressed: () => setState(() {
                _selectedIndex = 1;
                _currentLocation = CustomFabLocation1();
                _animateToNewOffset(const Offset(-110, 0));
              }),
            ),
            _selectedIndex == 2 ? const SizedBox(width: 45) :
            IconButton(
              icon: const Icon(Icons.add_box, color: Color(0xFF6F7684)),
              onPressed: () => setState(() {
                _selectedIndex = 2;
                _currentLocation = CustomFabLocation2();
                _animateToNewOffset(const Offset(0, 0));
              }),
            ),
            _selectedIndex == 3 ? const SizedBox(width: 45) :
            IconButton(
              icon: const Icon(Icons.casino, color: Color(0xFF6F7684)),
              onPressed: () => setState(() {
                _selectedIndex = 3;
                _currentLocation = CustomFabLocation3();
                _animateToNewOffset(const Offset(110, 0));
              }),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: _currentLocation,
      floatingActionButton: Container(
          width: 70,
          height: 70,
          child: FittedBox( child:  FloatingActionButton(
            backgroundColor: const Color(0xFF6F7684),
            foregroundColor: const Color(0xFFEAF8FF),
            shape: const CircleBorder(),
            onPressed: () async {
              if(_selectedIndex == 2){
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecaoPage()),
                );
              }
            },
            child:CustomPaint(
              size: const Size(100, 100),
              painter: HexagonPainter(),
              child: Icon(_icon[_selectedIndex], color: Color(0xFFFF3A3A),),
            ),
          )
          )
      ),
    );
  }

  Widget _buildFichasView() {
    return _fichas.isEmpty
        ? const Center(child: Text("Nenhuma ficha criada ainda.", style: TextStyle(color: Colors.black54)))
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fichas.length,
      itemBuilder: (context, i) {
        final ficha = _fichas[i];
        final imagemPath = ficha.imagemPath;
        final temImagemValida = imagemPath != null && File(imagemPath).existsSync();

        return Card(
          color: const Color(0xFF2A2A31),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: temImagemValida
                  ? FileImage(File(imagemPath))
                  : const AssetImage('images/profile.jpeg') as ImageProvider,
            ),
            title: Text(
              ficha.nome ?? "Sem nome",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${ficha.classe ?? "Classe indefinida"} - ${ficha.raca ?? "Raça indefinida"}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFFEAF8FF)),
              onSelected: (value) {
                if (value == 'editar') {
                  _editarFichaModal(ficha);
                } else if (value == 'ver') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesFicha(ficha: Ficha.fromMap(ficha.toMap())),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'ver', child: Text("Visualizar")),
                const PopupMenuItem(value: 'editar', child: Text("Editar")),
              ],
            ),
          ),
        );
      },
    );
  }
}
