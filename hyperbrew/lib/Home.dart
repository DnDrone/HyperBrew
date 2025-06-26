import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'DetalhesFicha.dart';
import 'LoginPage.dart';
import 'PlayerProfile.dart';
import 'NotesPage.dart' hide CreateFicha;
import 'SecaoPage.dart';
import 'SettingsPage.dart';
import 'DiceRoller.dart';
import 'CreateFicha.dart';
import 'FichaDataBase.dart';
import 'FichaModel.dart';

// Importar Firebase Auth para acessar o usuário atual
import 'package:firebase_auth/firebase_auth.dart';


// Custom FAB Location 1: Posiciona o Floating Action Button no lado esquerdo.
class CustomFabLocation1 extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Calcula o offset para posicionar o FAB no décimo da largura da tela à esquerda.
    return Offset(scaffoldGeometry.scaffoldSize.width/10, scaffoldGeometry.scaffoldSize.height - 150);
  }
}

// Custom FAB Location 2: Posiciona o Floating Action Button no centro inferior.
class CustomFabLocation2 extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Calcula o offset para centralizar o FAB horizontalmente.
    return Offset(scaffoldGeometry.scaffoldSize.width / 2 - scaffoldGeometry.floatingActionButtonSize.width / 2,
        scaffoldGeometry.scaffoldSize.height - 150);
  }
}

// Custom FAB Location 3: Posiciona o Floating Action Button no lado direito.
class CustomFabLocation3 extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Calcula o offset para posicionar o FAB no décimo da largura da tela à direita.
    return Offset(scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width - scaffoldGeometry.scaffoldSize.width/10,
        scaffoldGeometry.scaffoldSize.height - 150);
  }
}

// Forma Entalhada de Triângulo para o BottomAppBar
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
      ..lineTo(guest.center.dx, host.top - notchHeight) // Pico do triângulo
      ..lineTo(guest.center.dx + notchWidth / 2, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();

    return path;
  }
}

// Pintor para o plano de fundo entalhado do BottomAppBar
class NotchedBackgroundPainter extends CustomPainter {
  Size middleOffset = const Size(0, 30); // Offset central (não usado diretamente na lógica, mas pode ser para ajuste)
  final Offset notchOffset; // Offset da entalhe para animação

  NotchedBackgroundPainter(this.notchOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF6F7684); // Cor do plano de fundo

    final path = Path()
      ..moveTo(0, size.height + 50) // Ponto inicial inferior esquerdo
      ..lineTo(size.width, size.height + 50) // Linha para o inferior direito
      ..lineTo(size.width, size.height - 10 ) // Linha para o topo direito
      ..lineTo(size.width / 2 + 40 + notchOffset.dx, size.height - 10 ) // Começa o entalhe
      ..lineTo(0, size.height - 10 ) // Linha de volta para o topo esquerdo
      ..close(); // Fecha o caminho

    canvas.drawPath(path, paint); // Desenha o caminho no canvas
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repinta apenas se o notchOffset mudar para a animação
    return (oldDelegate as NotchedBackgroundPainter).notchOffset != notchOffset;
  }
}

// Pintor para o Hexágono do Floating Action Button
class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A31) // Cor do hexágono
      ..style = PaintingStyle.fill; // Estilo de preenchimento

    final double width = size.width ;
    final double height = size.height ;

    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = (width < height ? width : height); // Calcula o raio baseado na menor dimensão

    final path = Path();
    for (int i = 0; i < 8; i++) { // Desenha um octógono para parecer mais arredondado
      final angle = (2 * pi / 8) * i;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y); // Move para o primeiro ponto
      } else {
        path.lineTo(x, y); // Desenha linha para os pontos seguintes
      }
    }
    path.close(); // Fecha o octógono

    canvas.drawPath(path, paint); // Desenha o octógono no canvas
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Não precisa repintar, pois as propriedades não mudam
  }
}

class Home extends StatefulWidget {
  // O construtor de Home não precisa mais de parâmetros de jogador,
  // pois o login será gerenciado separadamente.
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _notchAnimation;
  List<Ficha> _fichas = [];
  int _selectedIndex = 2; // Índice da página selecionada no BottomNavigationBar

  Offset _notchOffset = const Offset(0, 0); // Offset para a animação do entalhe do BottomAppBar

  @override
  void initState() {
    super.initState();
    // Chame _carregarFichas sempre que a autenticação mudar
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _carregarFichas(); // Recarrega as fichas se o usuário logar/deslogar
      } else {
        setState(() {
          _fichas = []; // Limpa as fichas se não houver usuário logado
        });
      }
    });

    // Inicializa o AnimationController para a animação do entalhe
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Duração da animação
      vsync: this, // Para sincronizar a animação com a tela
    );

    // Inicializa a animação com o offset atual, que será atualizado posteriormente
    _notchAnimation = Tween<Offset>(
      begin: _notchOffset,
      end: _notchOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        // Atualiza o estado para redesenhar o CustomPaint com o novo offset
        setState(() {
          _notchOffset = _notchAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera o controlador da animação
    super.dispose();
  }

  // Anima o entalhe do BottomAppBar para uma nova posição
  void _animateToNewOffset(Offset newOffset) {
    _notchAnimation = Tween<Offset>(
      begin: _notchOffset, // Inicia a animação do offset atual
      end: newOffset, // Vai para o novo offset
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.reset(); // Reseta o controlador para o início
    _controller.forward(); // Inicia a animação
  }

  // Carrega as fichas do banco de dados local
  Future<void> _carregarFichas() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String? userId = currentUser?.uid;

    if (userId != null) {
      print('Carregando fichas para o usuário: $userId');
      final fichas = await FichaDatabase.instance.readAllFichas(userId);
      print('Fichas carregadas: ${fichas.length}');
      setState(() {
        _fichas = fichas; // Atualiza a lista de fichas no estado
      });
    } else {
      print('Nenhum usuário logado. Não carregando fichas.');
      setState(() {
        _fichas = []; // Limpa as fichas se não houver usuário logado
      });
    }
  }

  // Atualiza uma ficha existente no banco de dados
  Future<void> _atualizarFicha(Ficha ficha) async {
    await FichaDatabase.instance.update(ficha);
    await _carregarFichas(); // Recarrega as fichas após a atualização
  }

  // Abre um modal para editar uma ficha
  void _editarFichaModal(Ficha ficha) {
    final nomeCtrl = TextEditingController(text: ficha.nome);
    final classeCtrl = TextEditingController(text: ficha.classe);
    final racaCtrl = TextEditingController(text: ficha.raca);
    String? novaImagem = ficha.imagemPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal seja redimensionado com o teclado
      backgroundColor: const Color(0xFF2A2A31), // Cor de fundo do modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Borda arredondada no topo
      ),
      builder: (_) => StatefulBuilder( // StatefulBuilder para gerenciar o estado do modal
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço vertical possível
            children: [
              const Text("Editar Ficha", style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setModalState(() => novaImagem = picked.path); // Atualiza a imagem selecionada no modal
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: (novaImagem != null && File(novaImagem!).existsSync())
                      ? FileImage(File(novaImagem!)) // Exibe a imagem selecionada
                      : const AssetImage('images/profile.jpeg') as ImageProvider, // Imagem padrão
                ),
              ),
              const SizedBox(height: 20),
              _input("Nome", nomeCtrl), // Campo de entrada para o nome
              _input("Classe", classeCtrl), // Campo de entrada para a classe
              _input("Raça", racaCtrl), // Campo de entrada para a raça
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  ficha.nome = nomeCtrl.text;
                  ficha.classe = classeCtrl.text;
                  ficha.raca = racaCtrl.text;
                  ficha.imagemPath = novaImagem ?? ""; // Salva o caminho da nova imagem

                  await _atualizarFicha(ficha);  // Salva as alterações no banco de dados
                  Navigator.pop(context); // Fecha o modal
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

  // Widget auxiliar para criar campos de texto padronizados
  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white), // Estilo do texto digitado
        decoration: InputDecoration(
          labelText: label, // Rótulo do campo
          labelStyle: const TextStyle(color: Colors.white), // Estilo do rótulo
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Borda quando não selecionado
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2), // Borda quando selecionado
          ),
        ),
      ),
    );
  }

  // Constrói a AppBar da tela Home
  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex != 2) return null; // Apenas mostra a AppBar na aba de Fichas
    return AppBar(
      title: const Text(
        'HYPERBREW',
        style: TextStyle(color: Color(0xFFFF3A3A), fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF2A2A31), // Cor de fundo da AppBar
      iconTheme: const IconThemeData(color: Color(0xFFEAF8FF)), // Cor dos ícones
      bottom: const PreferredSize( // Linha divisória na parte inferior da AppBar
        preferredSize: Size.fromHeight(3.0),
        child: Divider(
          color: Color(0xFFFF3A3A),
          thickness: 5,
          height: 3,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFFEAF8FF)), // Ícone de menu
          onSelected: (value) {
            // Obtém o usuário atual do Firebase Authentication
            final user = FirebaseAuth.instance.currentUser;
            final userId = user?.uid; // ID do usuário (String?)
            final userName = user?.displayName; // Nome de exibição do usuário (String?)

            if (value == 'perfil') {
              // Navega para a tela de Perfil do Jogador, passando os dados do usuário
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerProfile(
                    jogadorId: userId ?? "guest", // Passa o UID ou "guest" se não logado
                    jogadorNome: userName ?? "Convidado", // Passa o nome ou "Convidado"
                  ),
                ),
              );
            }
            if (value == 'config') {
              // Navega para a tela de Configurações, passando os dados do usuário
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    userId: userId, // Passa o UID (pode ser null)
                    userName: userName, // Passa o nome (pode ser null)
                  ),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'perfil', child: Text("Perfil do Jogador")),
            const PopupMenuItem(value: 'config', child: Text("Configurações")),
          ],
        )
      ],
    );
  }

  // Posição inicial do Floating Action Button
  FloatingActionButtonLocation _currentLocation = CustomFabLocation2();

  @override
  Widget build(BuildContext context) {
    // A lista de páginas que serão exibidas
    final List<Widget> _pages = [
      // PlayerProfile agora recebe os dados do usuário do Firebase
      PlayerProfile(
        jogadorId: FirebaseAuth.instance.currentUser?.uid ?? "guest",
        jogadorNome: FirebaseAuth.instance.currentUser?.displayName ?? "Convidado",
      ),
      const NotesPage(), // Página de Notas
      _buildFichasView(), // View das Fichas
      const DiceRoller(), // Rolador de Dados
      // SettingsPage agora recebe os dados do usuário do Firebase
      SettingsPage(
        userId: FirebaseAuth.instance.currentUser?.uid,
        userName: FirebaseAuth.instance.currentUser?.displayName,
      ),
    ];

    // Ícones para o Floating Action Button (usados no CustomPaint)
    final List<IconData> _icon = [
      Icons.person,
      Icons.note,
      Icons.play_arrow,
      Icons.casino,
      Icons.settings,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF), // Cor de fundo do Scaffold
      appBar: _buildAppBar(), // Constrói a AppBar
      body: Stack( // Usa Stack para sobrepor a navegação inferior
        children: [
          _pages[_selectedIndex], // Exibe a página selecionada
          /*
          Positioned.fill(
            bottom: 0,
            top: 0, // Ajuste este valor se o entalhe não estiver aparecendo corretamente

            child: CustomPaint(
              painter: NotchedBackgroundPainter(_notchOffset), // Desenha o fundo entalhado
            ),
          ),
           */
          _selectedIndex == 2 ? // Botão de Adicionar Ficha apenas na tela de Fichas
          Positioned(
            bottom: 20, // Posição vertical do botão
            left: MediaQuery.of(context).size.width * 0.5 - 50,
            width: 100, // Largura
            height: 50, // Altura
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F7684),
                  foregroundColor: const Color(0xFFEAF8FF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () async {
                  // Navega para a tela de criação de ficha
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateFicha()),
                  );
                  await _carregarFichas(); // Recarrega as fichas após criar uma nova
                },
                child: const Icon(Icons.add_rounded, color: Color(0xFFFF3A3A), size: 30,))
          ): const SizedBox(), // Esconde o botão se não for a tela de Fichas
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60, // Altura do BottomAppBar
        color: const Color(0xFF2A2A31), // Cor de fundo
        shape: TriangleNotchedShape(), // Forma do entalhe
        notchMargin: 5.0, // Margem do entalhe
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribui os itens igualmente
          children: [
            // Ícone de Notas
            _selectedIndex == 1 ? const SizedBox(width: 50) : // Espaço extra para o FAB central
            IconButton(
              icon: const Icon(Icons.note, color: Color(0xFF6F7684)),
              onPressed: () => setState(() {
                _selectedIndex = 1; // Seleciona a aba de Notas
                _currentLocation = CustomFabLocation1(); // Posiciona o FAB para a esquerda
                _animateToNewOffset(const Offset(-110, 0)); // Anima o entalhe para a esquerda
              }),
            ),
            // Ícone de Fichas (Central)
            _selectedIndex == 2 ? const SizedBox(width: 45) : // Espaço extra para o FAB central
            IconButton(
              icon: const Icon(Icons.add_box, color: Color(0xFF6F7684)),
              onPressed: () => setState(() {
                _selectedIndex = 2; // Seleciona a aba de Fichas
                _currentLocation = CustomFabLocation2(); // Posiciona o FAB no centro
                _animateToNewOffset(const Offset(0, 0)); // Anima o entalhe para o centro
              }),
            ),
            // Ícone de Dados
            _selectedIndex == 3 ? const SizedBox(width: 45) : // Espaço extra para o FAB central
            IconButton(
              icon: const Icon(Icons.casino, color: Color(0xFF6F7684)),
              onPressed: () => setState(() {
                _selectedIndex = 3; // Seleciona a aba de Dados
                _currentLocation = CustomFabLocation3(); // Posiciona o FAB para a direita
                _animateToNewOffset(const Offset(110, 0)); // Anima o entalhe para a direita
              }),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: _currentLocation, // Localização do Floating Action Button
      floatingActionButton: Container(
          width: 70,
          height: 70,
      ),
    );
  }

  // Constrói a visualização das fichas (lista de Cards)
  Widget _buildFichasView() {
    return _fichas.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  FirebaseAuth.instance.currentUser == null
                      ? "Faça login para gerenciar suas fichas."
                      : "Nenhuma ficha criada ainda.",
                  style: const TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                if (FirebaseAuth.instance.currentUser == null) // Adicionar um botão para login se não estiver logado
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        ).then((_) => _carregarFichas()); // Recarrega as fichas após voltar da LoginPage
                      },
                      child: const Text("Fazer Login"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A31),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fichas.length,
      itemBuilder: (context, i) {
        final ficha = _fichas[i];
        final imagemPath = ficha.imagemPath;
        final temImagemValida = imagemPath != null && File(imagemPath).existsSync();

        return Card(
          color: const Color(0xFF2A2A31), // Cor do card
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: temImagemValida
                  ? FileImage(File(imagemPath)) // Imagem da ficha
                  : const AssetImage('images/profile.jpeg') as ImageProvider, // Imagem padrão
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
                  _editarFichaModal(ficha); // Edita a ficha
                } else if (value == 'ver') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesFicha(ficha: Ficha.fromMap(ficha.toMap())), // Visualiza detalhes
                    ),
                  );
                } else if (value == 'excluir') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Excluir Ficha"),
                      content: const Text("Você tem certeza que deseja excluir esta ficha?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Fecha o diálogo
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FichaDatabase.instance.delete(ficha.id!); // Exclui a ficha do banco de dados
                            await _carregarFichas(); // Recarrega as fichas
                            Navigator.pop(context); // Fecha o diálogo
                          },
                          child: const Text("Excluir"),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'ver', child: Text("Visualizar")),
                const PopupMenuItem(value: 'editar', child: Text("Editar")),
                const PopupMenuItem(value: 'excluir', child: Text("Excluir")),
              ],
            ),
          ),
        );
      },
    );
  }
}
