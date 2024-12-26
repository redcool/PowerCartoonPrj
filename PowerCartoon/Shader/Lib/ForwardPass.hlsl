#if !defined(FORWARD_PASS_HLSL)
#define FORWARD_PASS_HLSL

#include "../../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../../PowerShaderLib/URPLib/URP_GI.hlsl"
#include "../../../PowerShaderLib/URPLib/URP_MainLightShadows.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 tSpace0:TEXCOORD1;
    float4 tSpace1:TEXCOORD2;
    float4 tSpace2:TEXCOORD3;

    float4 shadowCoord:TEXCOORD4;

};

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
    o.vertex = TransformWorldToHClip(worldPos);
    o.uv = v.uv;

    float3 n = normalize(TransformObjectToWorldNormal(v.normal));
    float3 t = normalize(TransformObjectToWorldDir(v.tangent.xyz));
    float3 b = normalize(cross(n,t)) * v.tangent.w;

    o.tSpace0 = float4(t.x,b.x,n.x,worldPos.x);
    o.tSpace1 = float4(t.y,b.y,n.y,worldPos.y);
    o.tSpace2 = float4(t.z,b.z,n.z,worldPos.z);
    #if !defined(_RECEIVE_SHADOWS_OFF) && !defined(PRECISION_SHADOW)
    o.shadowCoord = TransformWorldToShadowCoord(worldPos);
    #endif
    return o;
}



half4 frag (v2f i) : SV_Target
{
    float3 vertexTangent = (float3(i.tSpace0.x,i.tSpace1.x,i.tSpace2.x));
    float3 vertexBinormal = normalize(float3(i.tSpace0.y,i.tSpace1.y,i.tSpace2.y));
    float3 vertexNormal = normalize(float3(i.tSpace0.z,i.tSpace1.z,i.tSpace2.z));
    float3 tn = UnpackNormalScale(tex2D(_NormalMap,i.uv),_NormalScale);

    float3 n = normalize(float3(
        dot(i.tSpace0.xyz,tn),
        dot(i.tSpace1.xyz,tn),
        dot(i.tSpace2.xyz,tn)
    ));
    // n = vertexNormal;

    float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);

    #if defined(PRECISION_SHADOW)
    i.shadowCoord = TransformWorldToShadowCoord(worldPos);
    #endif

    float shadowAtten = CalcShadow(i.shadowCoord,worldPos,0,_ReceiveShadowOff,_MainLightShadowSoftScale);

    float3 l = GetWorldSpaceLightDir(worldPos) + _LightDirOffset;
    float3 v = normalize(GetWorldSpaceViewDir(worldPos) + _ViewDirOffset);
    float3 h = normalize(l+v);
    float nl = saturate(dot(n,l));
    float originalNL = nl;
    half3 mainLightColor = lerp(_MainLightColor,_CustomLightColor,_CustomLightOn);

    // diffuse smooth
    // nl = smoothstep(_DiffuseStepMin,_DiffuseStepMax,nl);
    // diffuse step smooth
    float idNL = floor(nl * _DiffuseStepCount);
    float idF = frac(nl * _DiffuseStepCount);
    nl = lerp(idNL,idNL+1,smoothstep(_DiffuseStepMin,_DiffuseStepMax,idF))/ _DiffuseStepCount;
    // return nl;

    
    nl = max(_DiffuseMin,nl);

    // pbr
    float nv = saturate(dot(n,v));
    float nh = saturate(dot(n,h));
    // nh = smoothstep(_SpecStepMin,_SpecStepMax,nh);
    // return nh;    
    float lh = saturate(dot(l,h));

    // pbrmask
    half4 pbrMask = tex2D(_PBRMask,i.uv);

    float smoothness = _Smoothness * pbrMask.y;
    float roughness = 1 - smoothness;

    float a = max(roughness * roughness, HALF_MIN_SQRT);
    float a2 = max(a * a ,HALF_MIN);

    float metallic = _Metallic * pbrMask.x;
    float occlusion = lerp(1,pbrMask.b,_Occlusion);

    half4 mainTex = tex2D(_MainTex, i.uv) * _BaseColor;
    half3 albedo = mainTex.xyz;
    
    albedo = lerp(dot(half3(.29,0.58,0.14),albedo),albedo,_Saturate);
    albedo = lerp(0,albedo,_Illumination);
    // albedo = lerp(0.5,albedo,_Constract);

    half alpha = mainTex.w;

    half3 diffColor = albedo * (1 - metallic);
    half3 specColor = lerp(0.04,albedo,metallic);

    half3 sh = SampleSH(n);
    half3 giDiff = sh * diffColor;

    half mip = roughness * (1.7 - roughness * 0.7) * 6;
    half3 reflectDir = reflect(-v,n);
    half4 envColor = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0,samplerunity_SpecCube0,reflectDir,mip);
    envColor.xyz = DecodeHDREnvironment(envColor,unity_SpecCube0_HDR);

    half surfaceReduction = 1/(a2+1);
    
    half grazingTerm = saturate(smoothness + metallic);
    half fresnelTerm = Pow4(1-nv);
    half3 giSpec = surfaceReduction * envColor.xyz * lerp(specColor,grazingTerm,fresnelTerm);
    // giSpec *= _GISpecIntensity;

    half4 col = 0;
    col.xyz = (giDiff + giSpec) * occlusion;

    half3 radiance = nl * mainLightColor * shadowAtten;
    float specTerm = MinimalistCookTorrance(nh,lh,a,a2);
    specTerm = smoothstep(_SpecStepMin,_SpecStepMax,specTerm*0.01)*100;

    col.xyz += (diffColor + specColor * specTerm) * radiance;

    // pre sss
    #if defined(_PRESSS)
        half3 presss = PreScattering(_ScatterLUT,n,l,_MainLightColor.xyz,nl,half4(albedo,alpha),worldPos,_ScatterCurve,_ScatterIntensity,_PreScatterMaskUseMainTexA);
        col.xyz += presss;
    #endif

    #if defined(_RIMON)
        half rim = 1 - nv;
        rim = rim * rim;
        rim = smoothstep(_RimStepMin,_RimStepMax,rim);
        half3 rimColor =  rim * originalNL * _RimColor * lerp(1,mainLightColor,_RimReceiveMainLightColor);
        col.xyz += rimColor;
    #endif

    // 水墨
    col.xyz *= _InkPaintOn ? lerp(_InkPaintColor.xyz,1,smoothstep(_InkPaintMin,_InkPaintMax,nh*nh)) : 1;

    #if defined(_EMISSION)
        half4 emissionColor = tex2D(_EmissionMap,i.uv);
        emissionColor.xyz *= _EmissionColor;

        half4 emissionMaskData = half4(1,mainTex.w,emissionColor.w,0);
        half emissionMask = GetMask(emissionMaskData,_EmissionMaskFrom);

        half3 blendEmission = lerp(col.xyz,emissionColor,emissionMask);
        half3 addEmission = col.xyz + emissionColor.xyz * emissionMask;
        col.xyz = lerp(blendEmission,addEmission,_EmissionMode);
    #endif

    return col;
}

#endif //FORWARD_PASS_HLSL
