import 'dart:io'; // ✅ Import File class for images

class MassegesEntities {
  final String massege;
  final bool isSender;
  final File? image; // ✅ Add image field (nullable)

  MassegesEntities({
    required this.massege,
    required this.isSender,
    this.image, // ✅ Image is optional
  });
}
