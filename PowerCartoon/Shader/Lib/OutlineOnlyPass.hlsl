#if !defined(OUTLINE_ONLY_PASS_HLSL)
#define OUTLINE_ONLY_PASS_HLSL
#include "UnityLib.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv:TEXCOORD;
    half3 normal:NORMAL;
    half3 color:COLOR;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv:TEXCOORD;
};

sampler2D _OutlineTex;

CBUFFER_START(UnityPerMaterial)
half _Width;
half4 _Color;
half4 _OutlineTex_ST;
CBUFFER_END

v2f vert (appdata v)
{
    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    // o.vertex.z *= 0.9;
    half3 worldNormal = TransformObjectToWorldNormal(v.normal);
    half3 normalClip = mul((half3x3)UNITY_MATRIX_VP,worldNormal);
    o.vertex.xy += normalClip.xy * _Width * o.vertex.w * v.color.x;

    o.uv= TRANSFORM_TEX(v.uv,_OutlineTex);
    
    return o;
}

half4 frag (v2f i) : SV_Target
{
    half4 col = tex2D(_OutlineTex,i.uv) * _Color;
    return col;
}
#endif //OUTLINE_ONLY_PASS_HLSL