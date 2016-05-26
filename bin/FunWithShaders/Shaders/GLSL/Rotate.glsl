#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Lighting.glsl"
#include "Fog.glsl"

varying float vTime;
varying vec2 vTexCoord;

void VS()
{
  vTime = cElapsedTime;
  vTexCoord = GetTexCoord( iTexCoord );

  mat4 modelMatrix = cModel;
  vec3 worldPos = GetWorldPos( modelMatrix );

  mat3 xRotate = mat3x3( 1.0, 0.0, 0.0, 0.0, cos(vTime), -sin(vTime), 0.0, sin(vTime), cos(vTime) );
  mat3 yRotate = mat3x3( cos(vTime), 0.0, sin(vTime), 0.0, 1.0, 0.0, -sin(vTime), 0.0, cos(vTime) );
  mat3 zRotate = mat3x3( cos(vTime), -sin(vTime), 0.0, sin(vTime), cos(vTime), 0.0, 0.0, 0.0, 1.0 );

  vec3 rotWorldPos = yRotate * worldPos;

  gl_Position = GetClipPos( rotWorldPos );

}

void PS()
{
  vec4 diffInput = texture2D( sDiffMap, vTexCoord.xy );
  vec4 diffColor = cMatDiffColor * diffInput;

  // Per-pixel forward lighting
  vec3 lightColor = cLightColor.rgb;

  gl_FragColor = vec4( lightColor * diffInput.rgb, diffColor.a );
}
