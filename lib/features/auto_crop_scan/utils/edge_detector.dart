import 'dart:async';
import 'dart:isolate';

import 'package:simple_edge_detection/edge_detection.dart';

class EdgeDetector {
  static Future<void> startEdgeDetectionIsolate(
      EdgeDetectionInput edgeDetectionInput) async {
    EdgeDetectionResult result =
        await EdgeDetection.detectEdges(edgeDetectionInput.inputPath);
    edgeDetectionInput.sendPort.send(result);
  }

  Future<EdgeDetectionResult> detectEdges(String filePath) async {
    // Creating a port for communication with isolate and arguments for entry point
    final port = ReceivePort();

    // Spawning an isolate
    Isolate.spawn<EdgeDetectionInput>(startEdgeDetectionIsolate,
        EdgeDetectionInput(inputPath: filePath, sendPort: port.sendPort),
        onError: port.sendPort, onExit: port.sendPort);

  

    // Listening for messages on port

    var completer = Completer<EdgeDetectionResult>();


    return completer.future;
  }
}

class EdgeDetectionInput {
  EdgeDetectionInput({required this.inputPath, required this.sendPort});

  String inputPath;
  SendPort sendPort;
}
