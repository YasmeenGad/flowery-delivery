import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApplyFormViewModel {
  List<dynamic> countries = [];
  String? selectedCountry;
  ValueNotifier<String> licenseCardPath = ValueNotifier('');
  List<String> licenseCardData = [];
  List<String> cardIdData = [];
  ValueNotifier<String> cardIdPath = ValueNotifier('');

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

  String pickCardId(String cardId) {
    cardIdPath.value = cardId;
    return cardIdPath.value;
  }

  String pickLicenseCard(String license) {
    licenseCardPath.value = license;
    return licenseCardPath.value;
  }

  Future<String?> getLicenseCardDataFromImagePath(String imagePath) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final inputImage = InputImage.fromFile(File(imagePath));
    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    licenseCardData = text.split('\n');
    textRecognizer.close();
    debugPrint(' Text recognized : $licenseCardData');
    return text;
  }

  // Future<List<String>> extractArabicCardId(String imagePath) async {
  //   try {
  //     // 1. Verify assets exist before proceeding
  //     await _verifyTessdataAssets();
  //
  //     // 2. Set up directories
  //     final dir = await getApplicationDocumentsDirectory();
  //     final tessdataDir = Directory('${dir.path}/tessdata');
  //
  //     if (!await tessdataDir.exists()) {
  //       await tessdataDir.create(recursive: true);
  //     }
  //
  //     // 3. Copy language data
  //     final trainedDataFile = File('${tessdataDir.path}/ara.traineddata');
  //     if (!await trainedDataFile.exists()) {
  //       final data = await rootBundle.load('assets/tessdata/ara.traineddata');
  //       await trainedDataFile.writeAsBytes(data.buffer.asUint8List());
  //     }
  //
  //     // 4. Run OCR with optimized parameters
  //     final text = await FlutterTesseractOcr.extractText(
  //       imagePath,
  //       language: 'ara',
  //       args: {
  //         "tessdata_path": dir.path,
  //         "preserve_interword_spaces": "1",
  //         "psm": "6", // Assume single text block
  //         "oem": "1", // LSTM engine only
  //       },
  //     );
  //     cardIdData = text.split('\n');
  //     return cardIdData;
  //   } catch (e) {
  //     debugPrint('OCR Error: ${e.toString()}');
  //     throw Exception(
  //         'Failed to process ID card. Please ensure clear image of Arabic text.');
  //   }
  // }
  //
  // Future<void> _verifyTessdataAssets() async {
  //   try {
  //     // Verify config file exists
  //     await rootBundle.load('assets/tessdata_config.json');
  //
  //     // Verify language file exists
  //     await rootBundle.load('assets/tessdata/ara.traineddata');
  //   } catch (e) {
  //     throw Exception(
  //         'Missing OCR assets. Please ensure both tessdata_config.json and ara.traineddata exist in assets folder.');
  //   }
  // }

  /// مسح نص عربي من صورة باستخدام Google Cloud Vision API

  Future<Map<String, dynamic>> scanEgyptianIdCard(String imagePath) async {
    final apiKey = dotenv.get('GOOGLE_CLOUD_VISION_API_KEY');
    final baseUrl = dotenv.get('GOOGLE_CLOUD_VISION_BASE_URL');

    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('$baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION'}
            ],
            'imageContext': {
              'languageHints': ['ar']
            }
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final String text = result['responses'][0]['fullTextAnnotation']?['text'] ?? '';

      if (text.trim().isEmpty) {
        return {
          'error': 'لم يتم العثور على نص.',
        };
      }

      final lines = text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      // الترجمة باستخدام ML Kit
      final onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.arabic,
        targetLanguage: TranslateLanguage.english,
      );

// تأكد من تنزيل الحزمة إن لم تكن موجودة
      final modelManager = OnDeviceTranslatorModelManager();
      final languageCode = TranslateLanguage.arabic.bcpCode;

      final hasModel = await modelManager.isModelDownloaded(languageCode);
      if (!hasModel) {
        await modelManager.downloadModel(languageCode);
      }


      for (String line in lines) {
        cardIdData.add(await onDeviceTranslator.translateText(line));
        // await onDeviceTranslator.translateText(line);
      }

      await onDeviceTranslator.close();

      debugPrint(' Text recognized : $lines');
      debugPrint(' Text translated : $cardIdData');
      // استخراج البيانات
      // final name = _extractName(lines);
      // final address = _extractAddress(lines);
      final nationalId = _extractNationalId(cardIdData,lines);
// debugPrint(' name : $name');
//       debugPrint(' address : $address');
      debugPrint(' nationalId : $nationalId');
      // // // الترجمة
      // final translator = GoogleTranslator();
      // final translation = await translator.translate(text, from: 'ar', to: 'en');

      return {
        // 'name': name,
        // 'address': address,
        'national_id': nationalId,
        'translated_text': cardIdData,
        'raw_lines': lines,
      };
    } else {
      throw Exception(
          'فشل الاتصال: ${response.statusCode} - ${response.body}');
    }
  }



  String? _extractNationalId(List<String> translatedLines, List<String> originalLines) {


    // // 2. fallback على النص العربي بعد تحويل الأرقام يدويًا
    const arabicToEnglishDigits = {
      '۰': '0', '٠': '0',
      '۱': '1', '١': '1',
      '۲': '2', '٢': '2',
      '۳': '3', '٣': '3',
      '۴': '4', '٤': '4',
      '۵': '5', '٥': '5',
      '۶': '6', '٦': '6',
      '۷': '7', '٧': '7',
      '۸': '8', '٨': '8',
      '۹': '9', '٩': '9',
    };

    String normalizeArabicDigits(String input) {
      return input.split('').map((c) => arabicToEnglishDigits[c] ?? c).join();
    }

    final originalText = normalizeArabicDigits(originalLines.join(' '));
    final arabicMatch = RegExp(r'بطاقة تحقيق الشخصية.*?(\d{14})').firstMatch(originalText);
    return arabicMatch?.group(1);
  }




  String? _extractName(List<String> lines) {
    for (final line in lines) {
      if (line.contains('بطاقة تحقيق الشخصية')) {
        final index = lines.indexOf(line);
        if (index + 1 < lines.length) {
          final nameLine1 = lines[0].trim();
          final nameLine2 = lines[3].trim();
          return '$nameLine1 $nameLine2';
        } else if (index + 1 < lines.length) {
          return lines[index + 1].trim(); // fallback إذا مفيش سطرين بعده
        }
      }
    }

    // كحل بديل: نبحث عن السطر اللي يحتوي 2 أو 3 كلمات عربية
    for (final line in lines) {
      final arabicWords = line
          .split(' ')
          .where((word) => RegExp(r'^[\u0600-\u06FF]+$').hasMatch(word))
          .toList();
      if (arabicWords.length >= 2 && arabicWords.length <= 4) {
        return line.trim();
      }
    }

    return null;
  }


  String? _extractAddress(List<String> lines) {
    // دور على سطر الاسم (بعد "بطاقة تحقيق الشخصية")
    int? nameIndex;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('بطاقة تحقيق الشخصية') && i + 1 < lines.length) {
        nameIndex = i + 1;
        break;
      }
    }

    // لو لقينا الاسم، نرجّع السطرين اللي بعده كعنوان (لو موجودين)
    if (nameIndex != null && nameIndex + 2 < lines.length) {
      final addressLines = lines.sublist(nameIndex + 1, nameIndex + 3);
      return addressLines.join(', ');
    }

    // fallback: لو ما لقيناش، نستخدم الطريقة القديمة
    for (final line in lines) {
      if (RegExp(r'(ش\.|شارع|حي|الاسكندرية|الجيزة|القاهرة|المنتزه|مدينة|أول|ثان)').hasMatch(line)) {
        return line;
      }
    }

    return null;
  }

}
/// Client مخصص يضيف apiKey تلقائيًا لكل طلب

