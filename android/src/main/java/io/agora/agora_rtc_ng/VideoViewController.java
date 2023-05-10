package io.agora.agora_rtc_ng;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class VideoViewController implements MethodChannel.MethodCallHandler {

    private final TextureRegistry textureRegistry;
    private final BinaryMessenger binaryMessenger;

    private final MethodChannel methodChannel;

    private final Map<Long, TextureRenderer> textureRendererMap = new HashMap<>();

    VideoViewController(TextureRegistry textureRegistry, BinaryMessenger binaryMessenger) {
        this.textureRegistry = textureRegistry;
        this.binaryMessenger = binaryMessenger;
        methodChannel = new MethodChannel(binaryMessenger, "agora_rtc_ng/video_view_controller");
        methodChannel.setMethodCallHandler(this);
    }

    private long createPlatformRender() {
        return 0L;
    }

    private boolean destroyPlatformRender(long platformRenderId) {
        return true;
    }

    private long createTextureRender(
            long irisRtcRenderingHandle,
            long uid,
            String channelId,
            int videoSourceType,
            int videoViewSetupMode) {
        final TextureRenderer textureRenderer = new TextureRenderer(
                textureRegistry,
                binaryMessenger,
                irisRtcRenderingHandle,
                uid,
                channelId,
                videoSourceType,
                videoViewSetupMode);
        final long textureId = textureRenderer.getTextureId();
        textureRendererMap.put(textureId, textureRenderer);

        return textureId;
    }

    private boolean destroyTextureRender(long textureId) {
        final TextureRenderer textureRenderer = textureRendererMap.get(textureId);
        if (textureRenderer != null) {
            textureRenderer.dispose();
            textureRendererMap.remove(textureId);
            return true;
        }

        return false;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
//            case "attachVideoFrameBufferManager": {
//                if (irisVideoFrameBufferManager == null) {
//                    final long engineIntPtr = (long) call.arguments;
//                    irisVideoFrameBufferManager = IrisVideoFrameBufferManager.create();
//                    irisVideoFrameBufferManager.attachToApiEngine(engineIntPtr);
//                    result.success(irisVideoFrameBufferManager.getNativeHandle());
//                } else {
//                    result.success(0L);
//                }
//
//                break;
//            }
//            case "detachVideoFrameBufferManager": {
//                final long engineIntPtr = (long) call.arguments;
//                detachVideoFrameBufferManager(engineIntPtr);
//
//                result.success(true);
//                break;
//            }
            case "createTextureRender": {
                final Map<?, ?> args = (Map<?, ?>) call.arguments;

                @SuppressWarnings("ConstantConditions")
                final long irisRtcRenderingHandle = getLong(args.get("irisRtcRenderingHandle"));
                @SuppressWarnings("ConstantConditions")
                final long uid = getLong(args.get("uid"));
                final String channelId = (String) args.get("channelId");
                final int videoSourceType = (int) args.get("videoSourceType");
                final int videoViewSetupMode = (int) args.get("videoViewSetupMode");

                final long textureId = createTextureRender(
                        irisRtcRenderingHandle,
                        uid,
                        channelId,
                        videoSourceType,
                        videoViewSetupMode);
                result.success(textureId);
                break;
            }
            case "destroyTextureRender": {
                final long textureId = getLong(call.arguments);
                final boolean success = destroyTextureRender(textureId);
                result.success(success);
                break;
            }
            case "updateTextureRenderData":
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Flutter may convert a long to int type in java, we force parse a long value via this function
     */
    private long getLong(Object value) {
        return Long.parseLong(value.toString());
    }

//    private void detachVideoFrameBufferManager(long engineIntPtr) {
//        if (irisVideoFrameBufferManager != null) {
//            irisVideoFrameBufferManager.detachFromApiEngine(engineIntPtr);
//
//            for (Map.Entry<Long, TextureRenderer> pair : textureRendererMap.entrySet()) {
//                pair.getValue().dispose();
//            }
//            textureRendererMap.clear();
//            irisVideoFrameBufferManager.destroy();
//            irisVideoFrameBufferManager = null;
//        }
//    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
