#if !defined(OUTLINE_ONLY_PASS_HLSL)
#define OUTLINE_ONLY_PASS_HLSL
#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../../PowerShaderLib/Lib/NoiseLib.hlsl"

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
};

sampler2D _OutlineTex;
sampler2D _NoiseMap;

CBUFFER_START(UnityPerMaterial)
half _Width,_WidthLocalYAtten;
half4 _Color;
half4 _OutlineTex_ST;
half _VertexColorAttenOn;
half _ZOffset;

half _NoiseWaveScale;
half _VertexMoveMode;
float _BaseLocalY;
float _NoiseAlphaScale,_NoiseAlphaBase;

float4 _NoiseMap_ST;
CBUFFER_END

#define MUL_VERTEX_COLOR_ATTEN(v) (_VertexColorAttenOn? v.color.x : 1)

v2f vert (appdata v)
{
    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
    float3 wn = UnityObjectToWorldNormal(v.normal);
    float3 viewDir = UnityWorldSpaceViewDir(worldPos);
    float rnv = 1 - saturate(dot(wn,viewDir));

    float localYAtten = saturate(v.vertex.y - _BaseLocalY);
    
    #if defined(_NOISE_VERTEX_ON)
        float noise = tex2Dlod(_NoiseMap,float4(v.uv.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw *_Time.xx,0,0));
        noise *= _NoiseWaveScale;
        noise *= localYAtten;
        noise *= rnv;
        // v.vertex.xyz *= noise + 1;
        float3 normalVertex = v.normal * noise;
        float3 dirVertex = v.vertex.xyz * noise;
        v.vertex.xyz += lerp(normalVertex,dirVertex,_VertexMoveMode);
    #endif

    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.vertex.z *= _ZOffset;
    o.uv.z = rnv;

    float3 normalView = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
    float3 normalClip = normalize(TransformViewToProjection(normalView));

    float2 outlineOffset = (normalClip.xy) * _Width * o.vertex.w * 0.1;
    outlineOffset *= MUL_VERTEX_COLOR_ATTEN(v);
    outlineOffset *= smoothstep(0.,0.3,saturate(v.vertex.y - _WidthLocalYAtten));
    o.vertex.xy += outlineOffset;

    o.color = v.color;
    o.uv.xy = v.uv;
    
    return o;
}

half4 frag (v2f i) : SV_Target
{
    // float noise = GradientNoise(i.uv * _NoiseST.xy + _Time.xx* _NoiseST.zw) ;
    float noise = 0;
    #if defined(_NOISE_MAP_ON)
    noise = tex2D(_NoiseMap,i.uv * _NoiseMap_ST.xy + _NoiseMap_ST.zw *_Time.xx);
    #endif
    
    float2 uv = i.uv * _OutlineTex_ST.xy + _OutlineTex_ST.zw + noise;
    half4 col = tex2D(_OutlineTex,uv) * _Color * MUL_VERTEX_COLOR_ATTEN(i);

    #if defined(_NOISE_MAP_ON)
    // clip(noise-_NoiseAlphaScale);
    col.a *= saturate((noise- _NoiseAlphaBase)*_NoiseAlphaScale);
    #endif

    #if defined(_APPLY_FRESNEL)
    col.a *= i.uv.z;
    #endif
    
    return col;
}
#endif //OUTLINE_ONLY_PASS_HLSL