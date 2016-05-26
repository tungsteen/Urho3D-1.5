#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"

void VS(float4 iPos : POSITION,
		float2 iTexCoord : TEXCOORD0, 
	out float2 oTexCoord : TEXCOORD0,
	out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;    
	float time = cElapsedTime;
	float3 worldPos = GetWorldPos(modelMatrix);
	
	matrix<float, 3, 3> xRotate = { 1.0, 0.0, 0.0, 0.0, cos(time), -sin(time), 0.0, sin(time), cos(time)};
	matrix<float, 3, 3> yRotate = { cos(time), 0.0, sin(time), 0.0, 1.0, 0.0, -sin(time), 0.0, cos(time)};
	matrix<float, 3, 3> zRotate = { cos(time), -sin(time), 0.0, sin(time), cos(time), 0.0, 0.0, 0.0, 1.0};
	
	float3 rotWorldPos = mul(xRotate, worldPos);
    oPos = GetClipPos(rotWorldPos);
	
    oTexCoord = iTexCoord;
}

void PS(
        float2 iTexCoord : TEXCOORD0,
    out float4 oColor : OUTCOLOR0)
{
    float4 diffInput = Sample2D(DiffMap, iTexCoord);
    oColor = diffInput * 1.0;
}
