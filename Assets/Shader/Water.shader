// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "SouptikDatta/Water"
{
    Properties
    {
        [Header(Colors)]
        _ColorLight ("Color Light", Color) = (1,1,1,1)
        _ColorDeep ("Color Deep", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,10)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [Header(Textures)]
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _FoamTexture("Foam Texture", 2D) = "white" {}
        [Header(Foam Line)]
        _FoamTextureSpeedX("Foam texture speed X", float) = 0
        _FoamTextureSpeedY("Foam texture speed Y", float) = 0
        _FoamLinesSpeed("Foam lines speed", float) = 0
        _FoamIntensity("Foam intensity", float) = 1
        _FoamCornerDiffusion("Foam Corner Diffusion", Range(1, 10)) = 1
        [Header(Normal Mapping)]
        _NormalMapOne("Normal Map One", 2D) = "bump" {}
        _NormalMapTwo("Normal Map Two", 2D) = "bump" {}
        _NormalUVScale("Normal UV Scale", Range(1, 50)) = 1
        _NormalIntensity("Normal Map Intensity", Range(0, 10)) = 1
        _NormalDistortionIntensity("Normal Map Distortion Intensity", Range(0, 1)) = 0.2
        _NormalBrightness("Normal Brightness", Range(0, 10)) = 1
        _ScrollXSpeed("X", Range(0,10)) = 2
        _ScrollYSpeed("Y", Range(0,10)) = 3
        [Header(Cube Maps)]
        _CubeMap("Cube Map", CUBE) = "white"{}
        [Header(Fresnel)]
        _FresnelPower("Fresnel Power", Range(0.05, 20.0)) = 1
        _FresnelPowerOpacity("Fresnel Power Opacity", Range(0.05, 20.0)) = 1
        _FresnelBrightness("Fresnel Brightness", Range(0, 10)) = 1
        [Header(Thresholds)]
        _IntersectionThreshold("Intersction threshold", float) = 0
        _IntersectionSmoothness("Intersction Smoothness", float) = 1
        _IntersectionThresholdBackGround("Intersction threshold BackGround", float) = 0
        _IntersectionSmoothnessBackGround("Intersction Smoothness BackGround", float) = 1
        _FogThreshold("Fog threshold", float) = 0
        _FoamThreshold("Foam threshold", float) = 0
        _FoamSmoothness("Foam Smoothness", float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 200

        GrabPass{}

        // Blend One One
        Cull off
        CGPROGRAM
        #pragma surface surf SimpleSpecular fullforwardshadows alpha:premul
        // fullforwardshadows
        #pragma target 3.0

        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        half _Glossiness;

        half4 LightingSimpleSpecular(inout SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
            half3 h = normalize(lightDir + viewDir);

            half diff = dot(s.Normal, lightDir); // Value decrease if the light is at a greater angle

            half nh = dot(s.Normal, h);

            nh = saturate(nh);
            diff = saturate(diff);
            float spec;
            float distToWaterFromCam = length(viewDir);
            spec = pow(nh, (1-exp(-50000 * distToWaterFromCam)) * 500);

            half4 c;
            // c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;

            //float specularAngle = acos(dot(normalize(lightDir - viewDir), s.Normal));
            //float specularExponent = specularAngle / _Glossiness;
            //float specularHighlight = exp(-specularExponent * specularExponent);
            // c.rgb = (s.Albedo * _LightColor0.rgb * pow(diff, 40) * 80 + _LightColor0.rgb * pow(diff, 200) * 1000 + _LightColor0.rgb * spec * 1) * atten;
            c.rgb = (s.Albedo * _LightColor0.rgb * pow(diff, 85) * 40 + _LightColor0.rgb * spec * 1) * atten;
            c.a = s.Alpha;

            return c;
        }
        
        sampler2D _MainTex;
        sampler2D _CameraDepthTexture;
        float4 _CameraDepthTexture_TexelSize;

        struct Input
        {
            float4 screenPos;
            float3 worldPos;
            float2 uv_MainTex;
            float2 uv_NormalMapOne;
            float3 worldRefl;
            float3 viewDir; INTERNAL_DATA
        };


        half _Metallic;
        fixed4 _ColorLight;
        fixed4 _ColorDeep;
        sampler2D _NormalMapOne;
        sampler2D _NormalMapTwo;
        half _NormalUVScale;
        half _NormalIntensity;
        half _NormalDistortionIntensity;
        half _NormalBrightness;
        samplerCUBE _CubeMap;
        half _FresnelPower;
        half _FresnelPowerOpacity;
        half _FresnelBrightness;
        fixed _ScrollXSpeed;
        fixed _ScrollYSpeed;
        float _IntersectionThreshold;
        float _IntersectionSmoothness;
        float _FogThreshold;
        float _FoamThreshold;
        sampler2D _FoamTexture;
        float4 _FoamTexture_ST;
        float _FoamTextureSpeedX;
        float _FoamTextureSpeedY;
        float _FoamLinesSpeed;
        float _FoamIntensity;
        float _FoamSmoothness;
        half _FoamCornerDiffusion;

        // Grab Texture
        sampler2D _GrabTexture;
        float4 _GrabTexture_TexelSize;
        // Grab Texture


        void surf (Input IN, inout SurfaceOutput o)
        {
            // Deep Color and Light Color

            fixed4 cdeep =  _ColorDeep;
            fixed4 clight =  _ColorLight;
            fixed4 rimColor = fixed4(1, 1, 1, 1);
            // o.Albedo = texCUBE(_CubeMap, IN.worldRefl).rgb;
            
            // Deep Color and Light Color


            // Scrolling the UV for the normal scrolling and assigning the normal mapping

            fixed xScrollValue = _ScrollXSpeed * _Time;
            fixed yScrollValue = _ScrollYSpeed * _Time;
            float2 calculatedUV = ((IN.uv_NormalMapOne + fixed2(xScrollValue, yScrollValue)) * _NormalUVScale)%2;
            calculatedUV = float2(calculatedUV.x<=1 ? calculatedUV.x : 2-calculatedUV.x, calculatedUV.y <= 1 ? calculatedUV.y : 2 - calculatedUV.y);
            float3 currentNormal = o.Normal;
            o.Normal = UnpackNormalWithScale(tex2D(_NormalMapOne, calculatedUV + fixed2(xScrollValue, yScrollValue)), _NormalIntensity) * _NormalBrightness;
            o.Normal *= UnpackNormalWithScale(tex2D(_NormalMapTwo, float2(calculatedUV.y, calculatedUV.x) + fixed2(yScrollValue, xScrollValue)), _NormalIntensity) * _NormalBrightness;
            o.Normal *= float3(_NormalIntensity, _NormalIntensity, 1);

            // Scrolling the UV for the normal scrolling and assigning the normal mapping

            // Fresnel Effect

            float dotProduct = dot(normalize(IN.viewDir), o.Normal);
            half rim = 1 - min(0.2, saturate(dotProduct < 0 ? -dotProduct : dotProduct));
            half opacityRim = 1 - min(0.2, saturate(dotProduct < 0 ? -dotProduct : dotProduct));

            // Fresnel Effect

            // Using the camera's depth texture to get the distToBottomLand from the camera
            
            float distToBottomLand = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
            // float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, IN.screenPos);
            distToBottomLand = LinearEyeDepth(distToBottomLand);

            // Using the camera's depth texture to get the distToBottomLand from the camera

            // Getting the depth texture from the water surface by substracting the  water's screenPos.w from the distToBottomLand

            float fogDiff = saturate((distToBottomLand - IN.screenPos.w) / _FogThreshold);
            fogDiff = pow(fogDiff, 0.5);
            float intersectionDiff = saturate((distToBottomLand - IN.screenPos.w) / _IntersectionThreshold);
            float distToBottomLandAveraged = distToBottomLand;
            float samplingOffset = 0.001f;
            for (int i = 0; i < _FoamCornerDiffusion; i++) {
                float temp = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + float4(samplingOffset*(i+1), 0, 0, 0 ) ));
                temp = LinearEyeDepth(temp);
                distToBottomLandAveraged += temp;
                temp = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos - float4(samplingOffset * (i + 1), 0, 0, 0)));
                temp = LinearEyeDepth(temp);
                distToBottomLandAveraged += temp;
                temp = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + float4(0, samplingOffset * (i + 1), 0, 0)));
                temp = LinearEyeDepth(temp);
                distToBottomLandAveraged += temp;
                temp = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos - float4(0, samplingOffset * (i + 1), 0, 0)));
                temp = LinearEyeDepth(temp);
                distToBottomLandAveraged += temp;
            }
            distToBottomLandAveraged /= (_FoamCornerDiffusion * 5);
            float foamDiff = saturate((distToBottomLand - IN.screenPos.w) / _FoamThreshold);
            foamDiff = pow(foamDiff, _FoamSmoothness);
            // foamDiff *= (1.0 - rt.b);

            // Getting the depth texture from the water surface by substracting the  water's screenPos.w from the distToBottomLand
             
            
            // Getting the screen space UV for the grabTexture
            
            float2 refractionUVOffset = o.Normal.xy * _NormalDistortionIntensity;
            // refractionUVOffset.y *= (_GrabTexture_TexelSize.z * abs(_GrabTexture_TexelSize.y));
            float2 screenPosUV = (IN.screenPos.xy+ refractionUVOffset) / IN.screenPos.w;
            float distToBottomLandDistorted = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + float4(refractionUVOffset, 0, 0)));
            // float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, IN.screenPos);
            distToBottomLandDistorted = LinearEyeDepth(distToBottomLandDistorted);
            float intersectionDiffDistorted = (distToBottomLandDistorted - IN.screenPos.w);
            if (intersectionDiffDistorted < 0) {
                screenPosUV = IN.screenPos.xy / IN.screenPos.w;
                #if UNITY_UV_STARTS_AT_TOP
                    if (_CameraDepthTexture_TexelSize.y < 0) {
                        screenPosUV.y = 1 - screenPosUV.y;
                    }
                #endif
                distToBottomLandDistorted = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
                distToBottomLandDistorted = LinearEyeDepth(distToBottomLandDistorted);
                intersectionDiffDistorted = distToBottomLandDistorted - IN.screenPos.w;
            }
            float3 sampledGrabTex = tex2D(_GrabTexture, screenPosUV);
            intersectionDiffDistorted = saturate(intersectionDiffDistorted / _IntersectionThreshold);
            float grabTexFogFactor = (1 - pow(intersectionDiffDistorted, _IntersectionSmoothness));
            

            // Getting the screen space UV for the grabTexture


            // Computing the Albedos one after another

            float3 fresnelAlbedo = (lerp(cdeep, clight, pow(rim, _FresnelPower)) * _FresnelBrightness).rgb ;
            // * exp(intersectionDiff * _IntersectionSmoothness)
            float3 prevPlusDepthAlbedo = lerp(clight, fresnelAlbedo, pow(intersectionDiffDistorted, _IntersectionSmoothness)); // Later to be interpolated at different rates for r g and b
            // float3 prevPlusGrabAlbedo = lerp(prevPlusDepthAlbedo, sampledGrabTex, grabTexFogFactor);
            float3 prevPlusGrabAlbedo = lerp(0, sampledGrabTex, grabTexFogFactor);

            // Computing the Albedos one after another

            
            // Applying the albedo (we only apply the depth colored albedo here because the uderwater should not be affected by the sunlight and albedo is infact affected by sunlight... so we apply the grabtexture in the emission channel)
            
            o.Albedo.rgb = prevPlusDepthAlbedo;
            // o.Albedo.rgb = pow(intersectionDiff, _IntersectionSmoothness); // Uncomment this for seeing the depth texture mask
            // o.Metallic = _Metallic;
            // o.Smoothness = _Glossiness;
            o.Alpha = pow(intersectionDiffDistorted, _IntersectionSmoothness) * pow(rim, _FresnelPowerOpacity);
            o.Alpha = 1;

            // Applying the albedo
            

            // Computing the foam
            
            float foamTex = tex2D(_FoamTexture, IN.worldPos.xz * _FoamTexture_ST.xy + _Time.y * float2(_FoamTextureSpeedX, _FoamTextureSpeedY));
            float foam = step(foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 8 * UNITY_PI)) * (1.0 - foamDiff)), foamTex);
            float intensityAtThisPoint = foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 8 * UNITY_PI)) * (1.0 - foamDiff));
            // o.Albedo.rgb = foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 8 * UNITY_PI)) * (1.0 - foamDiff));

            // Computing the foam 
            
            // o.Albedo.rgb = intensityAtThisPoint;
            
            // Applying the foam here (and also the GrabTexture for underwater seen)

            o.Emission = (prevPlusGrabAlbedo) + foam * _FoamIntensity * (1-fogDiff);

            // Applying the foam here (and also the GrabTexture for underwater seen)
        }
        ENDCG


        //Pass{
        //    Blend One Zero
        //    ZWrite Off
        //    Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        //    CGPROGRAM
        //    #pragma alpha:premul
        //    #pragma vertex vert
        //    #pragma fragment frag
        //    #include "UnityCG.cginc"
        //    struct appdata {
        //        float4 vertex : POSITION;
        //        float2 uv : TEXCOORD0;
        //        float3 normal : NORMAL;
        //    };
        //    struct v2f {
        //        half3 worldNormal : TEXCOORD0;
        //        float4 uvgrab : TEXCOORD1;
        //        float2 uvbump : TEXCOORD2;
        //        half3 worldRefl : TEXCOORD3;
        //        float4 screenPos : TEXCOORD4;
        //        float4 vertex : SV_POSITION;
        //    };
        //    sampler2D _GrabTexture;
        //    float4 _GrabTexture_TexelSize;
        //    sampler2D _MainTex;
        //    float4 _MainTex_ST;
        //    sampler2D _NormalMapOne;
        //    sampler2D _NormalMapTwo;
        //    float4 _NormalMapOne_ST;
        //    float4 _NormalMapTwo_ST;
        //    half _NormalUVScale;
        //    half _NormalDistortionIntensity;
        //    half _NormalBrightness;
        //    fixed _ScrollXSpeed;
        //    fixed _ScrollYSpeed;
        //    sampler2D _CameraDepthTexture;
        //    float _IntersectionThresholdBackGround;
        //    float _IntersectionSmoothnessBackGround;

        //    v2f vert(appdata v) {
        //        v2f o;
        //        o.vertex = UnityObjectToClipPos(v.vertex);
        //        o.screenPos = ComputeScreenPos(o.vertex);
        //        // Taking only the part of uvgrab which is visible through the object
        //        o.uvgrab.xy = (float2(o.vertex.x, -o.vertex.y) + o.vertex.w) * 0.5;
        //        o.uvgrab.zw = o.vertex.zw;
        //        // Taking only the part of uvgrab which is visible through the object
        //        fixed xScrollValue = _ScrollXSpeed * _Time;
        //        fixed yScrollValue = _ScrollYSpeed * _Time;
        //        float2 calculatedUV = ((v.uv + fixed2(xScrollValue, yScrollValue)) * _NormalUVScale) % 2;
        //        calculatedUV = float2(calculatedUV.x <= 1 ? calculatedUV.x : 2 - calculatedUV.x, calculatedUV.y <= 1 ? calculatedUV.y : 2 - calculatedUV.y);
        //        o.uvbump = TRANSFORM_TEX(calculatedUV, _NormalMapOne);
        //        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        //        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        //        float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
        //        o.worldRefl = reflect(-worldViewDir, o.worldNormal);
        //        return o;
        //    }
        //    fixed4 frag(v2f i) : SV_Target{
        //        // Create distortion in the grabtexture (by creating distortion in the uvgrab uv) according to the normal map
        //        // half2 bump = UnpackNormal(tex2D(_NormalMapOne, i.uvbump)).rg;
        //        // bump += UnpackNormal(tex2D(_NormalMapTwo, i.uvbump)).rg;
        //        half2 bump = i.worldNormal.rg;
        //        bump += UnpackNormal(tex2D(_NormalMapOne, i.uvbump)).rg;
        //        bump += UnpackNormal(tex2D(_NormalMapTwo, i.uvbump)).rg;
        //        float2 offset = bump * _NormalDistortionIntensity * _GrabTexture_TexelSize.xy;
        //        i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
        //        // Create distortion in the grabtexture (by creating distortion in the uvgrab uv) according to the normal map
        //        fixed4 distortedGrabTexture = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
        //        half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
        //        half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
        //        // color.rgb *= skyColor;
        //        // color = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.uvgrab));
        //        float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
        //        depth = LinearEyeDepth(depth);
        //        float intersectionDiff = saturate((depth - i.screenPos.w) / _IntersectionThresholdBackGround);
        //        fixed4 color = lerp(float4(0, 0, 0, 1), distortedGrabTexture, pow(1- intersectionDiff, _IntersectionSmoothnessBackGround));
        //        // color = lerp(float4(0, 0, 0, 1), distortedGrabTexture, 0.5);
        //        // color.a = pow(1 - intersectionDiff, _IntersectionSmoothnessBackGround);
        //        color.a = 1;
        //        return color;
        //    }
        //    ENDCG
        //}
    }
    // FallBack "Diffuse"
    FallBack Off
}
