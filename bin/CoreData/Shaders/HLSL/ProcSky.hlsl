#include "Uniforms.hlsl"
#include "ScreenPos.hlsl"
#include "Transform.hlsl"

void VS( float4 iPos : POSITION,
         out float2 oTexCoord : TEXCOORD0,
         out float4 oPos : OUTPOSITION )
{
  float4x3 modelMatrix = iModelMatrix;
  float3 worldPos = GetWorldPos( modelMatrix );
  oPos = GetClipPos( worldPos );
  oPos.z = oPos.w;
  oTexCoord = GetQuadTexCoord( oPos );
  oTexCoord.y = 1.0 - oTexCoord.y;
}


#if defined(COMPILEPS)

uniform float4x3 cInvProj;
uniform float3x3 cInvViewRot;
uniform float3 cLightDir;
uniform float3 cKr;
uniform float cRayleighBrightness, cMieBrightness, cSpotBrightness, cScatterStrength, cRayleighStrength, cMieStrength, cRayleighCollectionPower, cMieCollectionPower, cMieDistribution;

static const float surfaceHeight = 0.99; // < 1
static const float intensity = 1.8;
static const int stepCount = 16;

float3 GetWorldNormal( float2 texCoord )
{
  float2 fragCoord = texCoord;
  fragCoord = ( fragCoord - 0.5 ) * 2.0;
  float4 deviceNormal = float4( fragCoord, 0.0, 1.0 );
  float4 eyeUN = float4(
                   cInvProj._m00 * deviceNormal.x + cInvProj._m10 * deviceNormal.y + cInvProj._m20 * deviceNormal.z + cInvProj._m30,
                   cInvProj._m01 * deviceNormal.x + cInvProj._m11 * deviceNormal.y + cInvProj._m21 * deviceNormal.z + cInvProj._m31,
                   cInvProj._m02 * deviceNormal.x + cInvProj._m12 * deviceNormal.y + cInvProj._m22 * deviceNormal.z + cInvProj._m32,
                   deviceNormal.w );
  float3 eyeNormal = normalize( eyeUN.xyz );

  float3 worldUN = float3(
                     cInvViewRot._m00 * eyeNormal.x + cInvViewRot._m01 * eyeNormal.y + cInvViewRot._m20 * eyeNormal.z,
                     cInvViewRot._m01 * eyeNormal.x + cInvViewRot._m11 * eyeNormal.y + cInvViewRot._m21 * eyeNormal.z,
                     cInvViewRot._m02 * eyeNormal.x + cInvViewRot._m12 * eyeNormal.y + cInvViewRot._m22 * eyeNormal.z
                   );

  float3 worldNormal = normalize( worldUN );

  return worldNormal;
}

float AtmosphericDepth( float3 pos, float3 dir )
{
  float a = dot( dir, dir );
  float b = 2.0 * dot( dir, pos );
  float c = dot( pos, pos ) - 1.0;
  float det = b * b - 4.0 * a * c;
  float detSqrt = sqrt( det );
  float q = ( -b - detSqrt ) / 2.0;
  float t1 = c / q;
  return t1;
}

float Phase( float alpha, float g )
{
  float a = 3.0 * ( 1.0 - g * g );
  float b = 2.0 * ( 2.0 + g * g );
  float c = 1.0 + alpha * alpha;
  float d = pow( 1.0 + g * g - 2.0 * g * alpha, 1.5 );
  return ( a / b ) * ( c / d );
}

float HorizonExtinction( float3 pos, float3 dir, float radius )
{
  float u = dot( dir, -pos );
  if ( u < 0.0 )
  {
    return 1.0;
  }
  float3 near = pos + u * dir;
  if ( length( near ) < radius )
  {
    return 0.0;
  }
  else
  {
    float3 v2 = normalize( near ) * radius - pos;
    float diff = acos( dot( normalize( v2 ), dir ) );
    return smoothstep( 0.0, 1.0, pow( diff * 2.0, 3.0 ) );
  }
}

float3 Absorb( float dist, float3 color, float factor )
{
  return color - color * pow( cKr, float3( factor / dist, factor / dist, factor / dist ) );
}

#endif // defined(COMPILEPS)

void PS( float2 iPos: TEXCOORD0, out float4 oColor : OUTCOLOR0 )
{
  float3 lightDir = cLightDir;
  lightDir.z *= -1.0; // Invert world Z for Urho.
  float3 eyeDir = GetWorldNormal( iPos );
  float alpha = clamp( dot( eyeDir, lightDir ), 0, 1 );
  float rayleighFactor = Phase( alpha, -0.01 ) * cRayleighBrightness;
  float mieFactor = Phase( alpha, cMieDistribution ) * cMieBrightness;
  float spot = smoothstep( 0.0, 15.0, Phase( alpha, 0.9995 ) ) * cSpotBrightness;
  float3 eyePos = float3( 0.0, surfaceHeight, 0.0 );
  float eyeDepth = AtmosphericDepth( eyePos, eyeDir );
  float stepLength = eyeDepth / float( stepCount );
  float eyeExtinction = HorizonExtinction( eyePos, eyeDir, surfaceHeight - 0.15 );

  float3 rayleighCollected = float3( 0.0, 0.0, 0.0 );
  float3 mieCollected = float3( 0.0, 0.0, 0.0 );

  for ( int i = 0; i < stepCount; ++i )
  {
    float sampleDistance = stepLength * float( i );
    float3 pos = eyePos + eyeDir * sampleDistance;
    float extinction = HorizonExtinction( pos, lightDir, surfaceHeight - 0.35 );
    float sampleDepth = AtmosphericDepth( pos, lightDir );
    float3 influx = Absorb( sampleDepth, float3( intensity, intensity , intensity ), cScatterStrength ) * extinction;
    rayleighCollected += Absorb( sampleDistance, cKr * influx, cRayleighStrength );
    mieCollected += Absorb( sampleDistance, influx, cMieStrength );
  }

  rayleighCollected = ( rayleighCollected * eyeExtinction * pow( eyeDepth, cRayleighCollectionPower ) ) / float( stepCount );
  mieCollected = ( mieCollected * eyeExtinction * pow( eyeDepth, cMieCollectionPower ) ) / float( stepCount );

  float3 color = float3( spot * mieCollected + mieFactor * mieCollected + rayleighFactor * rayleighCollected );
  oColor = float4( color, 1.0 );
}
