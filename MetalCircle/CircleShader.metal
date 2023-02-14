//
//  CircleShader.metal
//  AudioVisualizer
//
//  Created by doremin on 2023/02/02.
//

#include <simd/simd.h>
#include <metal_stdlib>
using namespace metal;

struct VertexOut {
  vector_float4 pos [[position]];
  vector_float4 color;
};

vertex VertexOut vertexShader(unsigned int vid [[vertex_id]],
                              const constant vector_float2 *vertexArray [[buffer(0)]]) {
  vector_float2 currentVertex = vertexArray[vid];
  VertexOut output;
  
  output.pos = vector_float4(currentVertex.x, currentVertex.y, 0, 1);
  output.color = vector_float4(1, 1, 1, 1);
  
  return output;
}

fragment vector_float4 fragmentShader(VertexOut interpolated [[stage_in]]) {
  return interpolated.color;
}
