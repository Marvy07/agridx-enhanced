import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

void main() {
  test('Analyze TFLite model', () async {
    final interpreter = Interpreter.fromFile(File('assets/models/agridx_model.tflite'));
    
    final inputTensor = interpreter.getInputTensor(0);
    print('Input Name: ${inputTensor.name}');
    print('Input Shape: ${inputTensor.shape}');
    print('Input Type: ${inputTensor.type}'); // Float32 or Uint8
    
    final outputTensor = interpreter.getOutputTensor(0);
    print('Output Name: ${outputTensor.name}');
    print('Output Shape: ${outputTensor.shape}');
    print('Output Type: ${outputTensor.type}');

    // Try a dummy run
    var isQuantized = inputTensor.type == TensorType.uint8;
    int size = inputTensor.shape[1]; // e.g. 224

    dynamic input;
    if (isQuantized) {
      input = List.generate(1, (_) => List.generate(size, (_) => List.generate(size, (_) => [128, 128, 128])));
    } else {
      input = List.generate(1, (_) => List.generate(size, (_) => List.generate(size, (_) => [0.5, 0.5, 0.5])));
    }

    dynamic output;
    if (outputTensor.type == TensorType.uint8) {
      output = List.generate(1, (_) => List.filled(outputTensor.shape[1], 0));
    } else {
      output = List.generate(1, (_) => List.filled(outputTensor.shape[1], 0.0));
    }

    interpreter.run(input, output);
    print('Output sample: ${output[0].sublist(0, min(10, outputTensor.shape[1]))}');
  });
}
