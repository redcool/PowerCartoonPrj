Shader "Character/PowerCartoon"
{
    Properties
    {
        [Group(Main )]
        [GroupItem(Main)]_MainTex ("Texture", 2D) = "white" {}
        [GroupItem(Main)]_BaseColor ("_BaseColor", color) = (1,1,1,1)
        [GroupItem(Main)]_NormalMap("_NormalMap",2d) = "bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",float) = 1

        [Group(PBR Mask)]
        [GroupItem(PBR Mask)]_PBRMask("_PBRMask(Metallix:r,Smoothness:g,Occlusion:b)",2d) = "white"{}
        [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0

        [Group(Diffuse Step)]
        [GroupItem(Diffuse Step)]_DiffuseMin("_DiffuseMin",range(0,1)) = 0.1
        [GroupItem(Diffuse Step)]_DiffuseStepMin("_DiffuseStepMin",range(0,1)) = 0
        [GroupItem(Diffuse Step)]_DiffuseStepMax("_DiffuseStepMax",range(0,1)) = 1
        [GroupItem(Diffuse Step)]_DiffuseStepCount("_DiffuseStepCount",range(1,5)) = 1

        [Group(Spec)]
        [GroupItem(Spec Step)]_SpecStepMin("_SpecStepMin",range(0,1)) = 0
        [GroupItem(Spec Step)]_SpecStepMax("_SpecStepMax",range(0,1)) = 1
        // [GroupItem(Spec Step)]_GISpecIntensity("_GISpecIntensity",range(0,1)) = 1

        [Group(PreSSS)]
        [GroupToggle(PreSSS,_PRESSS)]_ScatterOn("_Scatter",float) = 0
        [GroupItem(PreSSS)]_ScatterLUT("_ScatterLUT",2d) = "white"{}
        [GroupItem(PreSSS)]_ScatterCurve("_ScatterCurve",range(0,1)) = 0
        [GroupItem(PreSSS)]_ScatterIntensity("_ScatterIntensity",float) = 1
        [GroupToggle(PreSSS)]_PreScatterMaskUseMainTexA("_PreScatterMaskUseMainTexA",float) = 0

        [Group(RimAdd)]
        [GroupToggle(RimAdd,_RIMON)]_RimOn("_RimOn",int) = 0
        [GroupItem(RimAdd)][hdr]_RimColor("_RimColor",color) = (1,1,1,1)
        [GroupItem(RimAdd)]_RimStepMin("_RimStepMin",range(0,1)) = 0
        [GroupItem(RimAdd)]_RimStepMax("_RimStepMax",range(0,1)) = 1

        [Group(Custom Light View)]
        [GroupItem(Custom Light View)]_LightDirOffset("_LightDirOffset",vector)=(0,0,0,0)
        [GroupItem(Custom Light View)]_ViewDirOffset("_ViewDirOffset",vector) = (0,0,0,0)

        [Group(Shadow)]
        [GroupToggle(Shadow)]_ReceiveShadow("_ReceiveShadow",int) = 1
        [GroupToggle(Shadow,PRECISION_SHADOW)]_PrecisionShadow("_PrecisionShadow",int) = 1
        [GroupItem(Shadow)]_MainLightShadowSoftScale("_MainLightShadowSoftScale",Range(0,2))=0.1
        [GroupItem(Shadow)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0
        [GroupItem(Shadow)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0

        [Group(InkPaint)]
        [GroupToggle(InkPaint)]_InkPaintOn("_InkPaintOn",int)=0
        [GroupItem(InkPaint)]_InkPaintColor("_InkPaintColor",color)=(0,0,0,0)
        [GroupItem(InkPaint)]_InkPaintMin("_InkPaintMin",range(0,1))=0
        [GroupItem(InkPaint)]_InkPaintMax("_InkPaintMax",range(0,1))=1

        [Group(Emission)]
        [GroupToggle(Emission,_EMISSION)]_EmissionOn("_EmissionOn",int)=0
        [GroupItem(Emission)]_EmissionMap("_EmissionMap",2d)="white"{}
        [GroupEnum(Emission,None 0 MainTex.a 1 EmissionMap.a 2)]_EmissionMaskFrom("_EmissionMaskFrom",int)=0
        [GroupItem(Emission)][hdr]_EmissionColor("_EmissionColor",color)=(1,1,1,1)
        [GroupEnum(Emission, Blend 0 Add 1)][hdr]_EmissionMode("_EmissionMode",int) = 0
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

            #pragma shader_feature_fragment _PRESSS
            #pragma shader_feature_fragment _RIMON
            #pragma shader_feature_local_fragment PRECISION_SHADOW
            #pragma shader_feature_fragment _EMISSION

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
