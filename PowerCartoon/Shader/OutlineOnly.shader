Shader "Unlit/OutlineOnly"
{
    Properties
    {
        [Header(Outline)]
        _OutlineTex("_OutlineTex",2d) = "white"{}
        [hdr]_Color("_Color",color)  =(1,1,1,1)
        _Width("_Width",range(0.002,0.2)) = 0.01
        _WidthLocalYAtten("_WidthLocalYAtten",float) = -1
        _ZOffset("_ZOffset",range(0,1)) = 0.9

        [Toggle(_VERTEX_COLOR_ATTEN)]_VertexColorAttenOn("_VertexColorAttenOn",float) = 1
        [Toggle(_APPLY_FRESNEL)]_ApplyFresnel("_ApplyFresnel",int) = 0

        [Header(Noise)]
        [Toggle(_NOISE_MAP_ON)]_NoiseMapOn("_NoiseMapOn",int) = 0
        _NoiseMap("_NoiseMap",2d) = ""{}
        _NoiseAlphaScale("_NoiseAlphaScale",float) = 1
        _NoiseAlphaBase("_NoiseAlphaBase",range(-1,1)) = 0

        [Header(Noise Vertex)]
        [Toggle(_NOISE_VERTEX_ON)]_NoiseVertexOn("_NoiseVertexOn",int) = 0
        _NoiseWaveScale("_NoiseWaveScale",float) = 0.3
        _BaseLocalY("_BaseLocalY",float) = 0

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
