#if !defined(SHADOW_CASTER_PASS_HLSL)
#define SHADOW_CASTER_PASS_HLSL

#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../../PowerShaderLib/URPLib/URP_MainLightShadows.hlsl"


struct v2f{
    half2 uv:TEXCOORD0;
    half4 pos:SV_POSITION;
};

struct appdata
{
    float4 vertex   : POSITION;
    float3 normal     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
};

half3 _LightDirection;
float3 _LightPosition;

//--------- shadow helpers
half4 GetShadowPositionHClip(appdata input){
    half3 worldPos = mul(unity_ObjectToWorld,input.vertex).xyz;
    half3 worldNormal = TransformObjectToWorldNormal(input.normal);

    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize(_LightPosition - worldPos);
#else
    float3 lightDirectionWS = _LightDirection;
#endif

    half4 positionCS = TransformWorldToHClip(ApplyShadowBias(worldPos,worldNormal,lightDirectionWS,0,0));
    #if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif
    return positionCS;
}

v2f vert(appdata input){
    v2f output;

    #if defined(SHADOW_PASS)
        output.pos = GetShadowPositionHClip(input);
    #else 
        output.pos = TransformObjectToHClip(input.vertex);
    #endif
    output.uv = TRANSFORM_TEX(input.texcoord,_MainTex);
    return output;
}

half4 frag(v2f input):SV_Target{
    #if defined(_ALPHA_TEST)
    if(_AlphaTestOn){
        half4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,input.uv);
        clip(tex.a - _Cutoff);
    }
    #endif
    return 0;
}

#endif //SHADOW_CASTER_PASS_HLSL