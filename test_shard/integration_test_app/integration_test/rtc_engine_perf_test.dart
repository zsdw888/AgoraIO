import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integration_test_app/fake_remote_user.dart';
import 'package:integration_test_app/main.dart' as app;

class MyApp extends StatelessWidget {
  final List<String> items;

  const MyApp({required this.items});

  @override
  Widget build(BuildContext context) {
    const title = 'Long List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: ListView.builder(
          // Add a key to the ListView. This makes it possible to
          // find the list and scroll through it in the tests.
          key: const Key('long_list'),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                items[index],
                // Add a key to the Text widget for each item. This makes
                // it possible to look for a particular item in the list
                // and verify that the text is correct
                key: Key('item_${index}_text'),
              ),
            );
          },
        ),
      ),
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

      String engineAppId = const String.fromEnvironment('TEST_APP_ID',
          defaultValue: '<YOUR_APP_ID>');

      // await tester.pumpWidget(MyApp(
      //   items: List<String>.generate(10000, (i) => 'Item $i'),
      // ));

      // final listFinder = find.byType(Scrollable);
      // final itemFinder = find.byKey(const ValueKey('item_50_text'));

      final onFrameCompleter = Completer();

      RtcEngineEx rtcEngine = createAgoraRtcEngineEx();

      await rtcEngine.initialize(RtcEngineContext(
        appId: engineAppId,
        areaCode: AreaCode.areaCodeGlob.value(),
      ));

      MediaPlayerController mediaPlayerController = MediaPlayerController(
          rtcEngine: rtcEngine, canvas: VideoCanvas(uid: 0));
      await mediaPlayerController.initialize();

      final observer = MediaPlayerVideoFrameObserver(
        onFrame: (frame) {
          debugPrint('[onFrame]: ${frame.toJson()}');

          if (onFrameCompleter.isCompleted) {
            return;
          }

          onFrameCompleter.complete(null);
        },
      );
      mediaPlayerController.registerVideoFrameObserver(observer);

      await binding.watchPerformance(() async {
        await tester.pumpWidget(AgoraVideoView(
          controller: mediaPlayerController,
        ));

        await mediaPlayerController.open(
            url:
                'https://agoracdn.s3.us-west-1.amazonaws.com/videos/Agora.io-Interactions.mp4',
            startPos: 0);

        await onFrameCompleter.future;
      });

      mediaPlayerController.unregisterVideoFrameObserver(observer);
      await mediaPlayerController.dispose();
      await rtcEngine.release();
    },
    semanticsEnabled: false,
    timeout: Timeout.none,
  );
}
