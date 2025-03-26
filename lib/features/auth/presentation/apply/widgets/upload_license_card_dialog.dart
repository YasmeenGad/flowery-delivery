import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flowery_delivery/core/utils/extension/navigation.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/viewModel/apply_form_view_model.dart';
import 'package:flutter/material.dart';

class UploadLicenseCardDialog extends StatefulWidget {
  

    const UploadLicenseCardDialog({super.key});

  @override
  State<UploadLicenseCardDialog> createState() => _UploadLicenseCardDialogState();
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
    return  DocumentCameraFrame(
      // Document frame dimensions
      frameWidth: 300.0,
      frameHeight: 200.0,

      // Title displayed at the top
      title: const Text(
        'Capture Your Document',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Show Close button
      showCloseButton: true,

      // Callback when the document is captured
      onCaptured: (imgPath) {
        debugPrint('Captured image path: $imgPath');
      },

      // Callback when the document is saved
      onSaved: (imgPath) {

        if (imgPath != null) {
          _applyFormViewModel.pickCardId(imgPath);

        }
        if (_applyFormViewModel.imagePath.isNotEmpty) {
          debugPrint('Saved image path 2: ${_applyFormViewModel.imagePath}');
          context.pop();
        }  

      },

      // Callback when the retake button is pressed
      onRetake: () {
        debugPrint('Retake button pressed');
      },

      // Optional: Customize Capture button, Save button, etc. if needed
    );
  }
}
