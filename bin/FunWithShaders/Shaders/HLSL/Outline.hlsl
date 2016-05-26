#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"

void VS(
		float4 iPos : POSITION,
		float2 iTexCoord : TEXCOORD0,
	out	float  oTime : TEXCOORD1,
	out float2 oTexCoord : TEXCOORD0,	
	out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;	
	float3 worldPos = GetWorldPos(modelMatrix);	
	
	float scale = 0.01;
	matrix<float, 3, 3> scaleMatrix = {1.0 + scale, 0.0, 0.0, 0.0, 1.0 + scale, 0.0, 0.0, 0.0, 1.0 + scale};
	float3 scaleWorld = mul(scaleMatrix, worldPos);
    oPos = GetClipPos(scaleWorld);
	
    oTime = abs(sin(cElapsedTime));
	oTexCoord = iTexCoord;
}

void PS(
		float2 iTexCoord : TEXCOORD0,
        float  iTime : TEXCOORD1,
    out float4 oColor : OUTCOLOR0)
{
    oColor = float4(191.0/255.0 * iTime, 193.0/255.0 * iTime, 194.0/255.0 * iTime, 1.0);
}
