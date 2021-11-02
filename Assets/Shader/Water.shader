// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "SouptikDatta/Water"
{
    Properties
    {
        [Header(Ripples)]
        _Wave0("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _Wave1("Wave B", Vector) = (0,1,0.25,20)
        _Wave2("Wave C", Vector) = (1,1,0.15,10)
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
        _NormalMapBlendingNoise("Normal Map Blending Noise", 2D) = "bump" {}
        _NormalMapOneTwoOffsetX("_NormalMap OneTwo OffsetX", float) = 0
        _NormalMapOneTwoOffsetY("_NormalMap OneTwo OffsetY", float) = 0
        _NormalUVScaleOne("Normal UV Scale One", Range(1, 50)) = 1
        _NormalUVScaleTwo("Normal UV Scale Two", Range(1, 50)) = 1
        _NormalIntensity("Normal Map Intensity", Range(0, 10)) = 1
        _BlendStrength("Blend Strength", Range(0, 50)) = 1
        _NormalDistortionIntensity("Normal Map Distortion Intensity", Range(0, 0.1)) = 0.02
        _NormalBrightness("Normal Brightness", Range(0, 10)) = 1
        _ScrollXSpeed("Normal X Scrolling Speed", Range(0,10)) = 2
        _ScrollYSpeed("Normal Y Scrolling Speed", Range(0,10)) = 3
        [Header(Cube Maps)]
        _CubeMap("Cube Map", CUBE) = "white"{}
        [Header(Fresnel)]
        _FresnelPower("Fresnel Power", Range(0.05, 50.0)) = 1
        _FresnelPowerOpacity("Fresnel Power Opacity", Range(0.05, 20.0)) = 1
        _FresnelBrightness("Fresnel Brightness", Range(0, 10)) = 1
        [Header(Thresholds)]
        _IntersectionThreshold("Intersction threshold", float) = 0
        _IntersectionThresholdUnderWater("Intersction threshold underwater", float) = 0
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
        LOD 200

        GrabPass{}

        // Blend One One
        Cull off
        CGPROGRAM
        #pragma surface surf SimpleSpecular vertex:disp addshadow
        // fullforwardshadows
        #pragma target 3.0

        #include "UnityCG.cginc"


        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)



        half _Metallic;
        fixed4 _ColorLight;
        fixed4 _ColorDeep;
        sampler2D _NormalMapOne;
        sampler2D _NormalMapTwo;
        sampler2D _NormalMapBlendingNoise;
        float _NormalMapOneTwoOffsetX;
        float _NormalMapOneTwoOffsetY;
        half _NormalUVScaleOne;
        half _NormalUVScaleTwo;
        half _NormalIntensity;
        half _BlendStrength;
        half _NormalDistortionIntensity;
        half _NormalBrightness;
        samplerCUBE _CubeMap;
        half _FresnelPower;
        half _FresnelPowerOpacity;
        half _FresnelBrightness;
        fixed _ScrollXSpeed;
        fixed _ScrollYSpeed;
        float _IntersectionThreshold;
        float _IntersectionThresholdUnderWater;
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

        half _Glossiness;

        struct SurfaceOutputCustom
        {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            float3 Specular;
            fixed Gloss;
            fixed Alpha;
            fixed3 posWorld;
        };

        // Study triplanar Mapping
        float3 TriplanarNormal(float3 worldPosition, float3 surfaceNormal) {
            float3 normalDistribution = tex2D(_NormalMapBlendingNoise, worldPosition.xz * 0.1); // For now xz is enough as we are having a straight surface here
            normalDistribution += tex2D(_NormalMapBlendingNoise, worldPosition.zx * 0.1); // For now xz is enough as we are having a straight surface here
            fixed xScrollValue = _ScrollXSpeed * _Time;
            fixed yScrollValue = _ScrollYSpeed * _Time;
            float3 colX = UnpackNormal(tex2D(_NormalMapOne, (worldPosition.zy + float2(xScrollValue, yScrollValue)) * _NormalUVScaleOne));
            // colX = float3(colX.xy + colX.zy, colX.z * surfaceNormal.x);
            float3 colX2 = UnpackNormal(tex2D(_NormalMapTwo, (worldPosition.zy + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * _NormalUVScaleTwo));
            // colX2 = float3(colX2.xy + colX2.zy, colX2.z * surfaceNormal.x);
            float3 colY = UnpackNormal(tex2D(_NormalMapOne, (worldPosition.xz + float2(xScrollValue, yScrollValue)) * _NormalUVScaleOne));
            // colY = float3(colY.xy + colY.zy, colY.z * surfaceNormal.y);
            float3 colY2 = UnpackNormal(tex2D(_NormalMapTwo, (worldPosition.xz + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * _NormalUVScaleTwo));
            // colY2 = float3(colY2.xy + colY2.zy, colY2.z * surfaceNormal.y);
            float3 colZ = UnpackNormal(tex2D(_NormalMapOne, (worldPosition.xy + float2(xScrollValue, yScrollValue)) * _NormalUVScaleOne));
            // colZ = float3(colZ.xy + colZ.zy, colZ.z * surfaceNormal.z);
            float3 colZ2 = UnpackNormal(tex2D(_NormalMapTwo, (worldPosition.xy + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * _NormalUVScaleTwo));
            // colZ2 = float3(colZ2.xy + colZ2.zy, colZ2.z * surfaceNormal.z);
            float3 blendWeight = pow(abs(normalize(surfaceNormal)), _BlendStrength);
            blendWeight /= dot(blendWeight, 1);
            float3 finalNormal = (colX.zyx + colX2.zyx) * blendWeight.x + (colY.xzy + colY2.xzy) * blendWeight.y + (colZ.xyz + colZ2.xyz) * blendWeight.z;
            finalNormal = (colX.zyx * normalDistribution.r + colX2.zyx * normalDistribution.g) * blendWeight.x + (colY.xzy * normalDistribution.r + colY2.xzy * normalDistribution.g) * blendWeight.y + (colZ.xyz * normalDistribution.r + colZ2.xyz * normalDistribution.g) * blendWeight.z;
            return normalize(finalNormal);
        }





        half4 LightingSimpleSpecular(inout SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten) {
            //half3 h = normalize(lightDir + viewDir);

            //half diff = dot(normalize(s.Normal + TriplanarNormal(s.posWorld, s.Normal)), lightDir); // Value decrease if the light is at a greater angle

            //half nh = dot(normalize(s.Normal + TriplanarNormal(s.posWorld, s.Normal)), h);

            //nh = saturate(nh);
            //float specAngle = acos(nh);
            //float specExponent = specAngle / _Glossiness;
            //diff = saturate(diff);
            //float spec;
            //float distToWaterFromCam = length(viewDir);
            //spec = exp(- specExponent * specExponent);

            //half4 c;
            //// c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
            //// c.rgb = (s.Albedo * _LightColor0.rgb * pow(diff, 40) * 80 + _LightColor0.rgb * pow(diff, 200) * 1000 + _LightColor0.rgb * spec * 1) * atten;
            //// c.rgb = (s.Albedo * _LightColor0.rgb * diff * 2 + _LightColor0.rgb * spec + s.Specular*specAngle) * atten;
            //c.rgb = (s.Albedo * _LightColor0.rgb * diff * 2 + _LightColor0.rgb * spec) * atten;
            //// c.rgb = s.Specular*specAngle;
            //// c.rgb = s.Albedo;
            //c.a = s.Alpha;

            //return c;


            half3 h = normalize(lightDir + viewDir);

            half diff = dot(normalize(s.Normal + TriplanarNormal(s.posWorld, s.Normal)), lightDir); // Value decrease if the light is at a greater angle

            half nh = dot(normalize(s.Normal + TriplanarNormal(s.posWorld, s.Normal)), h);

            nh = saturate(nh);
            float specAngle = acos(nh);
            float specExponent = specAngle / _Glossiness;
            diff = saturate(diff);
            float spec;
            float distToWaterFromCam = length(viewDir);
            spec = exp(-specExponent * specExponent);

            half4 c;
            // c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
            // c.rgb = (s.Albedo * _LightColor0.rgb * pow(diff, 40) * 80 + _LightColor0.rgb * pow(diff, 200) * 1000 + _LightColor0.rgb * spec * 1) * atten;
            c.rgb = (s.Albedo * _LightColor0.rgb * diff * 2 + _LightColor0.rgb * spec) * atten;
            // c.rgb = s.Albedo;
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



        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };


        struct Octave
        {
            float2 speed;
            float2 scale;
            float height;
            int alternate;
            int enabled;
        };


        float4 _Wave0;
        float4 _Wave1;
        float4 _Wave2;

        float3 GerstnerWave(
            float4 wave, float3 worldPos, inout float3 tangent, inout float3 binormal
        ) {
            float steepness = wave.z;
            float wavelength = wave.w;
            float k = 2 * UNITY_PI / wavelength;
            float c = sqrt(9.8 / k);
            float2 d = normalize(wave.xy);
            float f = k * (dot(d, worldPos.xz) - c * _Time.y);
            float a = steepness / k;

            //p.x += d.x * (a * cos(f));
            //p.y = a * sin(f);
            //p.z += d.y * (a * cos(f));

            tangent += float3(
                -d.x * d.x * (steepness * sin(f)),
                d.x * (steepness * cos(f)),
                -d.x * d.y * (steepness * sin(f))
                );
            binormal += float3(
                -d.x * d.y * (steepness * sin(f)),
                d.y * (steepness * cos(f)),
                -d.y * d.y * (steepness * sin(f))
                );
            return float3(
                d.x * (a * cos(f)),
                a * sin(f),
                d.y * (a * cos(f))
                );
        }


        void disp(inout appdata v)
        {
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 gridPoint = worldPos.xyz;
            float3 tangent = float3(1, 0, 0);
            float3 binormal = float3(0, 0, 1);
            float3 p = v.vertex.xyz;
            p += GerstnerWave(_Wave0, gridPoint, tangent, binormal);
            p += GerstnerWave(_Wave1, gridPoint, tangent, binormal);
            p += GerstnerWave(_Wave2, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal, tangent));
            v.vertex.xyz = p;
            v.normal = normal;
        }


        void surf (Input IN, inout SurfaceOutputCustom o)
        {
            // Deep Color and Light Color

            fixed4 cdeep =  _ColorDeep;
            fixed4 clight =  _ColorLight;
            fixed4 rimColor = fixed4(1, 1, 1, 1);
            // o.Albedo = texCUBE(_CubeMap, IN.worldRefl).rgb;
            
            // Deep Color and Light Color


            // Scrolling the UV for the normal scrolling and assigning the normal mapping


            //float2 calculatedUV = ((IN.uv_NormalMapOne + fixed2(xScrollValue, yScrollValue)) * _NormalUVScale)%2;
            //calculatedUV = float2(calculatedUV.x<=1 ? calculatedUV.x : 2-calculatedUV.x, calculatedUV.y <= 1 ? calculatedUV.y : 2 - calculatedUV.y);
            float3 currentNormal = o.Normal;
            // o.Normal = UnpackNormalWithScale(tex2D(_NormalMapOne, calculatedUV + fixed2(xScrollValue, yScrollValue)), _NormalIntensity) * _NormalBrightness;




            // o.Normal = TriplanarNormal(IN.worldPos, o.Normal);
            // o.Normal *= UnpackNormalWithScale(tex2D(_NormalMapTwo, float2(calculatedUV.y, calculatedUV.x) + fixed2(yScrollValue, xScrollValue)), _NormalIntensity) * _NormalBrightness;
            // o.Normal *= float3(_NormalIntensity, _NormalIntensity, 1);

            // Scrolling the UV for the normal scrolling and assigning the normal mapping

            // Fresnel Effect

            float dotProduct = dot(normalize(IN.viewDir), o.Normal+ TriplanarNormal(IN.worldPos, o.Normal));
            half rim = 1 - min(0.2, saturate(dotProduct < 0 ? -dotProduct : dotProduct));
            half opacityRim = 1 - min(0.2, saturate(dotProduct < 0 ? -dotProduct : dotProduct));

            // Fresnel Effect

            // Using the camera's depth texture to get the distToBottomLand from the camera
            
            float distToBottomLand = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
            // float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, IN.screenPos);
            distToBottomLand = LinearEyeDepth(distToBottomLand) * length(IN.viewDir);

            // Using the camera's depth texture to get the distToBottomLand from the camera

            // Getting the depth texture from the water surface by substracting the  water's screenPos.w from the distToBottomLand

            float fogDiff = saturate((distToBottomLand - IN.screenPos.w) / _FogThreshold);
            fogDiff = pow(fogDiff, 0.5);
            float intersectionDiff = saturate((distToBottomLand - IN.screenPos.w) / _IntersectionThreshold);
            float foamDiff = saturate((distToBottomLand - IN.screenPos.w) / _FoamThreshold);
            foamDiff = pow(foamDiff, _FoamSmoothness);
            // foamDiff *= (1.0 - rt.b);

            // Getting the depth texture from the water surface by substracting the  water's screenPos.w from the distToBottomLand
             
            
            // Getting the screen space UV for the grabTexture
            
            float2 postRefractionUVOffset = normalize(IN.viewDir + normalize(normalize(o.Normal) + TriplanarNormal(IN.worldPos, o.Normal))).xy;
            float2 refractionUVOffset = postRefractionUVOffset * _NormalDistortionIntensity;
            refractionUVOffset.y *= (_GrabTexture_TexelSize.z * abs(_GrabTexture_TexelSize.y));
            float2 screenPosUV = (IN.screenPos.xy + refractionUVOffset) / IN.screenPos.w;
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
            if (dot(o.Normal, IN.viewDir) < 0) {
                intersectionDiffDistorted = saturate(intersectionDiffDistorted / (_IntersectionThresholdUnderWater / pow(IN.screenPos.w, 0.2)));
            }else{
                intersectionDiffDistorted = saturate(intersectionDiffDistorted / _IntersectionThreshold);
            }
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
            
            o.posWorld = IN.worldPos;
            o.Albedo.rgb = prevPlusDepthAlbedo;
            // o.Albedo.rgb = pow(intersectionDiff, _IntersectionSmoothness); // Uncomment this for seeing the depth texture mask
            // o.Metallic = _Metallic;
            // o.Smoothness = _Glossiness;
            // o.Alpha = pow(intersectionDiffDistorted, _IntersectionSmoothness) * pow(rim, _FresnelPowerOpacity);
            o.Alpha = 1;

            // Applying the albedo


            // Calculating The world reflection
            
            float3 reflectionDir = reflect(-IN.viewDir, o.Normal);
            float4 envSample = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectionDir);
            // o.Specular = DecodeHDR(envSample, unity_SpecCube0_HDR);
             
            // Calculating the world reflection


            // Computing the foam
            
            float foamTex = tex2D(_FoamTexture, IN.worldPos.xz * _FoamTexture_ST.xy + _Time.y * float2(_FoamTextureSpeedX, _FoamTextureSpeedY));
            float foam = step(foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 10 * UNITY_PI)) * (1.0 - foamDiff)), foamTex);
            float intensityAtThisPoint = foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 10 * UNITY_PI)) * (1.0 - foamDiff));
            // o.Albedo.rgb = foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 8 * UNITY_PI)) * (1.0 - foamDiff));

            // Computing the foam 
            
            
            // Applying the foam here (and also the GrabTexture for underwater seen)

             // o.Albedo = 1;
            // o.Albedo = TriplanarNormal(IN.worldPos, o.Normal);

            o.Emission = (prevPlusGrabAlbedo) + foam * foamTex * _FoamIntensity;


            // Applying the foam here (and also the GrabTexture for underwater seen)
        }
        ENDCG


        //Pass{
        //    Blend One Zero
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
    FallBack "Diffuse"
    // FallBack Off
}
