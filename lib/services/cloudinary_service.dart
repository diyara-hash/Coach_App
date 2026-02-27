import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'dyacl5n2m',
    'mycoach_unsigned',
    cache: false,
  );

  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> uploadFile({
    required String userId,
    required FilePickerResult fileResult,
    required String fileType,
  }) async {
    try {
      final platformFile = fileResult.files.first;

      if (platformFile.path == null) {
        // ignore: avoid_print
        print('HATA: Dosya yolu bulunamadı.');
        return null;
      }

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          platformFile.path!,
          folder: 'mycoach/$userId',
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      final String docId = DateTime.now().millisecondsSinceEpoch.toString();

      final Map<String, dynamic> fileData = {
        'id': docId,
        'name': platformFile.name,
        'url': response.secureUrl,
        'publicId': response.publicId,
        'size': platformFile.size,
        'type': fileType,
        'uploadedAt': FieldValue.serverTimestamp(),
        'storage': 'cloudinary',
      };

      await _firestore
          .collection('athletes')
          .doc(userId)
          .collection('crm_files')
          .doc(docId)
          .set(fileData);

      return fileData;
    } on CloudinaryException catch (e) {
      // ignore: avoid_print
      print('Cloudinary API Hatası: ${e.message} (Kod: ${e.statusCode})');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Dosya Yükleme Hatası: $e');
      return null;
    }
  }

  Future<bool> deleteFile({
    required String userId,
    required String docId,
    required String publicId,
  }) async {
    try {
      // NOT: cloudinary_public paketi istemci tarafında silme (delete) işlemini desteklemez.
      // Silme işlemi için normalde bir backend veya signed request gerekir.
      // Bu yüzden şimdilik sadece Firestore kaydını siliyoruz.

      // 1. Firestore'dan sil
      await _firestore
          .collection('athletes')
          .doc(userId)
          .collection('crm_files')
          .doc(docId)
          .delete();

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Dosya silme hatası: $e');
      return false;
    }
  }
}
