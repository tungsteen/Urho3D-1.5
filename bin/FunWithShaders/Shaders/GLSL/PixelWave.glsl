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

}

void PS()
{

  float u;
  float f = vTexCoord.x;
  float offset = 0.4 + 0.4 * sin(vTime);

    if (f > offset && f < offset + 0.2)
    {
      u = 1.0;
    }
    else
    {
        u = 0.0;
    }

  vec4 diffInput = vec4(u, 1.0 , 0.0, 1.0);

  vec4 diffColor = cMatDiffColor * diffInput;

  // Per-pixel forward lighting
  vec3 lightColor = cLightColor.rgb;

  gl_FragColor = vec4( lightColor * diffInput.rgb, diffColor.a );
}
