#import <Foundation/Foundation.h>
#import "TextureRenderer.h"
#import <AgoraRtcWrapper/iris_rtc_rendering_cxx.h>
#import <AgoraRtcKit/IAgoraMediaEngine.h>

using namespace agora::iris;

@interface TextureRender ()

@property(nonatomic, weak) NSObject<FlutterTextureRegistry> *textureRegistry;
@property(nonatomic, strong) FlutterMethodChannel *channel;
@property(nonatomic) CVPixelBufferRef buffer_cache;
@property(nonatomic, strong) dispatch_semaphore_t lock;
@property(nonatomic) agora::iris::IrisRtcRendering *videoFrameBufferManager;
@property(nonatomic) NSDictionary *cvBufferProperties;
@property(nonatomic) IrisRtcVideoFrameConfig config;
@property(nonatomic) BOOL isNeedReleaseCVPixelBufferRefInDispose;

@end

namespace {
class RendererDelegate : public agora::iris::VideoFrameObserverDelegate {
public:
  RendererDelegate(void *renderer) : renderer_(renderer) {}

  void OnVideoFrameReceived(const void *videoFrame,
                            const IrisRtcVideoFrameConfig &config, bool resize) override {
    @autoreleasepool {
        TextureRender *renderer = (__bridge TextureRender *)renderer_;
        
        agora::media::base::VideoFrame *vf = (agora::media::base::VideoFrame *)videoFrame;
        
        CVPixelBufferRef _Nullable pixelBuffer = reinterpret_cast<CVPixelBufferRef>(vf->pixelBuffer);
        
        
//        if (renderer.buffer_cache != NULL && resize) {
//            CVBufferRelease(renderer.buffer_cache);
//            renderer.buffer_cache = NULL;
//        }
//
//        CVPixelBufferRef buffer = renderer.buffer_cache;
//        if (renderer.buffer_cache == NULL) {
//            CVPixelBufferCreate(kCFAllocatorDefault, video_frame.width,
//                                video_frame.height, kCVPixelFormatType_32BGRA,
//                                (__bridge CFDictionaryRef)renderer.cvBufferProperties, &buffer);
//


//        }
//
//        CVPixelBufferLockBaseAddress(buffer, 0);
//        void *copyBaseAddress = CVPixelBufferGetBaseAddress(buffer);
//        memcpy(copyBaseAddress, video_frame.y_buffer,
//               video_frame.y_buffer_length);
//        CVPixelBufferUnlockBaseAddress(buffer, 0);
        
        
//
        
        
        if (pixelBuffer) {
            if (resize) {
                [renderer.channel invokeMethod:@"onSizeChanged"
                                     arguments:@{@"width": @(vf->width),
                                                 @"height": @(vf->height)}];
            }
            
            dispatch_semaphore_wait(renderer.lock, DISPATCH_TIME_FOREVER);
            renderer.buffer_cache = CVPixelBufferRetain(pixelBuffer);
            renderer.isNeedReleaseCVPixelBufferRefInDispose = YES;

            [renderer.textureRegistry textureFrameAvailable:renderer.textureId];
        }
    }
  }

public:
  void *renderer_;
};
}

@interface TextureRender ()

@property(nonatomic) RendererDelegate *delegate;

@end

@implementation TextureRender

- (instancetype) initWithTextureRegistry:(NSObject<FlutterTextureRegistry> *)textureRegistry
                               messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                 videoFrameBufferManager:(void *)manager {
    self = [super init];
    if (self) {
      self.textureRegistry = textureRegistry;
        self.videoFrameBufferManager = (agora::iris::IrisRtcRendering *)manager;
      self.textureId = [self.textureRegistry registerTexture:self];
      self.channel = [FlutterMethodChannel
          methodChannelWithName:
              [NSString stringWithFormat:@"agora_rtc_engine/texture_render_%lld",
                                         self.textureId]
                binaryMessenger:messenger];

      self.lock = dispatch_semaphore_create(1);
        
      self.cvBufferProperties = @{
          (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
          (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
          (__bridge NSString *)kCVPixelBufferOpenGLCompatibilityKey: @YES,
          (__bridge NSString *)kCVPixelBufferMetalCompatibilityKey: @YES,
        };
        
      self.delegate = new ::RendererDelegate((__bridge void *)self);
    }
    return self;
}

- (void)updateData:(NSNumber *)uid channelId:(NSString *)channelId videoSourceType:(NSNumber *)videoSourceType {
    IrisRtcVideoFrameConfig config;
    config.video_frame_format = 12; // VIDEO_CVPIXEL_NV12
    config.id = [uid unsignedIntValue];
    config.video_source_type = [videoSourceType intValue];
    
      if (channelId && (NSNull *)channelId != [NSNull null]) {
          strcpy(config.key, [channelId UTF8String]);
          
      } else {
          strcpy(config.key, "");
      }
    
//    self.videoFrameBufferManager->EnableVideoFrameBuffer(buffer, &config);
    self.config = config;
    
    self.videoFrameBufferManager->AddVideoFrameObserverDelegate(self.config, self.delegate);
}

- (void)dispose {
//    self.videoFrameBufferManager->DisableVideoFrameBuffer(self.delegate);
    self.videoFrameBufferManager->RemoveVideoFrameObserverDelegate(self.config);
    if (self.delegate) {
        delete self.delegate;
        self.delegate = NULL;
    }
    [self.textureRegistry unregisterTexture:self.textureId];
    if (self.isNeedReleaseCVPixelBufferRefInDispose) {
      CVPixelBufferRelease(self.buffer_cache);
      self.buffer_cache = NULL;
    }
}

- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    CVPixelBufferRef buffer_temp = self.buffer_cache;
    dispatch_semaphore_signal(self.lock);
    
    self.isNeedReleaseCVPixelBufferRefInDispose = NO;
    
    return buffer_temp;
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
}

@end
    
