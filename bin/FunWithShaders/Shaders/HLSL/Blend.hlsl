#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"

void VS(float4 iPos : POSITION,
		float2 iTexCoord : TEXCOORD0,
	out	float  oTime : TEXCOORD1,
	out float2 oTexCoord : TEXCOORD0,
	out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;    
	oTime = abs(sin(cElapsedTime));
	float3 worldPos = GetWorldPos(modelMatrix);	
    oPos = GetClipPos(worldPos);
	
    oTexCoord = iTexCoord;
}

void PS(
        float2 iTexCoord : TEXCOORD0,
		float iTime: TEXCOORD1,
    out float4 oColor : OUTCOLOR0)
{
    float4 diffInput = Sample2D(DiffMap, iTexCoord);
	float4 normalInput = Sample2D(NormalMap, iTexCoord);
    oColor = lerp(diffInput, normalInput, iTime) * 1.0;
}
