Shader "Unlit/OutlineOnly"
{
    Properties
    {
        _OutlineTex("_OutlineTex",2d) = "white"{}
        _Color("_Color",color)  =(1,1,1,1)
        _Width("_Width",range(0.002,.1)) = 0.01

        [Header(Atten)]
        [Toggle(_VERTEX_COLOR_ATTEN)]_VertexColorAttenOn("_VertexColorAttenOn",float) = 1

        [Header(Blend)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        blend [_SrcMode][_DstMode]

        Pass
        {
            cull front
            // ztest greater
            // zwrite off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _VERTEX_COLOR_ATTEN

            #include "Lib/OutlineOnlyPass.hlsl"
            ENDHLSL
        }

        // UsePass "Universal Render Pipeline/Unlit/DEPTHONLY"
    }
}
