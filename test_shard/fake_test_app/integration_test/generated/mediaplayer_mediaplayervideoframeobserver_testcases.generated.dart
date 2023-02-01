/// GENERATED BY testcase_gen. DO NOT MODIFY BY HAND.

// ignore_for_file: deprecated_member_use,constant_identifier_names

import 'dart:async';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iris_tester/iris_tester.dart';
import 'package:iris_method_channel/iris_method_channel.dart';

void generatedTestCases() {
  testWidgets(
    'onFrame',
    (WidgetTester tester) async {
      final irisTester = IrisTester();
      final debugApiEngineIntPtr = irisTester.getDebugApiEngineNativeHandle();
      setMockIrisMethodChannelNativeHandle(debugApiEngineIntPtr);

      RtcEngine rtcEngine = createAgoraRtcEngine();
      await rtcEngine.initialize(RtcEngineContext(
        appId: 'app_id',
        areaCode: AreaCode.areaCodeGlob.value(),
      ));
      MediaPlayerController mediaPlayerController = MediaPlayerController(
          rtcEngine: rtcEngine, canvas: const VideoCanvas());
      await mediaPlayerController.initialize();

      final onFrameCompleter = Completer<bool>();
      final theMediaPlayerVideoFrameObserver = MediaPlayerVideoFrameObserver(
        onFrame: (VideoFrame frame) {
          onFrameCompleter.complete(true);
        },
      );

      mediaPlayerController.registerVideoFrameObserver(
        theMediaPlayerVideoFrameObserver,
      );

// Delay 500 milliseconds to ensure the registerVideoFrameObserver call completed.
      await Future.delayed(const Duration(milliseconds: 500));

      {
        const VideoPixelFormat frameType = VideoPixelFormat.videoPixelDefault;
        const int frameWidth = 10;
        const int frameHeight = 10;
        const int frameYStride = 10;
        const int frameUStride = 10;
        const int frameVStride = 10;
        Uint8List frameYBuffer = Uint8List.fromList([1, 2, 3, 4, 5]);
        Uint8List frameUBuffer = Uint8List.fromList([1, 2, 3, 4, 5]);
        Uint8List frameVBuffer = Uint8List.fromList([1, 2, 3, 4, 5]);
        const int frameRotation = 10;
        const int frameRenderTimeMs = 10;
        const int frameAvsyncType = 10;
        Uint8List frameMetadataBuffer = Uint8List.fromList([1, 2, 3, 4, 5]);
        const int frameMetadataSize = 10;
        const int frameTextureId = 10;
        const List<double> frameMatrix = [];
        Uint8List frameAlphaBuffer = Uint8List.fromList([1, 2, 3, 4, 5]);
        final VideoFrame frame = VideoFrame(
          type: frameType,
          width: frameWidth,
          height: frameHeight,
          yStride: frameYStride,
          uStride: frameUStride,
          vStride: frameVStride,
          yBuffer: frameYBuffer,
          uBuffer: frameUBuffer,
          vBuffer: frameVBuffer,
          rotation: frameRotation,
          renderTimeMs: frameRenderTimeMs,
          avsyncType: frameAvsyncType,
          metadataBuffer: frameMetadataBuffer,
          metadataSize: frameMetadataSize,
          textureId: frameTextureId,
          matrix: frameMatrix,
          alphaBuffer: frameAlphaBuffer,
        );

        final eventJson = {
          'frame': frame.toJson(),
        };

        irisTester.fireEvent('MediaPlayerVideoFrameObserver_onFrame',
            params: eventJson);
      }

      final eventCalled = await onFrameCompleter.future;
      expect(eventCalled, isTrue);

      {
        mediaPlayerController.unregisterVideoFrameObserver(
          theMediaPlayerVideoFrameObserver,
        );
      }
// Delay 500 milliseconds to ensure the unregisterVideoFrameObserver call completed.
      await Future.delayed(const Duration(milliseconds: 500));

      await rtcEngine.release();
    },
    timeout: const Timeout(Duration(minutes: 1)),
  );
}

