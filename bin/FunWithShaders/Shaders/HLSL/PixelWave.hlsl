#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"

void VS(float4 iPos : POSITION,
		float2 iTexCoord : TEXCOORD0, 
	out float2 oTexCoord : TEXCOORD0,
	out float  oTime : TEXCOORD1,
	out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;
	float3 worldPos = GetWorldPos(modelMatrix);	
    oPos = GetClipPos(worldPos);

	oTime = cElapsedTime;
	oTexCoord = iTexCoord;
}

void PS(
		float2 iTexCoord : TEXCOORD0,
		float  iTime : TEXCOORD1,
    out float4 oColor : OUTCOLOR0)
{
	float u;
	float f = iTexCoord.x;
	float offset = 0.4 + 0.4 * sin(iTime);
    if (f > offset && f < offset + 0.2)
    {
      u = 1.0;
    } 
    else
    {
        u = 0.0;
    }
    oColor = float4(u, 1.0, 0.0, 1.0);
}
