import 'dart:io';

void main() {
  var bytes = File('assets/models/agridx_model.tflite').readAsBytesSync();
  var string = String.fromCharCodes(bytes.where((b) => b >= 32 && b <= 126));
  
  print('Strings found in model:');
  var words = string.split(RegExp(r'\s+'));
  for (var w in words) {
    if (w.length > 5 && RegExp(r'[a-zA-Z]').hasMatch(w)) {
      if (w.contains('quantized') || w.contains('float') || w.contains('MobileNet') || w.contains('ResNet')) {
        print(w);
      }
    }
  }
}
