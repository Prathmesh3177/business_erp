import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_text_shaper/pdf_text_shaper.dart';

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('Usage: dart run bin/devanagari_pdf_spike.dart FONT OUTPUT');
    exitCode = 64;
    return;
  }
  final font = ShapedFont.fromBytes(
    await File(args[0]).readAsBytes(),
    name: 'Host Devanagari proof font',
  );
  try {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            ShapedText(
              '\u0938\u094b\u0932\u0930 \u0936\u0949\u092a \u0908\u0906\u0930\u092a\u0940 - \u0926\u0947\u0935\u0928\u093e\u0917\u0930\u0940 \u0906\u0915\u093e\u0930\u0923\u0940 \u091a\u093e\u091a\u0923\u0940',
              style: ShapedTextStyle(font: font, fontSize: 22),
            ),
            pw.SizedBox(height: 18),
            ShapedText(
              '\u0915\u094d\u0937\u092e\u0924\u093e, \u0917\u094d\u0930\u093e\u0939\u0915, \u0935\u093f\u0915\u094d\u0930\u0940 \u092a\u093e\u0935\u0924\u0940, \u0938\u094c\u0930 \u092a\u0902\u092a, \u092e\u0930\u093e\u0920\u0940 \u092e\u091c\u0915\u0942\u0930 \u0906\u0923\u093f \u0938\u0902\u092f\u0941\u0915\u094d\u0924\u093e\u0915\u094d\u0937\u0930\u0947.',
              style: ShapedTextStyle(font: font, fontSize: 16),
            ),
            pw.SizedBox(height: 18),
            ShapedText(
              '\u0930\u0915\u094d\u0915\u092e: \u20b9 \u0967,\u0967\u096e\u0966.\u0966\u0966 | \u0926\u093f\u0928\u093e\u0902\u0915: \u0968\u096b-\u0966\u096f-\u0968\u0966\u0968\u096c',
              style: ShapedTextStyle(font: font, fontSize: 16),
            ),
          ],
        ),
      ),
    );
    final output = File(args[1]);
    output.parent.createSync(recursive: true);
    await output.writeAsBytes(await document.save(), flush: true);
    stdout.writeln(
      'PASS pdf_created=${output.absolute.path} bytes=${output.lengthSync()}',
    );
  } finally {
    font.dispose();
  }
}
