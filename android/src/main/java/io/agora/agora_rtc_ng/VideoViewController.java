package io.agora.agora_rtc_ng;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class VideoViewController implements MethodChannel.MethodCallHandler {

    private final MethodChannel methodChannel;

    VideoViewController(BinaryMessenger binaryMessenger) {
        methodChannel = new MethodChannel(binaryMessenger, "agora_rtc_ng/video_view_controller");
        methodChannel.setMethodCallHandler(this);
    }

    private long createPlatformRender(){
        return 0L;
    }

    private boolean destroyPlatformRender(long platformRenderId) {
        return true;
    }

    private long createTextureRender(long uid, String channelId, int videoSourceType) {
        return 0L;
    }

    private boolean destroyTextureRender(long textureId){
        return false;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "attachVideoFrameBufferManager":
                result.success(0);
                break;
            case "detachVideoFrameBufferManager":
                result.success(true);
                break;

            case "createTextureRender":
            {
                final Long uid = call.argument("uid");
                final String channelId = call.argument("channelId");
                final Integer videoSourceType = call.argument("videoSourceType");

                @SuppressWarnings("ConstantConditions")
                final long textureId = createTextureRender(uid, channelId, videoSourceType);
                result.success(textureId);
                break;
            }
            case "destroyTextureRender":
            {
                final long textureId = (long) call.arguments;
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

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
