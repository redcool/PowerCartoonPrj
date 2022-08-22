#if !defined(PBR_INPUT_HLSL)
#define PBR_INPUT_HLSL
#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"

sampler2D _MainTex;
sampler2D _PBRMask;
// samplerCUBE unity_SpecCube0;
sampler2D _NormalMap;
sampler2D _ScatterLUT;

CBUFFER_START(UnityPerMaterial)
half4 _MainTex_ST;
half _Smoothness, _Metallic,_Occlusion;

half _NormalScale;

half _DiffuseMin,_DiffuseStepMin,_DiffuseStepMax,_DiffuseStepCount;
half _SpecStepMax,_SpecStepMin;
// half _GISpecIntensity;
half _ScatterCurve,_ScatterIntensity,_PreScatterMaskUseMainTexA;

half4 _RimColor;
half _RimStepMin,_RimStepMax;

half3 _LightDirOffset,_ViewDirOffset;

half _ReceiveShadow;
half _MainLightShadowSoftScale;
half _CustomShadowDepthBias,_CustomShadowNormalBias;
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