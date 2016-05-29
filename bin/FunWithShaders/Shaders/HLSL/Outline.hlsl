#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"

uniform float cSiluetWidth;
uniform float4 cSiluetColor;

void VS(
    float4 iPos : POSITION,
    float2 iTexCoord : TEXCOORD0,
  out float  oTime : TEXCOORD1,
  out float2 oTexCoord : TEXCOORD0,
  out float4 oPos : OUTPOSITION)
{
  float4x3 modelMatrix = iModelMatrix;
  float3 worldPos = GetWorldPos(modelMatrix);
  vec3 worldNormal = GetWorldNormal( modelMatrix );

  // shift towards normal multiplied by siluet width
  worldPos.xy += worldNormal.xy * cSiluetWidth;
  oPos = GetClipPos(scaleWorld);

  oTime = abs(sin(cElapsedTime));
  oTexCoord = iTexCoord;
}

void PS(
    float2 iTexCoord : TEXCOORD0,
        float  iTime : TEXCOORD1,
    out float4 oColor : OUTCOLOR0)
{
    oColor = float4(cSiluetColor.rgb * iTime, cSiluetColor.a);
}
