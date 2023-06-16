//
//  PoseVideoProcessor.m
//  MatchItUp
//
//  Created by 安子和 on 2021/6/10.
//

#import "PoseVideoProcessor.h"
#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>
#import <Vision/Vision.h>
#import "ShaderType.h"
#import <simd/simd.h>
#import <Photos/Photos.h>
#import "GlobalVar.h"
#import "NotificationManager.h"

#define blue simd_make_float4(0.5 ,0.25, 0.25, 1.0)
#define green simd_make_float4(0.0 ,1.0, 0.0, 1.0)
#define red simd_make_float4(0.0 ,0.0, 1.0, 1.0)

#define t simd_make_int2(1, 2)
#define f simd_make_int2(3, 4)
#define p simd_make_float4(0.0, 0.0, 0.0, 0.0)

@implementation PoseVideoProcessor{
    id<MTLDevice> mtlDevice;
    id<MTLCommandQueue> commandQueue;
    
    MTLRenderPassDescriptor *renderPassDescriptor;
    id<MTLRenderPipelineState> videoRenderPipelineState;
    id<MTLRenderPipelineState> keyPointRenderPipelineState;

    id<MTLTexture> targetTexture;
    id<MTLTexture> textureY;
    id<MTLTexture> textureUV;
    id<MTLBuffer> videoVerticesBuffer;
    id<MTLBuffer> keyPointVerticesBuffer;
    id<MTLBuffer> convertMatrix;
    
    AssetReader *assetReader;
    CVMetalTextureCacheRef textureCache;
    
    AVAssetWriter *assetWriter;
    AVAssetWriterInput *videoWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *pool;
    NSUInteger indexOfFrame;
    CGSize imageSize;
//    var destinationVideoURL = URL.init(fileURLWithPath: NSHomeDirectory()+"/Documents/test.mp4")
    
    VNDetectHumanBodyPoseRequest *humanPoseRequest;
    
    KeyPointVertex keyPointVertices[28];
    KeyPointVertex noseVertic;
    KeyPointVertex neckVertic;
    KeyPointVertex rootVertic;
    KeyPointVertex leftShoulderVertic;
    KeyPointVertex leftElbowVertic;
    KeyPointVertex leftWristVertic;
    KeyPointVertex rightShoulderVertic;
    KeyPointVertex rightElbowVertic;
    KeyPointVertex rightWristVertic;
    KeyPointVertex leftHipVertic;
    KeyPointVertex leftKneeVertic;
    KeyPointVertex leftAnkleVertic;
    KeyPointVertex rightHipVertic;
    KeyPointVertex rightKneeVertic;
    KeyPointVertex rightAnkleVertic;
    
    VideoVertex videoVertices[6];
    
    dispatch_queue_t processorQueue;
}

SingleM(Processor)

- (instancetype)init
{
    self = [super init];
    if (self) {
//        processorQueue = dispatch_queue_create(<#const char * _Nullable label#>, <#dispatch_queue_attr_t  _Nullable attr#>)
        
        mtlDevice = MTLCreateSystemDefaultDevice();
        commandQueue = mtlDevice.newCommandQueue;
        CVMetalTextureCacheCreate(CFAllocatorGetDefault(), nil, mtlDevice, nil, &textureCache);
        
        MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
        textureDescriptor.textureType = MTLTextureType2D;
        textureDescriptor.width = 720;
        textureDescriptor.height = 1280;
        textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
        textureDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
        
        targetTexture = [mtlDevice newTextureWithDescriptor:textureDescriptor];
        
        renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        renderPassDescriptor.colorAttachments[0].texture = targetTexture;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        
        id<MTLLibrary> lib = mtlDevice.newDefaultLibrary;
        id<MTLFunction> videoVertexFunc = [lib newFunctionWithName:@"videoVertexShader"];
        id<MTLFunction> videoFragmentFunc = [lib newFunctionWithName:@"videoSamplingShader"];
        id<MTLFunction> keyPointVertexFunc = [lib newFunctionWithName:@"keyPointVertexShader"];
        id<MTLFunction> keyPointFragmentFunc = [lib newFunctionWithName:@"keyPointSamplingShader"];
        
        MTLRenderPipelineDescriptor *videoRenderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        videoRenderPipelineDescriptor.label = @"Offscreen Video Render Pipeline";
        videoRenderPipelineDescriptor.sampleCount = 1;
        videoRenderPipelineDescriptor.vertexFunction = videoVertexFunc;
        videoRenderPipelineDescriptor.fragmentFunction = videoFragmentFunc;
        videoRenderPipelineDescriptor.colorAttachments[0].pixelFormat = targetTexture.pixelFormat;
        
        NSError *error = nil;
        videoRenderPipelineState = [mtlDevice newRenderPipelineStateWithDescriptor:videoRenderPipelineDescriptor error:&error];
        if (error){
            NSLog(@"Failed to create pipeline state to render to texture:::::::%@", error.localizedDescription);
        }
        
        MTLRenderPipelineDescriptor *keyPointRenderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        keyPointRenderPipelineDescriptor.label = @"Offscreen KeyPoint Render Pipeline";
        keyPointRenderPipelineDescriptor.vertexFunction = keyPointVertexFunc;
        keyPointRenderPipelineDescriptor.fragmentFunction = keyPointFragmentFunc;
        keyPointRenderPipelineDescriptor.colorAttachments[0].pixelFormat = targetTexture.pixelFormat;

        keyPointRenderPipelineState = [mtlDevice newRenderPipelineStateWithDescriptor:keyPointRenderPipelineDescriptor error:&error];
        if (error){
            NSLog(@"pipelineState1 init error:::::::%@", error.localizedDescription);
        }
        
        VideoVertex videoVertex0 = {simd_make_float4( 1.0, -1.0, 0.0, 1.0), simd_make_float2(1.0, 1.0)};
        VideoVertex videoVertex1 = {simd_make_float4(-1.0, -1.0, 0.0, 1.0), simd_make_float2(0.0, 1.0)};
        VideoVertex videoVertex2 = {simd_make_float4(-1.0,  1.0, 0.0, 1.0), simd_make_float2(0.0, 0.0)};
        VideoVertex videoVertex3 = {simd_make_float4( 1.0, -1.0, 0.0, 1.0), simd_make_float2(1.0, 1.0)};
        VideoVertex videoVertex4 = {simd_make_float4(-1.0,  1.0, 0.0, 1.0), simd_make_float2(0.0, 0.0)};
        VideoVertex videoVertex5 = {simd_make_float4( 1.0,  1.0, 0.0, 1.0), simd_make_float2(1.0, 0.0)};
        videoVertices[0] = videoVertex0;
        videoVertices[1] = videoVertex1;
        videoVertices[2] = videoVertex2;
        videoVertices[3] = videoVertex3;
        videoVertices[4] = videoVertex4;
        videoVertices[5] = videoVertex5;
        videoVerticesBuffer = [mtlDevice newBufferWithBytes:videoVertices length:6*sizeof(VideoVertex) options:MTLResourceStorageModeShared];
        
        matrix_float3x3 colorConversion601FullRangeMatrix = {
            simd_make_float3(1.0, 1.0, 1.0),
            simd_make_float3(1.4, -0.711, 0.00),
            simd_make_float3(0.0, -0.343, 1.765)
        };
        vector_float3 colorConversion601FullRangeOffset = simd_make_float3(-16.0/255.0, -0.5, -0.5);
        ColorConvertMatrix matrix = {colorConversion601FullRangeMatrix, colorConversion601FullRangeOffset};
        convertMatrix = [mtlDevice newBufferWithBytes:&matrix length:sizeof(ColorConvertMatrix) options:MTLResourceStorageModeShared];
        
        humanPoseRequest = [[VNDetectHumanBodyPoseRequest alloc] init];
        
        noseVertic.color = blue;
        neckVertic.color = blue;
        rootVertic.color = blue;
        leftShoulderVertic.color = red;
        leftElbowVertic.color = red;
        leftWristVertic.color = red;
        rightShoulderVertic.color = green;
        rightElbowVertic.color = green;
        rightWristVertic.color = green;
        leftHipVertic.color = red;
        leftKneeVertic.color = red;
        leftAnkleVertic.color = red;
        rightHipVertic.color = green;
        rightKneeVertic.color = green;
        rightAnkleVertic.color = green;
    }
    return self;
}

- (void)processVideo:(NSString *)videoFile withSwingId:(NSString *)swingId{
    
    [GlobalVar.sharedInstance.processingVideos addObject:swingId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *oriVideoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",GlobalVar.sharedInstance.albumDir, videoFile]];
        NSURL *poseVideoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@.mp4",GlobalVar.sharedInstance.video2dLocalDir, swingId]];
        
        NSError *error = nil;
        
        AVAsset *asset = [AVAsset assetWithURL:oriVideoURL];
        float frameRate = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.nominalFrameRate;
        self->assetReader = [[AssetReader alloc] initWithURL:oriVideoURL];
        self->assetWriter = [[AVAssetWriter alloc] initWithURL:poseVideoURL fileType:AVFileTypeMPEG4 error:&error];
        if (error){
            NSLog(@"error : %@", error.localizedDescription);
            return;
        }
        
        NSDictionary *videoSettings = @{
            AVVideoCodecKey: AVVideoCodecTypeH264,
            AVVideoWidthKey: @720,
            AVVideoHeightKey: @1280
        };
        self->videoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        
        NSDictionary *pixelBufferAttributes = @{
            (NSString *)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInteger:kCVPixelFormatType_32BGRA]
        };
        self->pool = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self->videoWriterInput sourcePixelBufferAttributes:pixelBufferAttributes];
        
        if ([self->assetWriter canAddInput:self->videoWriterInput]){
            [self->assetWriter addInput:self->videoWriterInput];
        }
        
        if (self->assetWriter && self->assetWriter.status == AVAssetWriterStatusUnknown && self->videoWriterInput){
            NSLog(@"开始写入");
            [self->assetWriter startWriting];
            [self->assetWriter startSessionAtSourceTime:kCMTimeZero];
            self->indexOfFrame = 0;
        }
        
        CMSampleBufferRef sampleBuffer = nil;
        while (1) {
            sampleBuffer = [self->assetReader nextBuffer];
            if (sampleBuffer == nil){
                break;
            }
            [self getKeyPoints:sampleBuffer];
            
            id<MTLCommandBuffer> commandBuffer = [self->commandQueue commandBuffer];
            id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:self->renderPassDescriptor];
            renderCommandEncoder.label = @"Offscreen Render Encoder";
            
            [renderCommandEncoder setRenderPipelineState:self->videoRenderPipelineState];
            [renderCommandEncoder setVertexBuffer:self->videoVerticesBuffer offset:0 atIndex:0];
            [renderCommandEncoder setFragmentBuffer:self->convertMatrix offset:0 atIndex:0];
            [self setTextureWithEncode:renderCommandEncoder sampleBuffer:sampleBuffer];
            [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
            
            [renderCommandEncoder setRenderPipelineState:self->keyPointRenderPipelineState];
            [renderCommandEncoder setVertexBuffer:self->keyPointVerticesBuffer offset:0 atIndex:1];
            [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:28];
            [renderCommandEncoder drawPrimitives:MTLPrimitiveTypePoint vertexStart:0 vertexCount:28];
            
            [renderCommandEncoder endEncoding];
            
            [commandBuffer addScheduledHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
                NSLog(@"command buffer status %lu", (unsigned long)buffer.status);
                
                if (self->videoWriterInput && self->videoWriterInput.isReadyForMoreMediaData){
                    NSUInteger tHeight = self->targetTexture.height;
                    NSUInteger tWidth = self->targetTexture.width;
                    
                    NSMutableData *data = [[NSMutableData alloc] initWithLength:tHeight*tWidth*32];
                    [self->targetTexture getBytes:[data mutableBytes] bytesPerRow:tWidth*32 bytesPerImage:tHeight*tWidth*32 fromRegion:MTLRegionMake2D(0, 0, tWidth, tHeight) mipmapLevel:0 slice:0];
                    if (data.mutableBytes){
                        CVPixelBufferRef outputPixelBuffer = nil;
                        CVPixelBufferCreateWithBytes(CFAllocatorGetDefault(), tWidth, tHeight, kCVPixelFormatType_32BGRA, data.mutableBytes, tWidth*32, nil, nil, nil, &outputPixelBuffer);
                        
                        if (outputPixelBuffer){
                            NSLog(@"index of frame : %lu", (unsigned long)self->indexOfFrame);
                            [self->pool appendPixelBuffer:outputPixelBuffer withPresentationTime:CMTimeMake(self->indexOfFrame * 1000, frameRate * 1000)];
                            ++self->indexOfFrame;
                        }else{
                            NSLog(@"outputPixelbuffer null");
                        }
                        CVPixelBufferRelease(outputPixelBuffer);
                    }else{
                        NSLog(@"没data");
                    }
                }else{
                    NSLog(@"没写：：：%d", self->videoWriterInput.isReadyForMoreMediaData);
                }
            }];
            [commandBuffer commit];
            [commandBuffer waitUntilCompleted];
        }
        
        if (self->assetWriter && self->videoWriterInput){
            [self->videoWriterInput markAsFinished];
            self->videoWriterInput = nil;
            //assetWriter = nil;
            
            [self->assetWriter finishWritingWithCompletionHandler:^{

                [NotificationManager.sharedManager pushLocalNotification:swingId];
                
            }];
        }
    });
}

- (void)getKeyPoints:(CMSampleBufferRef)sampleBuffer{
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCMSampleBuffer:sampleBuffer orientation:kCGImagePropertyOrientationUp options:@{}];
    NSError *error = nil;
    [handler performRequests:@[humanPoseRequest] error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    VNHumanBodyPoseObservation *observation = humanPoseRequest.results.firstObject;
    if(!observation){
        return;
    }
    
    VNRecognizedPoint *nose = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameNose error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (nose.x != 0 && nose.y != 1){
        noseVertic.position = simd_make_float4(2*nose.x-1.0, 2*nose.y-1, 0, 1);
        noseVertic.flag = t;
    }else if(noseVertic.position[3] == 0){
        noseVertic.flag = f;
    }
    
    VNRecognizedPoint *neck = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameNeck error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (neck.x != 0 && neck.y != 1){
        neckVertic.position = simd_make_float4(2*neck.x-1.0, 2*neck.y-1, 0, 1);
        neckVertic.flag = t;
    }else if(neckVertic.position[3] == 0){
        neckVertic.flag = f;
    }
    
    VNRecognizedPoint *root = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRoot error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (root.x != 0 && root.y != 1){
        rootVertic.position = simd_make_float4(2*root.x-1.0, 2*root.y-1, 0, 1);
        rootVertic.flag = t;
    }else if(rootVertic.position[3] == 0){
        rootVertic.flag = f;
    }
    
    VNRecognizedPoint *leftShoulder = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameLeftShoulder error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (leftShoulder.x != 0 && leftShoulder.y != 1){
        leftShoulderVertic.position = simd_make_float4(2*leftShoulder.x-1.0, 2*leftShoulder.y-1, 0, 1);
        leftShoulderVertic.flag = t;
    }else if(leftShoulderVertic.position[3] == 0){
        leftShoulderVertic.flag = f;
    }
    
    VNRecognizedPoint *leftElbow = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameLeftElbow error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (leftElbow.x != 0 && leftElbow.y != 1){
        leftElbowVertic.position = simd_make_float4(2*leftElbow.x-1.0, 2*leftElbow.y-1, 0, 1);
        leftElbowVertic.flag = t;
    }else if(leftElbowVertic.position[3] == 0){
        leftElbowVertic.flag = f;
    }
    
    VNRecognizedPoint *leftWrist = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameLeftWrist error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (leftWrist.x != 0 && leftWrist.y != 1){
        leftWristVertic.position = simd_make_float4(2*leftWrist.x-1.0, 2*leftWrist.y-1, 0, 1);
        leftWristVertic.flag = t;
    }else if(leftWristVertic.position[3] == 0){
        leftWristVertic.flag = f;
    }
    
    VNRecognizedPoint *rightShoulder = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRightShoulder error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (rightShoulder.x != 0 && rightShoulder.y != 1){
        rightShoulderVertic.position = simd_make_float4(2*rightShoulder.x-1.0, 2*rightShoulder.y-1, 0, 1);
        rightShoulderVertic.flag = t;
    }else if(rightShoulderVertic.position[3] == 0){
        rightShoulderVertic.flag = f;
    }
    
    VNRecognizedPoint *rightElbow = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRightElbow error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (rightElbow.x != 0 && rightElbow.y != 1){
        rightElbowVertic.position = simd_make_float4(2*rightElbow.x-1.0, 2*rightElbow.y-1, 0, 1);
        rightElbowVertic.flag = t;
    }else if(rightElbowVertic.position[3] == 0){
        rightElbowVertic.flag = f;
    }
    
    VNRecognizedPoint *rightWrist = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRightWrist error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (rightWrist.x != 0 && rightWrist.y != 1){
        rightWristVertic.position = simd_make_float4(2*rightWrist.x-1.0, 2*rightWrist.y-1, 0, 1);
        rightWristVertic.flag = t;
    }else if(rightWristVertic.position[3] == 0){
        rightWristVertic.flag = f;
    }
    
    VNRecognizedPoint *leftHip = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameLeftHip error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (leftHip.x != 0 && leftHip.y != 1){
        leftHipVertic.position = simd_make_float4(2*leftHip.x-1.0, 2*leftHip.y-1, 0, 1);
        leftHipVertic.flag = t;
    }else if(leftHipVertic.position[3] == 0){
        leftHipVertic.flag = f;
    }
    
    VNRecognizedPoint *leftKnee = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameLeftKnee error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (leftKnee.x != 0 && leftKnee.y != 1){
        leftKneeVertic.position = simd_make_float4(2*leftKnee.x-1.0, 2*leftKnee.y-1, 0, 1);
        leftKneeVertic.flag = t;
    }else if(leftKneeVertic.position[3] == 0){
        leftKneeVertic.flag = f;
    }
    
    VNRecognizedPoint *leftAnkle = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameLeftAnkle error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (leftAnkle.x != 0 && leftAnkle.y != 1){
        leftAnkleVertic.position = simd_make_float4(2*leftAnkle.x-1.0, 2*leftAnkle.y-1, 0, 1);
        leftAnkleVertic.flag = t;
    }else if(leftAnkleVertic.position[3] == 0){
        leftAnkleVertic.flag = f;
    }
    
    VNRecognizedPoint *rightHip = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRightHip error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (rightHip.x != 0 && rightHip.y != 1){
        rightHipVertic.position = simd_make_float4(2*rightHip.x-1.0, 2*rightHip.y-1, 0, 1);
        rightHipVertic.flag = t;
    }else if(rightHipVertic.position[3] == 0){
        rightHipVertic.flag = f;
    }
    
    VNRecognizedPoint *rightKnee = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRightKnee error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (rightKnee.x != 0 && rightKnee.y != 1){
        rightKneeVertic.position = simd_make_float4(2*rightKnee.x-1.0, 2*rightKnee.y-1, 0, 1);
        rightKneeVertic.flag = t;
    }else if(rightKneeVertic.position[3] == 0){
        rightKneeVertic.flag = f;
    }
    
    VNRecognizedPoint *rightAnkle = [observation recognizedPointForJointName:VNHumanBodyPoseObservationJointNameRightAnkle error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    if (rightAnkle.x != 0 && rightAnkle.y != 1){
        rightAnkleVertic.position = simd_make_float4(2*rightAnkle.x-1.0, 2*rightAnkle.y-1, 0, 1);
        rightAnkleVertic.flag = t;
    }else if(rightAnkleVertic.position[3] == 0){
        rightAnkleVertic.flag = f;
    }

        
    keyPointVertices[0] = noseVertic;
    keyPointVertices[1] = neckVertic;
    keyPointVertices[2] = neckVertic;
    keyPointVertices[3] = leftShoulderVertic;
    keyPointVertices[4] = leftShoulderVertic;
    keyPointVertices[5] = leftElbowVertic;
    keyPointVertices[6] = leftElbowVertic;
    keyPointVertices[7] = leftWristVertic;
    keyPointVertices[8] = neckVertic;
    keyPointVertices[9] = rightShoulderVertic;
    keyPointVertices[10] = rightShoulderVertic;
    keyPointVertices[11] = rightElbowVertic;
    keyPointVertices[12] = rightElbowVertic;
    keyPointVertices[13] = rightWristVertic;
    keyPointVertices[14] = neckVertic;
    keyPointVertices[15] = rootVertic;
    keyPointVertices[16] = rootVertic;
    keyPointVertices[17] = leftHipVertic;
    keyPointVertices[18] = leftHipVertic;
    keyPointVertices[19] = leftKneeVertic;
    keyPointVertices[20] = leftKneeVertic;
    keyPointVertices[21] = leftAnkleVertic;
    keyPointVertices[22] = rootVertic;
    keyPointVertices[23] = rightHipVertic;
    keyPointVertices[24] = rightHipVertic;
    keyPointVertices[25] = rightKneeVertic;
    keyPointVertices[26] = rightKneeVertic;
    keyPointVertices[27] = rightAnkleVertic;
    
    keyPointVerticesBuffer = [mtlDevice newBufferWithBytes:keyPointVertices length:28*sizeof(KeyPointVertex) options:MTLResourceStorageModeShared];
}

- (void)setTextureWithEncode:(id<MTLRenderCommandEncoder>)encoder sampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t widthY = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t heightY = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    CVMetalTextureRef cvMetalTextureY = nil;
    CVReturn statusY = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, MTLPixelFormatR8Unorm, widthY, heightY, 0, &cvMetalTextureY);
    if (statusY == kCVReturnSuccess && cvMetalTextureY){
        textureY = CVMetalTextureGetTexture(cvMetalTextureY);
    }
    CFRelease(cvMetalTextureY);
    
    size_t widthUV = CVPixelBufferGetWidthOfPlane(imageBuffer, 1);
    size_t heightUV = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);
    CVMetalTextureRef cvMetalTextureUV = nil;
    CVReturn statusUV = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, MTLPixelFormatRG8Unorm, widthUV, heightUV, 1, &cvMetalTextureUV);
    if (statusUV == kCVReturnSuccess && cvMetalTextureUV){
        textureUV = CVMetalTextureGetTexture(cvMetalTextureUV);
    }
    CFRelease(cvMetalTextureUV);
    
    if (textureY && textureUV){
        [encoder setFragmentTexture: textureY atIndex:FragmentTextureIndexVideoTextureY];
        [encoder setFragmentTexture: textureUV atIndex:FragmentTextureIndexVideoTextureUV];
    }
    
    CFRelease(sampleBuffer);
}

@end

@implementation AssetReader{
    AVAssetReaderTrackOutput *readerVideoTrackOutput;
    AVAssetReader *assetReader;
    AVURLAsset *asset;
}

- (instancetype)initWithURL:(NSURL *)videoURL{
    self = [super init];
    if (self){
        asset = [[AVURLAsset alloc] initWithURL:videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
        [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            NSError *error = nil;
            
            AVKeyValueStatus status = [self->asset statusOfValueForKey:@"tracks" error:&error];
            if (error){
                NSLog(@"status %ld : %@", (long)status, error.localizedDescription);
                return;
            }
            
            self->assetReader = [[AVAssetReader alloc] initWithAsset:self->asset error:&error];
            if (error){
                NSLog(@"%@", error.localizedDescription);
                return;
            }
            
            AVAssetTrack *videoTrack = [self->asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (!videoTrack){
                NSLog(@"video track nil");
                return;
            }
            self->readerVideoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]}];
            self->readerVideoTrackOutput.alwaysCopiesSampleData = NO;
            
            if ([self->assetReader canAddOutput:self->readerVideoTrackOutput]){
                [self->assetReader addOutput:self->readerVideoTrackOutput];
            }else{
                NSLog(@"assetReader add output failed");
            }
            
            if ([self->assetReader startReading] == NO){
                NSLog(@"error reading from file at url::::: %@", self->asset);
            }
        }];
    }
    return self;
}

- (nullable CMSampleBufferRef)nextBuffer{
    CMSampleBufferRef bufferRef = nil;
    bufferRef = readerVideoTrackOutput.copyNextSampleBuffer;
    return bufferRef;
}

@end
