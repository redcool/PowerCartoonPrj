Shader "Character/Unlit/OutlineOnly"
{
    Properties
    {
        [Group(Outline)]
        [GroupItem(Outline)]_OutlineTex("_OutlineTex",2d) = "white"{}
        [GroupItem(Outline)][hdr]_Color("_Color",color)  =(1,1,1,1)
        [GroupItem(Outline)]_Width("_Width",range(0.002,1)) = 0.01
        [GroupToggle(Outline)]_KeepWidth("_KeepWidth",int) = 1

        [GroupItem(Outline,atten alone local Y direction)]_WidthLocalYAtten("_WidthLocalYAtten",float) = -1
        [GroupItem(Outline)]_ZOffset("_ZOffset",range(0,1)) = 0.95

        [GroupToggle(Outline,,atten use vertex color.x)]_VertexColorAttenOn("_VertexColorAttenOn",float) = 1

        [GroupHeader(Main,Scale)]
        [GroupItem(Main)]_ObjectScale("_ObjectScale",range(1,1.05)) = 1
//================================================= Fresnel
        [Group(Fresnel)]
        [GroupToggle(Fresnel,_APPLY_FRESNEL)]_ApplyFresnel("_ApplyFresnel",int) = 0
        [GroupItem(Fresnel)]_FresnelMin("_FresnelMin",range(0,1))=0.5
        [GroupItem(Fresnel)]_FresnelMax("_FresnelMax",range(0,1))=0.9
//================================================= Noise
        [Group(Noise)]
        [GroupHeader(Noise,Noise Map)]
        [GroupItem(Noise)]_NoiseMap("_NoiseMap",2d) = "bump"{}

        [GroupHeader(Noise,Noise Apply UV)]
        [GroupToggle(Noise,_NOISE_MAP_ON)]_NoiseMapOn("_NoiseMapOn",int) = 0
        [GroupToggle(Noise)]_NoiseOffsetAutoStop("_NoiseOffsetAutoStop",float) = 0
        [GroupItem(Noise)]_NoiseAlphaScale("_NoiseAlphaScale",float) = 1
        [GroupItem(Noise)]_NoiseAlphaBase("_NoiseAlphaBase",range(-1,1)) = 0

        [GroupHeader(Noise,Noise Apply Vertex)]
        [GroupToggle(Noise,_NOISE_VERTEX_ON)]_NoiseVertexOn("_NoiseVertexOn",int) = 0
        [GroupItem(Noise)]_NoiseWaveScale("_NoiseWaveScale",float) = 0.3
        [GroupToggle(Noise)]_NoiseWaveAutoStop("_NoiseWaveAutoStop",float) = 0
        [GroupItem(Noise)]_BaseLocalY("_BaseLocalY",float) = 0
        [GroupItem(Noise,left use normal direction right use vertex direction)]_VertexMoveMode("_VertexMoveMode",range(0,1)) = 0.5
//================================================= Alpha
        [Group(Alpha)]
        // [GroupHeader(Alpha,AlphaTest)]
        // [GroupToggle(Alpha,ALPHA_TEST)]_ClipOn("_AlphaTestOn",int) = 0
        // [GroupSlider(Alpha)]_Cutoff("_Cutoff",range(0,1)) = 0.5
        
        // [GroupHeader(Alpha,Premultiply)]
        // [GroupToggle(Alpha)]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [GroupHeader(Alpha,BlendMode)]
        [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0
        // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        [HideInInspector]_SrcMode("_SrcMode",int) = 1
        [HideInInspector]_DstMode("_DstMode",int) = 0

//================================================= settings
        [Group(Settings)]
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
        [Header(Color Mask)]
        [GroupEnum(_,RGBA 16 RGB 15 RG 12 GB 6 RB 10 R 8 G 4 B 2 A 1 None 0)] _ColorMask("_ColorMask",int) = 15
        // ================================================== stencil settings
        [Group(Stencil)]
        [GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 0
        [GroupStencil(Stencil)] _Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        [GroupHeader(Stencil,)]
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilFailOp ("Stencil Fail Operation", Float) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("Stencil zfail Operation", Float) = 0
        [GroupItem(Stencil)] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [GroupItem(Stencil)] _StencilReadMask ("Stencil Read Mask", Float) = 255
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100

        Pass
        {
            blend [_SrcMode][_DstMode]
            zwrite[_ZWriteMode]
            ztest[_ZTestMode]
            cull [_CullMode]
            ColorMask [_ColorMask]

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma shader_feature_local _VERTEX_COLOR_ATTEN
            #pragma shader_feature_local_vertex _NOISE_VERTEX_ON
            #pragma shader_feature_local_fragment _NOISE_MAP_ON
            #pragma shader_feature_local_fragment _APPLY_FRESNEL

            #include "Lib/OutlineOnlyPass.hlsl"
            ENDHLSL
        }

        // UsePass "Universal Render Pipeline/Unlit/DEPTHONLY"
    }
}
