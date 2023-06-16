//
//  ShaderType.h
//  Sport
//
//  Created by 安子和 on 2021/5/5.
//

#include <simd/simd.h>

typedef struct{
    vector_float4 position;
    vector_float2 textureCoordinate;
} VideoVertex;

typedef struct{
    vector_float4 position;
    vector_float4 color;
    vector_int2 flag;
} KeyPointVertex;

typedef enum{
    VertexBufferIndexVideo = 0,
    VertexBufferIndexKeyPoint = 1,
} VertexBufferIndex;

typedef struct{
    matrix_float3x3 matrix;
    vector_float3 offset;
} ColorConvertMatrix;

typedef enum{
    FragmentBufferIndexColorConvertMatrix = 0,
} FragmentBufferIndex;

typedef enum{
    FragmentTextureIndexVideoTextureY = 0,
    FragmentTextureIndexVideoTextureUV = 1,
} FragmentTextureIndex;
