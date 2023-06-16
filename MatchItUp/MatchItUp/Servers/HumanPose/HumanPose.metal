//
//  HumanPose.metal
//  Sport
//
//  Created by 安子和 on 2021/5/5.
//

#include <metal_stdlib>
#include "ShaderType.h"
using namespace metal;

typedef struct
{
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    float2 textureCoordinate; // 纹理坐标，会做插值处理
} VideoData;

vertex VideoData // 返回给片元着色器的结构体
videoVertexShader(uint vertexID [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant VideoVertex *vertexArray [[ buffer(0) ]]) { // buffer表明是缓存数据，0是索引
    VideoData out;
    out.clipSpacePosition = vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
}

fragment float4
videoSamplingShader(VideoData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<float> videoTextureY [[ texture(FragmentTextureIndexVideoTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureY是索引
               texture2d<float> videoTextureUV [[ texture(FragmentTextureIndexVideoTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureUV是索引
               constant ColorConvertMatrix *convertMatrix [[ buffer(0) ]]) //buffer表明是缓存数据，LYFragmentInputIndexMatrix是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
    /*
     From RGB to YUV

     Y = 0.299R + 0.587G + 0.114B
     U = 0.492 (B-Y)
     V = 0.877 (R-Y)
     
     上面是601
     
     下面是601-fullrange
     */
    // 视频读取出来的图像，yuv颜色空间
    float3 videoYUV = float3(videoTextureY.sample(textureSampler, input.textureCoordinate).r,
                              videoTextureUV.sample(textureSampler, input.textureCoordinate).rg);
    // yuv转成rgb
    float3 videoRGB = convertMatrix->matrix * (videoYUV + convertMatrix->offset);
    
    // 混合两个图像
    return float4(videoRGB, 1.0);
}

typedef struct
{
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    float4 color;
    float pointSize [[point_size]];
} KeyPointData;

vertex KeyPointData // 返回给片元着色器的结构体
keyPointVertexShader(uint vertexID [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant KeyPointVertex *vertexArray [[ buffer(1) ]]){ // buffer表明是缓存数据，0是索引
    KeyPointData out;
    out.clipSpacePosition = vertexArray[vertexID].position;
    out.color = vertexArray[vertexID].color;
    out.pointSize = 10;
    return out;
}

fragment float4
keyPointSamplingShader(KeyPointData input [[stage_in]]) // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
{
    return input.color;
}


