#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Fog.glsl"

varying vec2 vTexCoord;
varying float vTime;

void VS()
{
  vTime = abs( cos( cElapsedTime ) );
  vTexCoord = GetTexCoord( iTexCoord );

  mat4 modelMatrix = cModel;
  vec3 worldPos = GetWorldPos( modelMatrix );

  float scale = 0.02;
  mat3 scaleMatrix = mat3x3(1.0 + scale, 0.0, 0.0, 0.0, 1.0 + scale, 0.0, 0.0, 0.0, 1.0 + scale);
  vec3 scaleWorld = scaleMatrix * worldPos;
  //scaleWorld.xy += vec2(1.0, 1.0);
  gl_Position = GetClipPos( scaleWorld );
}

void PS()
{
  vec4 diffInput = texture2D( sDiffMap, vTexCoord.xy );
  vec4 diffColor = cMatDiffColor * diffInput;

  // Per-pixel forward lighting
  vec3 lightColor = cLightColor.rgb;

  gl_FragColor = vec4( 191.0/255.0 * vTime, 193.0/255.0 * vTime, 194.0/255.0 * vTime, diffColor.a );
}
