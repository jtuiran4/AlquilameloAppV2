import 'package:image_picker/image_picker.dart';

abstract class ImageKitDataSource {
  Future<String> uploadImage(XFile imageFile);
}