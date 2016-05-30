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
  gl_Position = GetClipPos( worldPos );


  worldPos.y += worldPos.y + 0.5 * sin((iPos.x + cElapsedTime) * 5.0);

  gl_Position = GetClipPos(worldPos);
}

void PS()
{
  vec4 diffInput = vec4(0.0, 0.2, 0.3, 0.1);

  vec4 diffColor = cMatDiffColor * diffInput;

  // Per-pixel forward lighting
  vec3 lightColor = cLightColor.rgb;

  gl_FragColor = vec4( lightColor * diffInput.rgb, diffColor.a );
}
