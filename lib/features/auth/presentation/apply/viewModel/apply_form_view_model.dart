import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ApplyFormViewModel {
  List<dynamic> countries = [];
  String? selectedCountry;
  String imagePath = '';

  Future<void> loadCountries() async {
    final String response =
        await rootBundle.loadString('assets/files/country.json');
    final List<dynamic> data = json.decode(response);
    countries = data;
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }
  Future<File?> pickCardId(String cardId) async {
    imagePath = cardId;
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return imagePath != null ? File(imagePath) : null;
  }
}
