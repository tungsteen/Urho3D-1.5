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
  vTime = abs( cos( cElapsedTime ) );
  vTexCoord = GetTexCoord( iTexCoord );

  mat4 modelMatrix = cModel;
  vec3 worldPos = GetWorldPos( modelMatrix );
  gl_Position = GetClipPos( worldPos );

}

void PS()
{
  vec4 diffInput = texture2D( sDiffMap, vTexCoord.xy );
  vec4 diffColor = cMatDiffColor * diffInput;

  vec4 normalInput = texture2D( sNormalMap, vTexCoord.xy );
  vec4 normalColor = cMatDiffColor * normalInput;

  // Per-pixel forward lighting
  vec3 lightColor = cLightColor.rgb;
  vec3 finalColor = mix( diffColor.rgb, normalColor.rgb, vTime );

  gl_FragColor = vec4( lightColor * finalColor, diffColor.a );
}
