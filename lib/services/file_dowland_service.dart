// ignore_for_file: avoid_print

import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class FileDownloadService {
  /// Dosyayı indir ve aç
  Future<void> downloadAndOpenFile(String url, String fileName) async {
    try {
      print('İndiriliyor: $fileName');

      // İzin kontrolü (Android 10+ için)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Depolama izni reddedildi');
          return;
        }
      }

      // İndirme konumu
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Dosya varsa sil (üzerine yazmak için)
      if (await file.exists()) {
        await file.delete();
      }

      // İndir
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('İndirildi: $filePath');

        // Dosyayı aç
        final result = await OpenFile.open(filePath);
        print('Açıldı: ${result.message}');
      } else {
        print('İndirme hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('İndirme hatası: $e');
    }
  }

  /// Sadece indir (açma)
  Future<String?> downloadFile(String url, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('İndirildi: $filePath');
        return filePath;
      }

      return null;
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }
}
