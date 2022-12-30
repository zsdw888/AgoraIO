package io.agora.agora_rtc_ng;

import android.os.Handler;
import android.os.Looper;
import android.view.Surface;

import java.util.HashMap;

import io.agora.iris.IrisRenderer;
import io.agora.iris.IrisVideoFrameBufferManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class TextureRenderer {
    private final TextureRegistry.SurfaceTextureEntry flutterTexture;
    private final IrisRenderer irisRenderer;
    private final MethodChannel methodChannel;
    private final Handler handler;

    public TextureRenderer(
            TextureRegistry textureRegistry,
            BinaryMessenger binaryMessenger,
            IrisVideoFrameBufferManager irisVideoFrameBufferManager,
            long uid,
            String channelId,
            int videoSourceType) {

        this.handler = new Handler(Looper.getMainLooper());

        this.flutterTexture = textureRegistry.createSurfaceTexture();
        Surface surface = new Surface(this.flutterTexture.surfaceTexture());

        this.methodChannel = new MethodChannel(binaryMessenger, "agora_rtc_engine/texture_render_" + flutterTexture.id());

        this.irisRenderer = new IrisRenderer(
                irisVideoFrameBufferManager.getNativeHandle(),
                uid,
                channelId,
                videoSourceType);
        this.irisRenderer.setCallback(new IrisRenderer.Callback() {
            @Override
            public void onSizeChanged(int width, int height) {
                handler.post(() -> methodChannel.invokeMethod(
                        "onSizeChanged",
                        new HashMap<String, Integer>() {{
                            put("width", width);
                            put("height", height);
                        }}));

            }
        });
        this.irisRenderer.startRenderingToSurface(surface);
    }

    public long getTextureId() {
        return flutterTexture.id();
    }

    public void dispose() {
        irisRenderer.stopRenderingToSurface();
        flutterTexture.release();
    }
}
