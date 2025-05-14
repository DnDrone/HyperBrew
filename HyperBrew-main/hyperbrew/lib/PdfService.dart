import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'FichaModel.dart';

class PdfService {
  /// Gera um PDF a partir de uma Ficha e retorna o arquivo salvo
  static Future<File> gerarPdfFicha(Ficha ficha) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ficha de Personagem', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('ID: ${ficha.id}'),
            pw.Text('Nome: ${ficha.nome}'),
            pw.Text('Classe: ${ficha.classe}'),
            pw.Text('Raça: ${ficha.raca}'),
            if (ficha.imagemPath.isNotEmpty)
              pw.Column(
                children: [
                  pw.SizedBox(height: 20),
                  pw.Text('Imagem:'),
                  pw.Image(pw.MemoryImage(File(ficha.imagemPath).readAsBytesSync())),
                ],
              ),
          ],
        ),
      ),
    );

    // Obtém diretório de documentos
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ficha.nome}_ficha.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}