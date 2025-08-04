import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  /// Menyimpan gambar ke direktori aplikasi yang konsisten
  Future<String> saveImageToAppDirectory(
    String originalPath,
    String imageType,
  ) async {
    try {
      // Buat direktori untuk gambar jika belum ada
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/visit_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Generate nama file yang unik
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${imageType}_$timestamp.jpg';
      final savedPath = '${imageDir.path}/$fileName';

      // Copy file dari path asli ke direktori aplikasi
      final originalFile = File(originalPath);
      final savedFile = await originalFile.copy(savedPath);

      print('Image saved successfully: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      print('Error saving image: $e');
      // Jika gagal, gunakan path asli
      return originalPath;
    }
  }

  /// Mengambil gambar dengan kompresi yang optimal
  Future<File?> pickAndSaveImage({
    required ImageSource source,
    required String imageType,
    int maxWidth = 800,
    int maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      // Simpan ke direktori aplikasi
      final savedPath = await saveImageToAppDirectory(
        pickedFile.path,
        imageType,
      );
      return File(savedPath);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Mengecek apakah file gambar ada
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      print('Error checking image existence: $e');
      return false;
    }
  }

  /// Menghapus gambar dari penyimpanan
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('Image deleted: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Membersihkan cache gambar lama
  Future<void> cleanOldImages({int daysOld = 7}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/visit_images');

      if (!await imageDir.exists()) return;

      final files = imageDir.listSync();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            print('Deleted old image: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning old images: $e');
    }
  }

  /// Mendapatkan path direktori gambar
  Future<String> getImageDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/visit_images';
  }

  /// Mendapatkan ukuran file gambar
  Future<int> getImageFileSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return 0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }
}
