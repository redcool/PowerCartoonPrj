Shader "Unlit/OutlineOnly"
{
    Properties
    {
        [Header(Outline)]
        _OutlineTex("_OutlineTex",2d) = "white"{}
        [hdr]_Color("_Color",color)  =(1,1,1,1)
        _Width("_Width",range(0.002,1)) = 0.01
        [GroupToggle]_KeepWidth("_KeepWidth",int) = 1

        _WidthLocalYAtten("_WidthLocalYAtten",float) = -1
        _ZOffset("_ZOffset",range(0,1)) = 0.9

        [Toggle(_VERTEX_COLOR_ATTEN)]_VertexColorAttenOn("_VertexColorAttenOn",float) = 1

        [Header(Fresnel)]
        [Toggle(_APPLY_FRESNEL)]_ApplyFresnel("_ApplyFresnel",int) = 0
        _FresnelMin("_FresnelMin",range(0,1))=0.5
        _FresnelMax("_FresnelMax",range(0,1))=0.9

        [Header(Noise Map)]    
        _NoiseMap("_NoiseMap",2d) = "bump"{}

        [Header(Noise UV)]
        [Toggle(_NOISE_MAP_ON)]_NoiseMapOn("_NoiseMapOn",int) = 0
        [GroupToggle]_NoiseOffsetAutoStop("_NoiseOffsetAutoStop",float) = 0
        _NoiseAlphaScale("_NoiseAlphaScale",float) = 1
        _NoiseAlphaBase("_NoiseAlphaBase",range(-1,1)) = 0

        [Header(Noise Vertex)]
        [Toggle(_NOISE_VERTEX_ON)]_NoiseVertexOn("_NoiseVertexOn",int) = 0
        _NoiseWaveScale("_NoiseWaveScale",float) = 0.3
        [GroupToggle]_NoiseWaveAutoStop("_NoiseWaveAutoStop",float) = 0
        _BaseLocalY("_BaseLocalY",float) = 0
        _VertexMoveMode("_VertexMoveMode",range(0,1)) = 0.5

        [Header(Render States)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 10
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        blend [_SrcMode][_DstMode]

        // pass{
        //     colorMask 0
        //     zwrite on
        // }

        Pass
        {
            cull [_CullMode]
            // ztest greater
            // zwrite off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _VERTEX_COLOR_ATTEN
            #pragma shader_feature_local_vertex _NOISE_VERTEX_ON
            #pragma shader_feature_local_fragment _NOISE_MAP_ON
            #pragma shader_feature_local_fragment _APPLY_FRESNEL

            #include "Lib/OutlineOnlyPass.hlsl"
            ENDHLSL
        }

        // UsePass "Universal Render Pipeline/Unlit/DEPTHONLY"
    }
}
