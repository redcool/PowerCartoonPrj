// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/MatchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle] _BumpSwitch("BumpSwitch",Int)=0
        [Toggle] _ACES("ACES_Switch",Int)=0
        _BumpMapScale("BumpSize",Range(-2,2))=1
        _BumpTex ("BumpTex",2D) = "white" {}
        _RampTex("RampTex",2D) ="white"{}
        _Metallic("Metallic",Range(0,1))=1
        _Smoothness("Roughness",Range(0,1))=1
        _EmissionSize("EmissionSize",Range(0,10))=1
        _ChangeMap("R=>Metal  G=>Roughness B=> Emission A=>AO",2D)="white"{}
        _FresnelColor("FresnelColor",Color)=(1,1,1,1)
        _FresnelPow("FresnelPow",Float)=1
        _FresnelSize("FresnelSize",Float)=1

        _Ao("AoSize",Range(0,1))=1




        //_PointColor1("PointColor1",Color)=(1,1,1,1)
        [HideInInspector]_PointLight1("PointLight1(xyz=>Pos  w=>Intensity)",Vector)=(0,0,0,1)
        _PointLight1Spec("_PointLight1Spec",Float)=1
        //_PointColor2("PointColor2",Color)=(1,1,1,1)
        [HideInInspector]_PointLight2("PointLight2(xyz=>Pos  w=>Intensity)",Vector)=(0,0,0,1)
        _PointLight2Spec("_PointLight2Spec",Float)=1

        _OutlineFactor("OutlineFactor",Float)=1
        _OutlineColor("OutlineColor",Color)=(0,0,0,1)

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "LightMode"="ForwardBase"}

        Pass{

            Cull Front
            ZWrite off

            //Offset 2,2
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineFactor;

            struct v2f{
                float4 pos:SV_POSITION;
            };
            v2f vert(appdata_full v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                // float2 offset = TransformViewToProjection(vnormal.xy);

                float2 offset = mul((float2x2)UNITY_MATRIX_P,vnormal.xy);
                o.pos.xy+=offset*_OutlineFactor;
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                return _OutlineColor;
            }
            ENDCG
        }


        Pass
        {
            Zwrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma shader_feature_local _BUMPSWITCH_ON 
            #pragma shader_feature_local _ACES_ON 

            #define HALF_MIN 6.103515625e-5
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            float3 ACESFilm(float3 x){
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x*(a*x+b))/(x*(c*x+d)+e));
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent :TANGENT;
                float4 color :COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL0;
                float3 tangentWS:TEXCOORD4;
                float3 bitangentWS:TEXCOORD1;
                float4 color : COLOR0;
                float3 worldPos : TEXCOORD2;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            sampler2D _BumpTex;
            sampler2D _RampTex;
            sampler2D _ChangeMap;
            float4 _BumpTex_ST;
            float4 _MainTex_ST;
            float4 _FresnelColor;
            float _BumpMapScale;
            float _FresnelPow;
            float _FresnelSize;
            float4 _PointColor1;
            float4 _PointColor2;
            float4 _PointLight1;
            float4 _PointLight2;
            float _PointLight1Spec;
            float _PointLight2Spec;
            fixed _Ao;
            fixed _Metallic;
            fixed _Smoothness;
            half _EmissionSize;
            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                float3 normalWS = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.normalWS =v.normal;
#ifdef _BUMPSWITCH_ON
                float3 tangentWS;// = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,1))).xyz;
                tangentWS = normalize(v.tangent.xyz);
                float3 bitangnetWS = cross(normalWS,tangentWS)*v.tangent.w*unity_WorldTransformParams.w;
                o.tangentWS = tangentWS;
                o.bitangentWS = bitangnetWS;
#endif
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TRANSFER_SHADOW(o)
                return o;
            }

            half3 m_DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
            {
                specColor = lerp (float3(0.04,0.04,0.04), albedo, metallic);
                oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);
                return albedo * oneMinusReflectivity;
            }
            half3 DirectBDRF(float3 L,float3 V,float3 N,float roughness2MinusOne,float roughness2,float normalizationTerm,half3 SpecColor){
                float3 H = normalize(L+V);
                float NoH = saturate(dot(N,H));
                half LoH = saturate(dot(L,H));
                float d =NoH*NoH*roughness2MinusOne +1.000001f;
                half LoH2 = LoH*LoH;
                half specularTerm = roughness2/((d*d)*max(0.1h,LoH2));
                //half range = 1-step(specularTerm,3.5f);
                return specularTerm*SpecColor;
            }

            float3 VirtualLight(float4 LightValue,float4 LightColor,float3 worldPos){
                float3 lightPos = LightValue.xyz-worldPos;
                float distanceSqr = sqrt(dot(lightPos.xyz,lightPos.xyz));
                float3 lightAtten = rcp(distanceSqr)*LightColor.rgb*LightValue.w;
                return lightAtten;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                i.normalWS = normalize(mul(i.normalWS,(float3x3)unity_WorldToObject));
                float3 normalNotMap = i.normalWS;
                float3 normalWS = i.normalWS;
                

#ifdef _BUMPSWITCH_ON
                half3x3 tangentToWorldMatrix = half3x3((i.tangentWS.xyz),normalize(i.bitangentWS),(i.normalWS));
                float4 normalMap = tex2D(_BumpTex,i.uv*_BumpTex_ST.xy+_BumpTex_ST.zw);
                normalMap.xy *= _BumpMapScale;
                normalMap.z = sqrt(1-saturate(dot(normalMap.xy,normalMap.xy)));
                float3 normalTS = UnpackNormal(normalMap);
                normalWS = normalize(mul(normalTS,tangentToWorldMatrix)); 
#endif

                float4 changeTex = tex2D(_ChangeMap,i.uv);
                float Matel = changeTex.r;
                float Smooth = changeTex.g;
                float Emission = changeTex.b;
                float AO = changeTex.w;

                

                float3 ambient = ShadeSH9(float4(normalWS,1));
                //return float4(ambient,1);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 R = normalize(reflect(-V,normalWS));
                float atten=SHADOW_ATTENUATION(i);
                fixed4 col = tex2D(_MainTex, i.uv);
//return float4(col.rgb,1);
                float NdotL = saturate(dot(normalWS,L)*atten*col.a);
                float2 newUV = float2(float2(NdotL,i.uv.y));
                fixed4 rampTex = tex2D(_RampTex,newUV);

                float FresnelIns = 1-step(pow(1-(dot(normalNotMap,V)*0.5+0.5),_FresnelPow)*_FresnelSize,0.5f);
                
                
                

                float3 pointLight1 = VirtualLight(_PointLight1,_PointColor1,i.worldPos);
                float3 pointLight2 = VirtualLight(_PointLight2,_PointColor2,i.worldPos);
                float3 pointLight1_Pos = normalize(_PointLight1.xyz-i.worldPos.xyz);
                float3 pointLight2_Pos = normalize(_PointLight2.xyz-i.worldPos.xyz);

//拟合PBR
                float metallic = _Metallic*Matel;


                float Smoothness =  _Smoothness*Smooth;
                half oneMinusReflectivity;
                half3 SpecColor=float3(0,0,0);
                half3  Dcol = m_DiffuseAndSpecularFromMetallic (col.rgb, metallic, /*out*/ SpecColor, /*out*/ oneMinusReflectivity);


                half reflectivity = 1.0 - oneMinusReflectivity;

                float perceptualRoughness =1.0h-Smoothness;
                float Roughness = max(perceptualRoughness*perceptualRoughness,HALF_MIN); 
                float Roughness2 = Roughness*Roughness;
                float Roughness2MinusOne = Roughness2-1.0h;

                float3 spec =DirectBDRF(L,V,normalWS,Roughness2MinusOne,Roughness2,1,SpecColor);
                float mipmap = Roughness*7;
                float4 cubeMap = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,R,mipmap);
                float3 cubeMapDecode = DecodeHDR(cubeMap,unity_SpecCube0_HDR);

                col.rgb = lerp(col.rgb,col.rgb*AO,_Ao);

                float4 finalColor=float4(0,0,0,1);

                finalColor.rgb = lerp(col.rgb*rampTex,col.rgb*cubeMapDecode,1-oneMinusReflectivity)
                                +spec.rgb*_LightColor0.rgb*AO
                                +col.rgb *ambient.rgb
                                +pointLight1*col.rgb
                                +pointLight2*col.rgb
                                +FresnelIns*_FresnelColor.rgb*saturate(dot(pointLight1_Pos,normalNotMap))*pointLight1*_PointLight1Spec
                                +FresnelIns*_FresnelColor.rgb*saturate(dot(pointLight2_Pos,normalNotMap))*pointLight2*_PointLight2Spec
                                ;
#if _ACES_ON
                finalColor.rgb = ACESFilm(finalColor.rgb);
#endif
                finalColor.rgb += Emission*col.rgb*_EmissionSize;
                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
