import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _itens = [];

  void _carregarItens(){
    _itens = [];
    for(int i=0; i<=10; i++){
      Map<String, dynamic> item = Map();
      item["titulo"] = "Titulo ${i} da ficha";
      item["descricao"]="Descrição ${i} da ficha";
      item["imagem"] = "https://via.placeholder.com/150";  // Imagem de exemplo
      _itens.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    _carregarItens();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFF4d346b),  // Cor do AppBar
        title: Align(  // Centraliza o logo
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'images/logo.jpeg',  // Coloque o caminho para a sua imagem aqui
            height: 80,  // Ajuste o tamanho conforme necessário
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu, size: 50,),
            color: Colors.white,
            onPressed: () {
              print("Menu clicado");
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Color(0xFF5D3A9B),  // Cor de fundo do body
        child: ListView.builder(
            itemCount: _itens.length,
            itemBuilder: (context, indice) {
              return Card(
                elevation: 5,  // Sombra da borda do card
                margin: EdgeInsets.only(bottom: 20),  // Espaço entre os cards
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),  // Borda arredondada
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Imagem
                      // Imagem de perfil
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'images/profile.jpeg',  // Caminho correto para a imagem na pasta images
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10),  // Espaço entre a imagem e o texto
                      // Conteúdo do card
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Text(
                              _itens[indice]["titulo"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            // Descrição
                            Text(
                              _itens[indice]["descricao"],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 10),
                            // Mais opções e botão "Entrar"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Mais opções
                                TextButton(
                                  onPressed: () {
                                    print("Mais opções clicadas para o item $indice");
                                  },
                                  child: Text(
                                    "Mais opções",
                                    style: TextStyle(color: Color(0xFF5D3A9B)),
                                  ),
                                ),
                                // Botão Entrar
                                ElevatedButton(
                                  onPressed: () {
                                    print("Entrar no item $indice");
                                  },
                                  child: Text("Entrar", style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,  // Cor do botão
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
