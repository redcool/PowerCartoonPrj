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
//================================================= Blend
        [Header(Blend)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

//================================================= settings
        [Header(Settings)]
        [GroupToggle]_ZWriteMode("_ZWriteMode",int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",int) = 4
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
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
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100

        Pass
        {
            blend [_SrcMode][_DstMode]
            zwrite[_ZWriteMode]
            ztest[_ZTestMode]
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
