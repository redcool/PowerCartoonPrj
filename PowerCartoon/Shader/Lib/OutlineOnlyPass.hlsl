#if !defined(OUTLINE_ONLY_PASS_HLSL)
#define OUTLINE_ONLY_PASS_HLSL
#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../../PowerShaderLib/Lib/NoiseLib.hlsl"
#include "../../../PowerShaderLib/Lib/MathLib.hlsl"
#include "../../../PowerShaderLib/Lib/PowerUtils.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv:TEXCOORD;
    half3 normal:NORMAL;
    half4 color:COLOR;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 uv:TEXCOORD;
    half4 color:COLOR;
    float3 normal:TEXCOORD1;
    float3 worldPos:TEXCOORD2;
};

sampler2D _OutlineTex;
sampler2D _NoiseMap;

CBUFFER_START(UnityPerMaterial)
half _Width,_WidthLocalYAtten,_KeepWidth;
half4 _Color;
half4 _OutlineTex_ST;
half _VertexColorAttenOn;
half _ZOffset;
half _ObjectScale;

half _FresnelMin,_FresnelMax;

half _NoiseWaveScale,_NoiseWaveAutoStop;
half _VertexMoveMode;
float _BaseLocalY;

float4 _NoiseMap_ST;
float _NoiseOffsetAutoStop,_NoiseAlphaScale,_NoiseAlphaBase;
CBUFFER_END

#define MUL_VERTEX_COLOR_ATTEN(v) (_VertexColorAttenOn? v.color.x : 1)

// float2 UVOffset(float2 uvOffset,bool autoStop){
//     return uvOffset * lerp(_Time.xx,1,autoStop);
// }

// void OffsetHClipVertexZ(inout float4 vertex){
//     #if defined(UNITY_REVERSED_Z)
//         vertex.z *= _ZOffset;  //[0,1]=>[1,0]
//     #else
//         vertex.z += (1-_ZOffset)* _ProjectionParams.y; //[-1,1]=>[0,1], camera near plane
//     #endif
// }

v2f vert (appdata v)
{
    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
    float3 wn = normalize(UnityObjectToWorldNormal(v.normal));
    float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
    float rnv = 1 - saturate(dot(wn,viewDir));

    #if defined(_NOISE_VERTEX_ON)
        float localYAtten = saturate(v.vertex.y - _BaseLocalY);
        float noise = tex2Dlod(_NoiseMap,float4(v.uv.xy * _NoiseMap_ST.xy + UVOffset(_NoiseMap_ST.zw,_NoiseWaveAutoStop),0,0));
        noise *= _NoiseWaveScale;
        noise *= localYAtten;
        noise *= rnv;
        // v.vertex.xyz *= noise + 1;
        float3 normalVertex = v.normal * noise;
        float3 dirVertex = v.vertex.xyz * noise;
        v.vertex.xyz += lerp(normalVertex,dirVertex,_VertexMoveMode);
    #endif

    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz  * _ObjectScale);
    OffsetHClipVertexZ(o.vertex,_ZOffset);

    o.uv.z = smoothstep(0.,.5,rnv);

    float3 normalView = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
    float3 normalClip = normalize(TransformViewToProjection(normalView));

    float aspect = _ScreenParams.y/_ScreenParams.x;
    normalClip.x *= aspect;

    float2 outlineOffset = (normalClip.xy) * _Width * 0.1 * lerp(1,o.vertex.w,_KeepWidth);
    outlineOffset *= MUL_VERTEX_COLOR_ATTEN(v);
     
    // local y atten
    float3 vertexRotated = mul((float3x3)unity_ObjectToWorld,v.vertex);
    outlineOffset *= smoothstep(0.,0.2,saturate(vertexRotated.y - _WidthLocalYAtten));

    o.vertex.xy += outlineOffset;

    o.color = v.color;
    o.uv.xy = v.uv;
    // o.uv.z = length(normalClip.xy);
    o.normal = wn;
    o.worldPos = worldPos;
    return o;
}

half4 frag (v2f i) : SV_Target
{
    // float noise = GradientNoise(i.uv * _NoiseST.xy + _Time.xx* _NoiseST.zw) ;
    float noise = 0;
    #if defined(_NOISE_MAP_ON)
        noise = tex2D(_NoiseMap,i.uv * _NoiseMap_ST.xy + UVOffset(_NoiseMap_ST.zw,_NoiseOffsetAutoStop));
    #endif
    
    float2 uv = i.uv * _OutlineTex_ST.xy + _OutlineTex_ST.zw + noise;
    half4 col = tex2D(_OutlineTex,uv) * _Color * MUL_VERTEX_COLOR_ATTEN(i);

    #if defined(_NOISE_MAP_ON)
        // clip(noise-_NoiseAlphaScale);
        col.a *= saturate((noise- _NoiseAlphaBase)*_NoiseAlphaScale);
    #endif

    #if defined(_APPLY_FRESNEL)
        float3 normal = normalize(i.normal);
        float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        float nv = saturate(dot(normal,viewDir));
        float rnv = 1-nv;
        float fresnel = smoothstep(_FresnelMin,_FresnelMax,rnv);

        col.a *= fresnel;
    #endif
    
    return col;
}
#endif //OUTLINE_ONLY_PASS_HLSL