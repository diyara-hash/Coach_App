import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../models/athlete.dart';
import 'package:intl/intl.dart';

class PdfReportGenerator {
  static Future<void> generateAndShareReport({
    required Athlete athlete,
    required Map<String, dynamic> crmProfile,
    required List<Map<String, dynamic>> notes,
    required List<Map<String, dynamic>> measurements,
    bool share = true,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );

    // Load assets (Logo) - assumes there is an asset at lib/assets/images/logo.png
    // If not found, it won't crash but will just not show the image or we can use a placeholder.
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('lib/assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Ignored if logo missing
    }

    _buildCoverPage(pdf, athlete, logoImage);
    _buildSummaryPage(pdf, athlete, crmProfile);
    _buildMeasurementsPage(pdf, measurements);
    _buildCoachNotesPage(pdf, notes);
    _buildNutritionAndGoalsPage(pdf, crmProfile);
    _buildClosingPage(pdf, logoImage);

    // Save PDF
    final output = await getTemporaryDirectory();
    final fileName = '${athlete.name.replaceAll(' ', '_')}_Gelisim_Raporu.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    if (share) {
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '${athlete.name} - Gelişim Raporu');
    } else {
      await OpenFile.open(file.path);
    }
  }

  // Sayfa 1: Kapak
  static void _buildCoverPage(
    pw.Document pdf,
    Athlete athlete,
    pw.MemoryImage? logoImage,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(32),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0F172A), // Dark slate
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoImage != null) pw.Image(logoImage, width: 150),
                pw.SizedBox(height: 100),
                pw.Text(
                  'GELİŞİM RAPORU',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 50,
                  height: 4,
                  color: PdfColor.fromInt(0xFF10B981),
                ), // Emerald
                pw.SizedBox(height: 40),
                pw.Text(
                  athlete.name.toUpperCase(),
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 24),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  DateFormat('dd MMMM yyyy').format(DateTime.now()),
                  style: const pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 16,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'MyCoach Özel Raporlama Sistemi',
                  style: const pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Sayfa 2: Özet
  static void _buildSummaryPage(
    pw.Document pdf,
    Athlete athlete,
    Map<String, dynamic> profile,
  ) {
    final personal = profile['personal'] ?? {};
    final health = profile['health'] ?? {};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('ÖĞRENCİ PROFİLİ VE GENEL BAKIŞ'),
              pw.SizedBox(height: 30),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildInfoCard('KİŞİSEL BİLGİLER', [
                      'Yaş: ${personal['age'] ?? '-'}',
                      'Meslek: ${personal['job'] ?? '-'}',
                      'Hedef: ${personal['goal'] ?? '-'}',
                      'Seviye: ${personal['level'] ?? '-'}',
                    ]),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildInfoCard('SAĞLIK DURUMU', [
                      'Sakatlıklar: ${health['injuries'] ?? 'Yok'}',
                      'Kronik Rahatsızlık: ${(health['diseases'] as List?)?.join(", ") ?? 'Yok'}',
                      'Kullanılan İlaçlar: ${health['medications'] ?? 'Yok'}',
                      'Doktor Onayı: ${health['doctorApproved'] == true ? 'Var' : 'Yok'}',
                    ]),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Sayfa 3: Ölçümler (Tablo)
  static void _buildMeasurementsPage(
    pw.Document pdf,
    List<Map<String, dynamic>> measurements,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          if (measurements.isEmpty) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader('FİZİKSEL ÖLÇÜM GEÇMİŞİ'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Kayıtlı ölçüm bulunmamaktadır.',
                  style: pw.TextStyle(color: PdfColors.grey600),
                ),
              ],
            );
          }

          final tableHeaders = ['Tarih', 'Kilo', 'Bel', 'Kalça', 'Göğüs'];
          final tableData = measurements.map((m) {
            final dateRaw = m['submittedAt'];
            final date = dateRaw != null
                ? DateFormat('dd/MM/yyyy').format(
                    DateTime.tryParse(dateRaw.toString()) ?? DateTime.now(),
                  )
                : '-';
            return [
              date,
              '${m['weight'] ?? '-'} kg',
              '${m['waist'] ?? '-'} cm',
              '${m['hips'] ?? '-'} cm',
              '${m['chest'] ?? '-'} cm',
            ];
          }).toList();

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('FİZİKSEL ÖLÇÜM GEÇMİŞİ'),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF10B981),
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                cellPadding: const pw.EdgeInsets.all(8),
              ),
            ],
          );
        },
      ),
    );
  }

  // Sayfa 4: Notlar
  static void _buildCoachNotesPage(
    pw.Document pdf,
    List<Map<String, dynamic>> notes,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('KOÇ DEĞERLENDİRMELERİ'),
              pw.SizedBox(height: 30),
              if (notes.isEmpty)
                pw.Text(
                  'Not bulunmamaktadır.',
                  style: const pw.TextStyle(color: PdfColors.grey600),
                ),
              ...notes.map((note) {
                final dateRaw = note['date'];
                final date = dateRaw != null
                    ? DateFormat('dd/MM/yyyy').format(
                        DateTime.tryParse(dateRaw.toString()) ?? DateTime.now(),
                      )
                    : '-';
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF1F5F9), // Slate 50
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: note['priority'] == true
                            ? PdfColors.orange
                            : PdfColor.fromInt(0xFF10B981),
                        width: 4,
                      ),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        date,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        note['content'] ?? '',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // Sayfa 5: Beslenme ve Hedefler
  static void _buildNutritionAndGoalsPage(
    pw.Document pdf,
    Map<String, dynamic> profile,
  ) {
    final nutrition = profile['nutrition'] ?? {};
    final goals = profile['goals'] ?? {};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('BESLENME & HEDEFLER'),
              pw.SizedBox(height: 30),

              pw.Text(
                'BESLENME TERCİHLERİ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Diyet Tipi: ${nutrition['dietType'] ?? '-'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Alerjiler: ${nutrition['allergies'] ?? 'Yok'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Sevilmeyenler: ${nutrition['dislikes'] ?? 'Yok'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Su Hedefi: ${nutrition['waterTarget'] ?? '-'} Litre',
                style: const pw.TextStyle(fontSize: 12),
              ),

              pw.SizedBox(height: 30),
              pw.Text(
                'ANTRENMAN HEDEFLERİ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 10),

              _buildGoalItem('Kısa Vadeli (1 Ay)', goals['short']),
              _buildGoalItem('Orta Vadeli (3 Ay)', goals['medium']),
              _buildGoalItem('Uzun Vadeli (6 Ay)', goals['long']),
            ],
          );
        },
      ),
    );
  }

  // Sayfa 6: Kapanış
  static void _buildClosingPage(pw.Document pdf, pw.MemoryImage? logoImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(32),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0F172A),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoImage != null) pw.Image(logoImage, width: 100),
                pw.SizedBox(height: 40),
                pw.Text(
                  'TEBRİKLER',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Hedeflerinize ulaşmak için gösterdiğiniz çabayı takdir ediyoruz.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(color: PdfColors.grey400, fontSize: 16),
                ),
                pw.SizedBox(height: 100),
                pw.Container(
                  width: 50,
                  height: 4,
                  color: PdfColor.fromInt(0xFF10B981),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'MyCoach Elite',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                  ),
                ),
                pw.Text(
                  'Sizin Başarınız, Bizim Gururumuz',
                  style: const pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Methods
  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF0F172A),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(width: 40, height: 4, color: PdfColor.fromInt(0xFF10B981)),
      ],
    );
  }

  static pw.Widget _buildInfoCard(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8FAFC), // Slate 50
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0)), // Slate 200
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              color: PdfColor.fromInt(0xFF64748B),
            ),
          ), // Slate 500
          pw.SizedBox(height: 12),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                item,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromInt(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGoalItem(String label, Map? goalData) {
    final title = goalData?['title'] ?? '-';
    final isCompleted = goalData?['completed'] == true;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromInt(0xFF64748B),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
          if (isCompleted)
            pw.Text(
              'TAMAMLANDI',
              style: pw.TextStyle(
                color: PdfColor.fromInt(0xFF10B981),
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            )
          else
            pw.Text(
              'DEVAM EDİYOR',
              style: pw.TextStyle(
                color: PdfColor.fromInt(0xFFF59E0B),
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
