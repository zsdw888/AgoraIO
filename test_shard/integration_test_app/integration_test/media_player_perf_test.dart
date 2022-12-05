import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integration_test_app/fake_remote_user.dart';
import 'package:integration_test_app/main.dart' as app;

class _MediaPlayer extends StatefulWidget {
  const _MediaPlayer({Key? key, required this.onFrame}) : super(key: key);

  final VoidCallback onFrame;

  @override
  State<_MediaPlayer> createState() => __MediaPlayerState();
}

class __MediaPlayerState extends State<_MediaPlayer> {
  late final RtcEngine rtcEngine;
  late final MediaPlayerController mediaPlayerController;
  late final MediaPlayerVideoFrameObserver observer;
  bool isInit = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    String engineAppId = const String.fromEnvironment('TEST_APP_ID',
        defaultValue: '<YOUR_APP_ID>');

    RtcEngineEx rtcEngine = createAgoraRtcEngineEx();

    await rtcEngine.initialize(RtcEngineContext(
      appId: engineAppId,
      areaCode: AreaCode.areaCodeGlob.value(),
    ));

    mediaPlayerController = MediaPlayerController(
        rtcEngine: rtcEngine, canvas: const VideoCanvas(uid: 0));
    await mediaPlayerController.initialize();

    observer = MediaPlayerVideoFrameObserver(
      onFrame: (frame) {
        debugPrint('[onFrame]: ${frame.toJson()}');

        widget.onFrame();
      },
    );
    mediaPlayerController.registerVideoFrameObserver(observer);

    setState(() {
      isInit = true;
    });

    await mediaPlayerController.open(
        url:
            'https://agoracdn.s3.us-west-1.amazonaws.com/videos/Agora.io-Interactions.mp4',
        startPos: 0);
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    mediaPlayerController.unregisterVideoFrameObserver(observer);
    await mediaPlayerController.dispose();
    await rtcEngine.release();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      return Container();
    }
    return AgoraVideoView(
      controller: mediaPlayerController,
    );
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive;

  testWidgets(
    'initialize perf test',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // The slight initial delay avoids starting the timing during a
      // period of increased load on the device. Without this delay, the
      // benchmark has greater noise.
      // See: https://github.com/flutter/flutter/issues/19434
      await tester.binding.delayed(const Duration(microseconds: 250));

      // String engineAppId = const String.fromEnvironment('TEST_APP_ID',
      //     defaultValue: '<YOUR_APP_ID>');

      // await tester.pumpWidget(MyApp(
      //   items: List<String>.generate(10000, (i) => 'Item $i'),
      // ));

      // final listFinder = find.byType(Scrollable);
      // final itemFinder = find.byKey(const ValueKey('item_50_text'));

      final onFrameCompleter = Completer();

      // RtcEngineEx rtcEngine = createAgoraRtcEngineEx();

      // await rtcEngine.initialize(RtcEngineContext(
      //   appId: engineAppId,
      //   areaCode: AreaCode.areaCodeGlob.value(),
      // ));

      // MediaPlayerController mediaPlayerController = MediaPlayerController(
      //     rtcEngine: rtcEngine, canvas: VideoCanvas(uid: 0));
      // await mediaPlayerController.initialize();

      // final observer = MediaPlayerVideoFrameObserver(
      //   onFrame: (frame) {
      //     debugPrint('[onFrame]: ${frame.toJson()}');

      //     if (onFrameCompleter.isCompleted) {
      //       return;
      //     }

      //     onFrameCompleter.complete(null);
      //   },
      // );
      // mediaPlayerController.registerVideoFrameObserver(observer);

      await binding.watchPerformance(() async {
        await tester.pumpWidget(_MediaPlayer(onFrame: () {
          if (onFrameCompleter.isCompleted) {
            return;
          }
          onFrameCompleter.complete();
        }));

        await onFrameCompleter.future;
      });
    },
    semanticsEnabled: false,
    timeout: Timeout.none,
  );
}
