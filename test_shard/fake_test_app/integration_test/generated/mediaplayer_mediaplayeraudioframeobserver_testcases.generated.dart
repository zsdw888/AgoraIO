/// GENERATED BY testcase_gen. DO NOT MODIFY BY HAND.

// ignore_for_file: deprecated_member_use,constant_identifier_names

import 'dart:async';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iris_tester/iris_tester.dart';
import 'package:agora_rtc_engine/src/impl/api_caller.dart';

void generatedTestCases() {
  testWidgets(
    'onFrame',
    (WidgetTester tester) async {
      final irisTester = IrisTester();
      final debugApiEngineIntPtr = irisTester.getDebugApiEngineNativeHandle();
      setMockIrisApiEngineIntPtr(debugApiEngineIntPtr);

      RtcEngine rtcEngine = createAgoraRtcEngine();
      await rtcEngine.initialize(RtcEngineContext(
        appId: 'app_id',
        areaCode: AreaCode.areaCodeGlob.value(),
      ));
      MediaPlayerController mediaPlayerController = MediaPlayerController(
          rtcEngine: rtcEngine, canvas: const VideoCanvas());
      await mediaPlayerController.initialize();

      final onFrameCompleter = Completer<bool>();
      final theMediaPlayerAudioFrameObserver = MediaPlayerAudioFrameObserver(
        onFrame: (AudioPcmFrame frame) {
          onFrameCompleter.complete(true);
        },
      );

      mediaPlayerController.registerAudioFrameObserver(
        theMediaPlayerAudioFrameObserver,
      );

// Delay 500 milliseconds to ensure the registerAudioFrameObserver call completed.
      await Future.delayed(const Duration(milliseconds: 500));

      {
        const BytesPerSample frameBytesPerSample =
            BytesPerSample.twoBytesPerSample;
        const int frameCaptureTimestamp = 10;
        const int frameSamplesPerChannel = 10;
        const int frameSampleRateHz = 10;
        const int frameNumChannels = 10;
        const List<int> frameData = [];
        const AudioPcmFrame frame = AudioPcmFrame(
          captureTimestamp: frameCaptureTimestamp,
          samplesPerChannel: frameSamplesPerChannel,
          sampleRateHz: frameSampleRateHz,
          numChannels: frameNumChannels,
          bytesPerSample: frameBytesPerSample,
          data: frameData,
        );

        final eventJson = {
          'frame': frame.toJson(),
        };

        irisTester.fireEvent('MediaPlayerAudioFrameObserver_onFrame',
            params: eventJson);
      }

      final eventCalled = await onFrameCompleter.future;
      expect(eventCalled, isTrue);

      {
        mediaPlayerController.unregisterAudioFrameObserver(
          theMediaPlayerAudioFrameObserver,
        );
      }
// Delay 500 milliseconds to ensure the unregisterAudioFrameObserver call completed.
      await Future.delayed(const Duration(milliseconds: 500));

      await rtcEngine.release();
    },
    timeout: const Timeout(Duration(minutes: 1)),
  );
}

