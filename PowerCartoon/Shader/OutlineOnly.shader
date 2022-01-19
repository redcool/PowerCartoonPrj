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
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            cull front
            // ztest greater
            // zwrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lib/OutlineOnlyPass.hlsl"
            ENDCG
        }
    }
}
