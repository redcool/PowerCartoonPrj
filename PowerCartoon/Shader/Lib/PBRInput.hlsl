#if !defined(PBR_INPUT_HLSL)
#define PBR_INPUT_HLSL
#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../../PowerShaderLib/Lib/MaskLib.hlsl"

sampler2D _MainTex;
sampler2D _PbrMask;
// samplerCUBE unity_SpecCube0;
sampler2D _NormalMap;
sampler2D _ScatterLUT;
sampler2D _EmissionMap;

CBUFFER_START(UnityPerMaterial)
half4 _MainTex_ST;
half4 _Color;
half _Smoothness, _Metallic,_Occlusion;
half _AlphaFaceShadowMask,_FaceDiffuse;
half _Saturate,_Illumination;//_Constract;

half _BelowColorOn, _VertexY;
half2 _ColorRate;
half4 _BelowColor;

half _NormalScale;

half _DiffuseMin,_DiffuseStepMin,_DiffuseStepMax,_DiffuseStepCount;
half _SpecStepMax,_SpecStepMin;
// half _GISpecIntensity;
half _ScatterCurve,_ScatterIntensity,_PreScatterMaskUseMainTexA;

half4 _RimColor;
half _RimReceiveMainLightColor;
half _RimStepMin,_RimStepMax;
half _InkPaintOn, _InkPaintMin,_InkPaintMax;
half4 _InkPaintColor;

half _CustomLightOn;
half3 _LightDirOffset, _CustomLightColor;
half3 _ViewDirOffset;

half _ReceiveShadowOff;
half _MainLightShadowSoftScale;
half _CustomShadowDepthBias,_CustomShadowNormalBias;

half _EmissionOn;
half4 _EmissionColor;
half _EmissionMaskFrom,_EmissionMode;
//----------------------------------------
half _AlphaPremultiply;
half _Cutoff;

CBUFFER_END

half CustomShadowDepthBias(){
    return _CustomShadowDepthBias;
    // return lerp(-1,1,_CustomShadowDepthBias);
}
half CustomShadowNormalBias(){
    return _CustomShadowNormalBias;
    // return lerp(-1,1,_CustomShadowNormalBias);
}

#endif //PBR_INPUT_HLSL