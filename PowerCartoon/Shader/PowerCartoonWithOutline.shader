Shader "Character/PowerCartoon With Outline"
{
    Properties
    {
        [LineHeader(Main )]
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("_NormalMap",2d) = "bump"{}
        _NormalScale("_NormalScale",float) = 1

        [LineHeader(PBR Mask)]
        _PBRMask("_PBRMask(Metallix:r,Smoothness:g,Occlusion:b)",2d) = "white"{}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("_Smoothness",range(0,1)) = 0.5
        _Occlusion("_Occlusion",range(0,1)) = 0

        [LineHeader(Ambient)]
        _DiffuseMin("_DiffuseMin",range(0,1)) = 0.1

        [LineHeader(Diffuse Step)]
        _DiffuseStepMin("_DiffuseStepMin",range(0,1)) = 0.1
        _DiffuseStepMax("_DiffuseStepMax",range(0,1)) = 0.3
        [IntRange]_DiffuseStepCount("_DiffuseStepCount",range(1,5)) = 1


        [LineHeader(PreSSS)]
        [Toggle(_PRESSS)]_ScatterOn("_Scatter",float) = 0
        _ScatterLUT("_ScatterLUT",2d) = "white"{}
        _ScatterCurve("_ScatterCurve",range(0,1)) = 0
        _ScatterIntensity("_ScatterIntensity",float) = 1
        [Toggle]_PreScatterMaskUseMainTexA("_PreScatterMaskUseMainTexA",float) = 0

        [LineHeader(Rim)]
        [Toggle(_RIMON)]_RimOn("_RimOn",int) = 0
        _RimColor("_RimColor",color) = (1,1,1,1)
        _RimStepMin("_RimStepMin",range(0,1)) = 0
        _RimStepMax("_RimStepMax",range(0,1)) = 1

        [LineHeader(Custom Light View)]
        _LightDirOffset("_LightDirOffset",vector)=(0,0,0,0)
        _ViewDirOffset("_ViewDirOffset",vector) = (0,0,0,0)

        [LineHeader(Outline Pass)]
        _OutlineTex("_OutlineTex(A:Outline Mask)",2d) = "white"{}
        _Color("_Color",color)  =(1,1,1,1)
        _Width("_Width",range(0.002,.01)) = 0.003
    }
    SubShader
    {
        Pass
        {
            // Tags{"LightMode"="ForwardBase"}
            // Tags{"LightMode"="UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local_fragment _PRESSS
            #pragma shader_feature_local_fragment _RIMON

            #define DRP
            #include "Lib/ForwardPass.hlsl"
            
            ENDHLSL
        }

        Pass{
            // cull front
            // Tags{"RenderQueue"="Transparent"}
            // Blend SrcAlpha OneMinusSrcAlpha
            // zwrite off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lib/OutlineOnlyPass.hlsl"
            ENDHLSL
        }

    }
}
