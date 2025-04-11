// ignore_for_file: unused_field

import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/viewModel/apply_form_view_model.dart';
import 'package:flutter/material.dart';

class UploadLicenseCardDialog extends StatefulWidget {
  final Function(String imagePath) onSaved;

  const UploadLicenseCardDialog({super.key, required this.onSaved});

  @override
  State<UploadLicenseCardDialog> createState() =>
      _UploadLicenseCardDialogState();
}

class _UploadLicenseCardDialogState extends State<UploadLicenseCardDialog> {
  late ApplyFormViewModel _applyFormViewModel;

  @override
  void initState() {
    super.initState();
    _applyFormViewModel = ApplyFormViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return DocumentCameraFrame(
      frameWidth: 300.0,
      frameHeight: 200.0,
      title: const Text(
        'Align Your ID Card Within the Frame',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      onCaptured: (path) {
        debugPrint('Captured image at: $path');
      },
      onSaved: (path) async {
        // debugPrint('Saved image at: $path');
        // final file = File(path);
        // final size = await file.length();
        // debugPrint('Image size: ${size / 1024} KB'); // Check file size
        widget.onSaved(path);
      },
      onRetake: () {
        debugPrint('Retaking photo');
      },
    );
  }
}
