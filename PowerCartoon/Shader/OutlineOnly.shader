Shader "Unlit/OutlineOnly"
{
    Properties
    {
        _OutlineTex("_OutlineTex",2d) = "white"{}
        _Color("_Color",color)  =(1,1,1,1)
        _Width("_Width",range(0.002,.1)) = 0.01

        [Toggle(_VERTEX_COLOR_ATTEN)]_VertexColorAtten("_VertexColorAtten",float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        blend srcAlpha oneMinusSrcAlpha

        Pass
        {
            cull front
            // ztest greater
            zwrite off

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
