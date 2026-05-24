import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tflite_service.dart';

TFLiteService getTFLiteService(Ref ref) {
  return _TFLiteServiceUnsupported();
}

class _TFLiteServiceUnsupported implements TFLiteService {
  @override
  Future<void> loadModel() async {}

  @override
  Future<DiagnosisResult> classify(String imagePath) async {
    throw UnsupportedError('TFLite inference is not supported on the web.');
  }

  @override
  void dispose() {}
}
