Shader "Unlit/OutlineOnly"
{
    Properties
    {
        _OutlineTex("_OutlineTex",2d) = "white"{}
        _Color("_Color",color)  =(1,1,1,1)
        _Width("_Width",range(0.002,.1)) = 0.01
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

            #include "Lib/OutlineOnlyPass.hlsl"
            ENDHLSL
        }

        // UsePass "Universal Render Pipeline/Unlit/DEPTHONLY"
    }
}
