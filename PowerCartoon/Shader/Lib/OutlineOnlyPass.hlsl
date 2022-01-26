#if !defined(OUTLINE_ONLY_PASS_HLSL)
#define OUTLINE_ONLY_PASS_HLSL
#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal:NORMAL;
    float2 uv:TEXCOORD;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv:TEXCOORD;
};

float _Width;
float4 _Color;
sampler2D _OutlineTex;
float4 _OutlineTex_ST;

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.vertex.z *= 0.9;
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
    float3 normalClip = mul((float3x3)UNITY_MATRIX_VP,worldNormal);

    // float3 normalView = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
    // float3 normalClip = normalize(TransformViewToProjection(normalView));
    o.vertex.xy += normalClip.xy * _Width * o.vertex.w;

    o.uv= TRANSFORM_TEX(v.uv,_OutlineTex);
    
    return o;
}

float4 frag (v2f i) : SV_Target
{
    float4 col = tex2D(_OutlineTex,i.uv) * _Color;
    return col;
}
#endif //OUTLINE_ONLY_PASS_HLSL