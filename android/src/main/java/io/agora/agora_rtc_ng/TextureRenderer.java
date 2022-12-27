package io.agora.agora_rtc_ng;

import android.view.Surface;

import io.flutter.view.TextureRegistry;

public class TextureRenderer {
    private final TextureRegistry textureRegistry;
    private final TextureRegistry.SurfaceTextureEntry surfaceTextureEntry;
    private final Surface surface;
    private final long uid;
    private final String channelId;
    private final int videoSourceType;

    public TextureRenderer(
            TextureRegistry textureRegistry,
            long uid,
            String channelId,
            int videoSourceType) {
        this.textureRegistry = textureRegistry;
        this.uid = uid;
        this.channelId = channelId;
        this.videoSourceType = videoSourceType;

        this.surfaceTextureEntry = this.textureRegistry.createSurfaceTexture();
        surface = new Surface(this.surfaceTextureEntry.surfaceTexture());

        nativeBindingRawData(this.uid, this.channelId, this.videoSourceType, this.surface);
    }

    public void dispose() {
        nativeUnbindingRawData();
    }

    private static native int nativeBindingRawData(
            long uid,
            String channelId,
            int videoSourceType,
            Surface surface);

    private static native int nativeUnbindingRawData();
}
