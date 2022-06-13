Shader "Character/PowerCartoon"
{
    Properties
    {
        [Header(Main )]
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("_NormalMap",2d) = "bump"{}
        _NormalScale("_NormalScale",float) = 1

        [Header(PBR Mask)]
        _PBRMask("_PBRMask(Metallix:r,Smoothness:g,Occlusion:b)",2d) = "white"{}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("_Smoothness",range(0,1)) = 0.5
        _Occlusion("_Occlusion",range(0,1)) = 0

        [Header(Ambient)]
        _DiffuseMin("_DiffuseMin",range(0,1)) = 0.1

        [Header(Diffuse Step)]
        _DiffuseStepMin("_DiffuseStepMin",range(0,1)) = 0
        _DiffuseStepMax("_DiffuseStepMax",range(0,1)) = 1
        [IntRange]_DiffuseStepCount("_DiffuseStepCount",range(1,5)) = 1

        [Header(PreSSS)]
        [Toggle(_PRESSS)]_ScatterOn("_Scatter",float) = 0
        _ScatterLUT("_ScatterLUT",2d) = "white"{}
        _ScatterCurve("_ScatterCurve",range(0,1)) = 0
        _ScatterIntensity("_ScatterIntensity",float) = 1
        [Toggle]_PreScatterMaskUseMainTexA("_PreScatterMaskUseMainTexA",float) = 0

        [Header(Rim)]
        [Toggle(_RIMON)]_RimOn("_RimOn",int) = 0
        _RimColor("_RimColor",color) = (1,1,1,1)
        _RimStepMin("_RimStepMin",range(0,1)) = 0
        _RimStepMax("_RimStepMax",range(0,1)) = 1

        [Header(Custom Light View)]
        _LightDirOffset("_LightDirOffset",vector)=(0,0,0,0)
        _ViewDirOffset("_ViewDirOffset",vector) = (0,0,0,0)

        [Header(Shadow )]
        [Toggle]_ReceiveShadow("_ReceiveShadow",int) = 1
        _MainLightShadowSoftScale("_MainLightShadowSoftScale",Range(0,2))=0.1
        _CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0
        _CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0
    }
    SubShader
    {

        Pass
        {
            Tags{"LightMode"="UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS_ON

            #pragma shader_feature_local_fragment _PRESSS
            #pragma shader_feature_local_fragment _RIMON

            #include "Lib/ForwardPass.hlsl"
            
            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            // ZWrite On
            // ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #define SHADOW_PASS 
            #include "Lib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass{
            Tags{"LightMode" = "DepthOnly"}

            // ZWrite On
            // ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 

            #include "Lib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
    }
}
