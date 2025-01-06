Shader "Character/PowerCartoon"
{
    Properties
    {
        [GroupHeader(v2.0.6)]
        [Group(Main )]
        [GroupItem(Main)]_MainTex ("Texture", 2D) = "white" {}
        [GroupItem(Main)]_Color ("_Color", color) = (1,1,1,1)
        [GroupItem(Main)]_NormalMap("_NormalMap",2d) = "bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",float) = 1

        [GroupHeader(Main,Color)]
        [GroupItem(Main)] _Saturate("_Saturate",float) = 1
        [GroupItem(Main)] _Illumination("_Illumination",float) = 1
        // [GroupItem(Main)] _Constract("_Constract",range(0,1)) = 1

        [GroupHeader(Main,Topdown Colors)]
        [GroupToggle(Main,)] _BelowColorOn("_BelowColorOn",float) = 0
        [GroupItem(Main,)] _BelowColor("_BelowColor",color) = (1,1,1,1)
        [GroupVectorSlider(Main,min max,0_1 0_1)] _ColorRate("_ColorRate",vector) = (0,1,1,1)
        [GroupItem(Main,contrn blend belowColor baseColor)] _VertexY("_VertexY",float) = 1

        [Group(PBR Mask)]
        [GroupItem(PBR Mask)]_PbrMask("_PbrMask(Metallix:r,Smoothness:g,Occlusion:b)",2d) = "white"{}
        [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0
        
        [GroupHeader(FaceShadowAttenMask)]
        [GroupItem(PBR Mask)]_AlphaFaceShadowMask("_AlphaFaceShadowMask",range(0,1)) = 0

        [Group(Diffuse Step)]
        [GroupItem(Diffuse Step)]_DiffuseMin("_DiffuseMin",range(0,1)) = 0.1
        [GroupItem(Diffuse Step)]_DiffuseStepMin("_DiffuseStepMin",range(0,1)) = 0
        [GroupItem(Diffuse Step)]_DiffuseStepMax("_DiffuseStepMax",range(0,1)) = 1
        [GroupItem(Diffuse Step)]_DiffuseStepCount("_DiffuseStepCount",range(1,5)) = 1

        [GroupHeader(Face Diffuse)]
        [GroupItem(PBR Mask)]_FaceDiffuse("_FaceDiffuse",range(0,1)) = 0
        
        [Group(Spec Step)]
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
        [GroupToggle(RimAdd)]_RimReceiveMainLightColor("_RimReceiveMainLightColor",int) = 0
        [GroupItem(RimAdd)]_RimStepMin("_RimStepMin",range(0,1)) = 0
        [GroupItem(RimAdd)]_RimStepMax("_RimStepMax",range(0,1)) = 1

        [Group(Custom Light)]
        [GroupToggle(Custom Light)]_CustomLightOn("_CustomLightOn",int)= 0
        [GroupItem(Custom Light)]_LightDirOffset("_LightDirOffset",vector)=(0,0,0,0)
        [GroupItem(Custom Light)]_CustomLightColor("_CustomLightColor",color)=(1,1,1,1)

        [Group(Custom View)]
        [GroupItem(Custom View)]_ViewDirOffset("_ViewDirOffset",vector) = (0,0,0,0)

        [Group(Shadow)]
        [GroupToggle(Shadow,_RECEIVE_SHADOWS_OFF)]_ReceiveShadowOff("_ReceiveShadowOff",int) = 0
        [GroupToggle(Shadow,PRECISION_SHADOW,calc shadowCoord in ps)]_PrecisionShadow("_PrecisionShadow",int) = 0
        // [GroupToggle(Shadow,_SHADOWS_SOFT)]_SoftShadowOn("_SoftShadowOn",int) = 0 // urp asset
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
//================================================= Alpha
        [Group(Alpha)]
        [GroupHeader(Alpha,AlphaTest)]
        [GroupToggle(Alpha,ALPHA_TEST)]_ClipOn("_AlphaTestOn",int) = 0
        [GroupSlider(Alpha)]_Cutoff("_Cutoff",range(0,1)) = 0.5
        
        [GroupHeader(Alpha,Premultiply)]
        [GroupToggle(Alpha)]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [GroupHeader(Alpha,BlendMode)]
        [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0 // PowerShaderInspector,will show _PresetBlendMode
        // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        [HideInInspector]_SrcMode("_SrcMode",int) = 1
        [HideInInspector]_DstMode("_DstMode",int) = 0

//================================================= Settings
        [Group(Settings)]
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
        [GroupHeader(Settings,Color Mask)]
        [GroupEnum(Settings,RGBA 16 RGB 15 RG 12 GB 6 RB 10 R 8 G 4 B 2 A 1 None 0)] _ColorMask("_ColorMask",int) = 15

// ================================================== stencil settings
        [Group(Stencil)]
        [GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 0
        [GroupItem(Stencil)] _Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        [GroupItem(Stencil)] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [GroupItem(Stencil)] _StencilReadMask ("Stencil Read Mask", Float) = 255

    }
    SubShader
    {

        Pass
        {
            Tags{"LightMode"="UniversalForward"}

			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			ColorMask [_ColorMask]

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS //_MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS_ON

            #pragma shader_feature_fragment _PRESSS
            #pragma shader_feature_fragment _RIMON
            #pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment ALPHA_TEST

            #pragma shader_feature _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local PRECISION_SHADOW
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #define TOPDOWN_COLORS
            #define FACE_SHADOW_ATTEN_MASK

            #include "Lib/PBRInput.hlsl"
            #include "Lib/ForwardPass.hlsl"
            
            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            cull [_CullMode]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }            

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma shader_feature_fragment ALPHA_TEST
            
            #define SHADOW_PASS 
            #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias
            #include "Lib/PBRInput.hlsl"
            #include "../../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass{
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            cull [_CullMode]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_fragment ALPHA_TEST

            #define USE_SAMPLER2D
            #include "Lib/PBRInput.hlsl"
            #include "../../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass{
            Name "Meta"
            Tags{"LightMode" = "Meta"}
            Cull Off
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma shader_feature_fragment ALPHA_TEST
            // #pragma shader_feature_local_fragment _EMISSION
            #define _EMISSION
            #define _BaseMap _MainTex

            #include "Lib/PBRInput.hlsl"
            // #include "Lib/FastLitMetaPass.hlsl"
            #include "../../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"

            ENDHLSL
        }        
    }
}
