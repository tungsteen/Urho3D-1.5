#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Fog.glsl"

varying float vTime;

uniform float cSiluetWidth;
uniform vec4 cSiluetColor;

void VS()
{
  vTime = abs( cos( cElapsedTime ) );

  mat4 modelMatrix = cModel;
  vec3 worldNormal = GetWorldNormal( modelMatrix );
  vec3 worldPos = GetWorldPos( modelMatrix );

  // shift towards normal multiplied by siluet width
  worldPos.xy += worldNormal.xy * cSiluetWidth;

  gl_Position = GetClipPos( worldPos );
}

void PS()
{
  gl_FragColor = vec4( cSiluetColor.rgb * vTime, cSiluetColor.a );
}
