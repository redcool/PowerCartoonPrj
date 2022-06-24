#if !defined(OUTLINE_ONLY_PASS_HLSL)
#define OUTLINE_ONLY_PASS_HLSL
#include "UnityLib.hlsl"

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
    float2 uv:TEXCOORD;
    half4 color:COLOR;
};

sampler2D _OutlineTex;

CBUFFER_START(UnityPerMaterial)
half _Width;
half4 _Color;
half4 _OutlineTex_ST;
half _VertexColorAttenOn;
half _ShowPolyEdge;
CBUFFER_END

#define MUL_VERTEX_COLOR_ATTEN(v) (_VertexColorAttenOn? v.color.x : 1)

v2f vert (appdata v)
{
    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.vertex.z *= _ShowPolyEdge ? 0.9 : 1;

    half3 normalView = mul((half3x3)UNITY_MATRIX_IT_MV,v.normal);
    half3 normalClip = normalize(TransformViewToProjection(normalView));

    o.vertex.xy += normalClip.xy * _Width * o.vertex.w * MUL_VERTEX_COLOR_ATTEN(v)*0.1;

    o.color = v.color;
    o.uv= TRANSFORM_TEX(v.uv,_OutlineTex);
    
    return o;
}

half4 frag (v2f i) : SV_Target
{
    half4 col = tex2D(_OutlineTex,i.uv) * _Color * MUL_VERTEX_COLOR_ATTEN(i);
    return col;
}
#endif //OUTLINE_ONLY_PASS_HLSL