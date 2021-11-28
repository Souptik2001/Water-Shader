// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SouptikDatta/Water"
{
    Properties
    {
        [Header(SuctionArea)]
        _SuckerCenter("Sucker Center", Vector) = (0, 0, 0, 0)
        _SuckerRadius("Sucker Radius", float) = 0
        _SuckerColor("Sucker Color", Color) = (0, 1, 0, 1)
        [Header(Ripples)]
        _Wave0("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _Wave1("Wave B", Vector) = (0,1,0.25,20)
        _Wave2("Wave C", Vector) = (1,1,0.15,10)
        [Header(Colors)]
        _ColorLight("Color Light", Color) = (1,1,1,1)
        _ColorDeep("Color Deep", Color) = (1,1,1,1)
        _Glossiness("Smoothness", Range(0,10)) = 0.08
        [Header(Textures)]
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _FoamTexture("Foam Texture", 2D) = "white" {}
        _WaterWakeFoamTexOne("WaterWakeFoamTexOne", 2D) = "white" {}
        _WaterWakeFoamTexTwo("WaterWakeFoamTexTwo", 2D) = "white" {}
        _WaterWakeFoamNormalOne("WaterWakeFoamNormalOne", 2D) = "bump" {}
        _WaterWakeFoamNormalTwo("WaterWakeFoamNormalTwo", 2D) = "bump" {}
        [Header(Foam Line)]
        _FoamTextureSpeedX("Foam texture speed X", float) = 0.01
        _FoamTextureSpeedY("Foam texture speed Y", float) = 0.17
        _FoamLinesSpeed("Foam lines speed", float) = 0.05
        _FoamIntensity("Foam intensity", float) = 5
        _FoamThreshold("Foam threshold", float) = 0.43
        _FoamSmoothness("Foam Smoothness", float) = 0.13
        _FoamCornerDiffusion("Foam Corner Diffusion", Range(1, 10)) = 0.85
        [Header(Normal Mapping)]
        _NormalMapOne("Normal Map One", 2D) = "bump" {}
        _NormalMapTwo("Normal Map Two", 2D) = "bump" {}
        _NormalMapBlendingNoise("Normal Map Blending Noise", 2D) = "bump" {}
        _NormalMapOneTwoOffsetX("_NormalMap OneTwo OffsetX", float) = 0.06
        _NormalMapOneTwoOffsetY("_NormalMap OneTwo OffsetY", float) = 0
        _NormalUVScaleOne("Normal UV Scale One", Range(1, 50)) = 1.5
        _NormalUVScaleTwo("Normal UV Scale Two", Range(1, 50)) = 2
        _NormalIntensity("Normal Map Intensity", Range(0, 10)) = 0
        _BlendStrength("Blend Strength", Range(0, 50)) = 9.4
        _NormalDistortionIntensity("Normal Map Distortion Intensity", Range(0, 0.1)) = 0.03
        _NormalBrightness("Normal Brightness", Range(0, 10)) = 0.7
        _ScrollXSpeed("Normal X Scrolling Speed", Range(0,10)) = 2.84
        _ScrollYSpeed("Normal Y Scrolling Speed", Range(0,10)) = 1.33
        [Header(Cube Maps)]
        _CubeMap("Cube Map", CUBE) = "white"{}
        [Header(Fresnel)]
        _FresnelPower("Fresnel Power", Range(0.05, 50.0)) = 20
        _FresnelPowerOpacity("Fresnel Power Opacity", Range(0.05, 20.0)) = 0.05
        _FresnelBrightness("Fresnel Brightness", Range(0, 10)) = 1
        [Header(Thresholds)]
        _IntersectionThreshold("Intersction threshold", float) = 4
        _IntersectionThresholdUnderWater("Intersction threshold underwater", float) = 12.5
        _IntersectionSmoothness("Intersction Smoothness", float) = 0.41
        _IntersectionThresholdBackGround("Intersction threshold BackGround", float) = 7
        _IntersectionSmoothnessBackGround("Intersction Smoothness BackGround", float) = 2.26
        _FogThreshold("Fog threshold", float) = 0.8
        _WaterSplashThreshold("WaterSplashThreshold", Range(0, 1)) = 0.85
    }


        CGINCLUDE

#include "UnityCG.cginc"
#include "AutoLight.cginc"


            float InverseLerp(float a, float b, float v) {
            return ((v - a) / (b - a));
        }


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

            //tangent += float3(
            //    -d.x * d.x * (steepness * sin(f)),
            //    d.x * (steepness * cos(f)),
            //    -d.x * d.y * (steepness * sin(f))
            //    );
            //binormal += float3(
            //    -d.x * d.y * (steepness * sin(f)),
            //    d.y * (steepness * cos(f)),
            //    -d.y * d.y * (steepness * sin(f))
            //    );
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

        ENDCG

            SubShader
        {

                    Tags { "RenderType" = "Transparent" "Queue" = "Transparent+1"  }


               GrabPass{ "_GrabTexture" }


            Tags { "RenderType" = "Opaque" "Queue" = "Geometry"  }


            Tags {"LightMode" = "ForwardAdd" }
            LOD 300
            // Blend Alpha OneMinusSrcAlpha
            Cull off
            CGPROGRAM
            #pragma surface surf SimpleSpecular vertex:disp addshadow fullforwardshadows
            // fullforwardshadows
            #pragma target 3.0


            UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)



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
            float _IntersectionSmoothnessBackGround;
            float _FogThreshold;
            float _FoamThreshold;
            sampler2D _FoamTexture;
            sampler2D _WaterWakeFoamTexOne;
            sampler2D _WaterWakeFoamTexTwo;
            sampler2D _WaterWakeFoamNormalOne;
            sampler2D _WaterWakeFoamNormalTwo;
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
                float4 screenPos;
            };

            // Ripple
            uniform sampler2D _RippleMask;
            uniform float3 _RippleOrthographicCamPosition;
            uniform float _RippleOrthographicCamSize;
            // Ripple

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_TexelSize;

            sampler2D _CustomCameraDepthTexture;
            sampler2D _WaterRippleMaskTexture;
            float4 _CustomCameraDepthTexture_TexelSize;



            // Study triplanar Mapping
            float3 TriplanarNormal(float3 worldPosition, float3 surfaceNormal, sampler2D texOne, sampler2D texTwo, fixed scrollXSpeed, fixed scrollYSpeed, half scaleOne, half scaleTwo) {
                float3 normalDistribution = tex2D(_NormalMapBlendingNoise, worldPosition.xz * 0.1); // For now xz is enough as we are having a straight surface here
                normalDistribution += tex2D(_NormalMapBlendingNoise, worldPosition.zx * 0.1); // For now xz is enough as we are having a straight surface here
                normalDistribution = normalize(normalDistribution);
                fixed xScrollValue = scrollXSpeed * _Time;
                fixed yScrollValue = scrollYSpeed * _Time;
                float3 colX = UnpackNormal(tex2D(texOne, (worldPosition.zy + float2(xScrollValue, yScrollValue)) * scaleOne));
                // colX = float3(colX.xy + colX.zy, colX.z * surfaceNormal.x);
                float3 colX2 = UnpackNormal(tex2D(texTwo, (worldPosition.zy + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * scaleTwo));
                // colX2 = float3(colX2.xy + colX2.zy, colX2.z * surfaceNormal.x);
                float3 colY = UnpackNormal(tex2D(texOne, (worldPosition.xz + float2(xScrollValue, yScrollValue)) * scaleOne));
                // colY = float3(colY.xy + colY.zy, colY.z * surfaceNormal.y);
                float3 colY2 = UnpackNormal(tex2D(texTwo, (worldPosition.xz + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * scaleTwo));
                // colY2 = float3(colY2.xy + colY2.zy, colY2.z * surfaceNormal.y);
                float3 colZ = UnpackNormal(tex2D(texOne, (worldPosition.xy + float2(xScrollValue, yScrollValue)) * scaleOne));
                // colZ = float3(colZ.xy + colZ.zy, colZ.z * surfaceNormal.z);
                float3 colZ2 = UnpackNormal(tex2D(texTwo, (worldPosition.xy + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * scaleTwo));
                // colZ2 = float3(colZ2.xy + colZ2.zy, colZ2.z * surfaceNormal.z);
                float3 blendWeight = pow(abs(normalize(surfaceNormal)), _BlendStrength);
                blendWeight /= dot(blendWeight, 1);
                float3 finalNormal = (colX.zyx + colX2.zyx) * blendWeight.x + (colY.xzy + colY2.xzy) * blendWeight.y + (colZ.xyz + colZ2.xyz) * blendWeight.z;
                finalNormal = (colX.zyx * normalDistribution.r + colX2.zyx * normalDistribution.g) * blendWeight.x + (colY.xzy * normalDistribution.r + colY2.xzy * normalDistribution.g) * blendWeight.y + (colZ.xyz * normalDistribution.r + colZ2.xyz * normalDistribution.g) * blendWeight.z;
                return (finalNormal);
            }


            float3 TriplanarTexture(float3 worldPosition, float3 surfaceNormal, sampler2D texOne, sampler2D texTwo, fixed scrollXSpeed, fixed scrollYSpeed, half scaleOne, half scaleTwo) {
                float3 normalDistribution = tex2D(_NormalMapBlendingNoise, worldPosition.xz * 0.1); // For now xz is enough as we are having a straight surface here
                normalDistribution += tex2D(_NormalMapBlendingNoise, worldPosition.zx * 0.1); // For now xz is enough as we are having a straight surface here
                normalDistribution = normalize(normalDistribution);
                fixed xScrollValue = scrollXSpeed * _Time;
                fixed yScrollValue = scrollYSpeed * _Time;
                float3 colX = (tex2D(texOne, (worldPosition.zy + float2(xScrollValue, yScrollValue)) * scaleOne)).rgb;
                // colX = float3(colX.xy + colX.zy, colX.z * surfaceNormal.x);
                float3 colX2 = (tex2D(texTwo, (worldPosition.zy + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * scaleTwo)).rgb;
                // colX2 = float3(colX2.xy + colX2.zy, colX2.z * surfaceNormal.x);
                float3 colY = (tex2D(texOne, (worldPosition.xz + float2(xScrollValue, yScrollValue)) * scaleOne)).rgb;
                // colY = float3(colY.xy + colY.zy, colY.z * surfaceNormal.y);
                float3 colY2 = (tex2D(texTwo, (worldPosition.xz + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * scaleTwo)).rgb;
                // colY2 = float3(colY2.xy + colY2.zy, colY2.z * surfaceNormal.y);
                float3 colZ = (tex2D(texOne, (worldPosition.xy + float2(xScrollValue, yScrollValue)) * scaleOne)).rgb;
                // colZ = float3(colZ.xy + colZ.zy, colZ.z * surfaceNormal.z);
                float3 colZ2 = (tex2D(texTwo, (worldPosition.xy + float2(_NormalMapOneTwoOffsetX, _NormalMapOneTwoOffsetY) - float2(xScrollValue, yScrollValue)) * scaleTwo)).rgb;
                // colZ2 = float3(colZ2.xy + colZ2.zy, colZ2.z * surfaceNormal.z);
                float3 blendWeight = pow(abs(normalize(surfaceNormal)), _BlendStrength);
                blendWeight /= dot(blendWeight, 1);
                // return (colZ.xyz * normalDistribution.r + colZ2.xyz * normalDistribution.g) * blendWeight.z;
                float3 finalNormal = (colX.zyx + colX2.zyx) * blendWeight.x + (colY.xzy + colY2.xzy) * blendWeight.y + (colZ.xyz + colZ2.xyz) * blendWeight.z;
                finalNormal = (colX.zyx * normalDistribution.r + colX2.zyx * normalDistribution.g) * blendWeight.x + (colY.xzy * normalDistribution.r + colY2.xzy * normalDistribution.g) * blendWeight.y + (colZ.xyz * normalDistribution.r + colZ2.xyz * normalDistribution.g) * blendWeight.z;
                return (finalNormal);
            }




            half4 LightingSimpleSpecular(inout SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten) {


                //float2 ripplesUV = s.posWorld.xz - _RippleOrthographicCamPosition.xz;
                //ripplesUV = ripplesUV / (_RippleOrthographicCamSize * 2);
                //ripplesUV += 0.5;

                float4 waterRippleMaskColor = tex2Dproj(_WaterRippleMaskTexture, UNITY_PROJ_COORD(s.screenPos));

                float3 ripples = (saturate((waterRippleMaskColor.b) + (waterRippleMaskColor.r)) * TriplanarNormal(s.posWorld, s.Normal, _WaterWakeFoamNormalOne, _WaterWakeFoamNormalOne, 0, 0, 0.05, 0.05)) * float3(5, 5, 1);

                half3 h = normalize(lightDir + viewDir);

                half diff = dot(normalize(s.Normal + TriplanarNormal(s.posWorld, s.Normal, _NormalMapOne, _NormalMapTwo, _ScrollXSpeed, _ScrollYSpeed, _NormalUVScaleOne, _NormalUVScaleTwo)), lightDir); // Value decrease if the light is at a greater angle

                half nh = dot(normalize(s.Normal + ripples + TriplanarNormal(s.posWorld, s.Normal, _NormalMapOne, _NormalMapTwo, _ScrollXSpeed, _ScrollYSpeed, _NormalUVScaleOne, _NormalUVScaleTwo)), h);
                nh = saturate(nh);
                float specAngle = acos(nh);
                float specExponent = specAngle / _Glossiness;
                diff = saturate(diff);
                float spec;
                float distToWaterFromCam = length(viewDir);
                spec = exp(-specExponent * specExponent);
                half ripplesReflection = dot(normalize(ripples * (s.Normal + ripples)), h);
                ripplesReflection = saturate(ripplesReflection);
                float ripplesSpecAngle = acos(ripplesReflection);
                float ripplesSpecExponent = ripplesSpecAngle / _Glossiness;
                float ripplesSpec;
                ripplesSpec = exp(-ripplesSpecExponent * ripplesSpecExponent);

                half4 c;
                // c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
                // c.rgb = (s.Albedo * _LightColor0.rgb * pow(diff, 40) * 80 + _LightColor0.rgb * pow(diff, 200) * 1000 + _LightColor0.rgb * spec * 1) * atten;
                c.rgb = (s.Albedo * _LightColor0.rgb * diff * 2 + _LightColor0.rgb * spec * 1.5) * atten;
                // c.rgb = s.Albedo;
                c.a = s.Alpha;

                return c;
            }

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

            float4 _SuckerCenter;
            float _SuckerRadius;
            fixed4 _SuckerColor;


            float normpdf(float x, float sigma)
            {
                return 0.39894 * exp(-0.5 * x * x / (sigma * sigma)) / sigma;
            }

            fixed4 blur(sampler2D tex, float2 uv, float blurAmount)
            {
                // get our base color...
                fixed4 col = tex2D(tex, uv);

                // total width/height of our blur "grid":
                const int mSize = 11;

                // this gives the number of times we'll iterate our blur on each side 
                // (up,down,left,right) of our uv coordinate;
                // NOTE that this needs to be a const or you'll get errors about unrolling for loops
                const int iter = (mSize - 1) / 2;

                //run loops to do the equivalent of what's written out line by line above
                //(number of blur iterations can be easily sized up and down this way)
                for (int i = -iter; i <= iter; ++i)
                {
                    for (int j = -iter; j <= iter; ++j)
                    {
                        col += tex2D(tex, float2(uv.x + i * blurAmount, uv.y + j * blurAmount)) * normpdf(float(i), 3);
                    }
                }

                //return blurred color
                return col / mSize;
            }

            float _WaterSplashThreshold;

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

                float2 ripplesUV = worldPos.xz - _RippleOrthographicCamPosition.xz;
                ripplesUV = ripplesUV / (_RippleOrthographicCamSize * 2);
                ripplesUV += 0.5;

                float ripples = (tex2Dlod(_RippleMask,float4(ripplesUV, 0, 0))) * 0.1;

                float3 normal = normalize(cross(binormal, tangent));
                v.vertex.xyz = p;
                v.normal = normal;
            }

            void surf(Input IN, inout SurfaceOutputCustom o)
            {
                // Deep Color and Light Color

                fixed4 cdeep = _ColorDeep;
                fixed4 clight = _ColorLight;
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

                float dotProduct = dot(normalize(IN.viewDir), o.Normal + TriplanarNormal(IN.worldPos, o.Normal, _NormalMapOne, _NormalMapTwo, _ScrollXSpeed, _ScrollYSpeed, _NormalUVScaleOne, _NormalUVScaleTwo));
                half rim = 1 - min(0.2, saturate(dotProduct < 0 ? -dotProduct : dotProduct));
                half opacityRim = 1 - min(0.2, saturate(dotProduct < 0 ? -dotProduct : dotProduct));

                // Fresnel Effect

                // Using the camera's depth texture to get the distToBottomLand from the camera

                float distToBottomLand = tex2Dproj(_CustomCameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
                // float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, IN.screenPos);
                distToBottomLand = LinearEyeDepth(distToBottomLand) * length(IN.viewDir);

                // Using the camera's depth texture to get the distToBottomLand from the camera

                // Getting the depth texture from the water surface by substracting the  water's screenPos.w from the distToBottomLand

                float fogDiff = saturate((distToBottomLand - IN.screenPos.w) / _FogThreshold);
                fogDiff = pow(fogDiff, 0.5);
                float intersectionDiff = saturate((distToBottomLand - IN.screenPos.w) / _IntersectionThreshold);
                float foamDiff = saturate((_FoamThreshold == 0) ? 1 : saturate((distToBottomLand - IN.screenPos.w) / _FoamThreshold));
                foamDiff = saturate(pow(foamDiff, _FoamSmoothness));
                // foamDiff *= (1.0 - rt.b);

                // Getting the depth texture from the water surface by substracting the  water's screenPos.w from the distToBottomLand

                float4 waterRippleMaskColor = tex2Dproj(_WaterRippleMaskTexture, UNITY_PROJ_COORD(IN.screenPos));

                float3 ripplesNormal = ((waterRippleMaskColor.b) * TriplanarNormal(IN.worldPos, o.Normal, _WaterWakeFoamNormalOne, _WaterWakeFoamNormalOne, 0, 0, 0.05, 0.05)) * float3(5, 5, 1);


                // Getting the screen space UV for the grabTexture

                float2 postRefractionUVOffset = normalize(IN.viewDir + normalize(normalize(o.Normal) + ripplesNormal + TriplanarNormal(IN.worldPos, o.Normal, _NormalMapOne, _NormalMapTwo, _ScrollXSpeed, _ScrollYSpeed, _NormalUVScaleOne, _NormalUVScaleTwo))).xy;
                float2 refractionUVOffset = postRefractionUVOffset * _NormalDistortionIntensity;
                refractionUVOffset.y *= (_GrabTexture_TexelSize.z * abs(_GrabTexture_TexelSize.y));
                float2 screenPosUV = (IN.screenPos.xy + refractionUVOffset) / IN.screenPos.w;
                float distToBottomLandDistorted = tex2Dproj(_CustomCameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + float4(refractionUVOffset, 0, 0)));
                // waterRippleMaskColor = blur(_WaterRippleMaskTexture, (IN.screenPos.xy / IN.screenPos.w), .0035);
                // float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, IN.screenPos);
                distToBottomLandDistorted = LinearEyeDepth(distToBottomLandDistorted);
                float intersectionDiffDistorted = (distToBottomLandDistorted - IN.screenPos.w);
                if (intersectionDiffDistorted < 0) {
                    screenPosUV = IN.screenPos.xy / IN.screenPos.w;
                    #if UNITY_UV_STARTS_AT_TOP
                        if (_CustomCameraDepthTexture_TexelSize.y < 0) {
                            screenPosUV.y = 1 - screenPosUV.y;
                        }
                    #endif
                    distToBottomLandDistorted = tex2Dproj(_CustomCameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
                    // waterRippleMaskColor = tex2Dproj(_WaterRippleMaskTexture, UNITY_PROJ_COORD(IN.screenPos + float4(refractionUVOffset, 0, 0)));
                    // waterRippleMaskColor = blur(_WaterRippleMaskTexture, (IN.screenPos.xy / IN.screenPos.w), .0035);
                    distToBottomLandDistorted = LinearEyeDepth(distToBottomLandDistorted);
                    intersectionDiffDistorted = distToBottomLandDistorted - IN.screenPos.w;
                }

                float3 sampledGrabTex = tex2D(_GrabTexture, screenPosUV) + tex2D(_FoamTexture, screenPosUV) * 0;
                // o.Albedo.rgb = sampledGrabTex;
                // o.Albedo.rgb = intersectionDiffDistorted;
                // o.Albedo.rgb = tex2Dproj(_ShadowMapTexture, UNITY_PROJ_COORD(IN.screenPos + float4(refractionUVOffset, 0, 0)));
                if (dot(o.Normal, IN.viewDir) < 0) {
                    intersectionDiffDistorted = saturate(intersectionDiffDistorted / (_IntersectionThresholdUnderWater / pow(IN.screenPos.w, 0.2)));
                }
    else {
       intersectionDiffDistorted = saturate(intersectionDiffDistorted / _IntersectionThreshold);
   }
   float grabTexFogFactor = (1 - pow(intersectionDiffDistorted, min(_IntersectionSmoothnessBackGround, _IntersectionSmoothness)));
   // foamDiff = (1 - pow(intersectionDiffDistorted, min(_IntersectionSmoothnessBackGround, _FoamSmoothness)));


   // Getting the screen space UV for the grabTexture


   // Computing the Albedos one after another

   float3 fresnelAlbedo = (lerp(cdeep, clight, pow(rim, _FresnelPower)) * _FresnelBrightness).rgb;
   // * exp(intersectionDiff * _IntersectionSmoothness)
   float3 prevPlusDepthAlbedo = lerp(clight, fresnelAlbedo, pow(intersectionDiffDistorted, _IntersectionSmoothness)); // Later to be interpolated at different rates for r g and b
   // float3 prevPlusGrabAlbedo = lerp(prevPlusDepthAlbedo, sampledGrabTex, grabTexFogFactor);
   float3 prevPlusGrabAlbedo = lerp(prevPlusDepthAlbedo, sampledGrabTex, grabTexFogFactor);

   // Computing the Albedos one after another


   // Applying ripples

   float2 ripplesUV = IN.worldPos.xz - _RippleOrthographicCamPosition.xz;
   ripplesUV = ripplesUV / (_RippleOrthographicCamSize * 2);
   ripplesUV += 0.5;
   float2 waterWakeFoamSamplingUV = IN.uv_NormalMapOne;
   waterWakeFoamSamplingUV.x += (_Time * 0.2);
   waterWakeFoamSamplingUV.y += (_Time * 0.5);

   // float3 ripples = saturate((tex2D(_RippleMask, ripplesUV).b) + (tex2D(_RippleMask, ripplesUV).r))  *pow(tex2D(_WaterWakeFoamTexOne, waterWakeFoamSamplingUV * 2), 5);
   float3 ripples = (saturate((waterRippleMaskColor.b) + (waterRippleMaskColor.r)) * (pow(TriplanarTexture(IN.worldPos, o.Normal, _WaterWakeFoamTexTwo, _WaterWakeFoamTexOne, sin(_Time.x) * 0.02, cos(_Time.y + sin(_Time.x + 2)) * 0.05, 0.05, 0.05), 5)));
   // ripples = (pow(TriplanarTexture(IN.worldPos, o.Normal, _WaterWakeFoamTexTwo, _WaterWakeFoamTexOne, sin(_Time.x) * 0.02, cos(_Time.y + sin(_Time.x + 2)) * 0.05, 0.05, 0.05), 2));
   //  
   // ripples = step(0.99, ripples * 3);

   // prevPlusGrabAlbedo += ripples;
   // Applying ripples


   // Applying the albedo (we only apply the depth colored albedo here because the uderwater should not be affected by the sunlight and albedo is infact affected by sunlight... so we apply the grabtexture in the emission channel)

   o.posWorld = IN.worldPos;
   o.screenPos = IN.screenPos;
   // float thresh = step(_WaterSplashThreshold, waterRippleMaskColor.w);
   // waterRippleMaskColor *= thresh;
   // fixed4 finalWaterSplashColor = tex2D(_GrabTexture, waterRippleMaskColor.yx) * thresh;
   o.Albedo.rgb = (prevPlusGrabAlbedo)+ripples * 0.5;
   // o.Albedo = waterRippleMaskColor; // See the ripples particle color
   // o.Albedo.rgb = ripples;
   // o.Albedo.rgb = grabTexFogFactor;
   float dstOfPointFromSucker = pow((IN.worldPos.x - _SuckerCenter.x), 2) + pow((IN.worldPos.z - _SuckerCenter.z), 2);
   float fractionDstOfPointFromSucker = (InverseLerp(0, _SuckerRadius * _SuckerRadius, dstOfPointFromSucker));
   fractionDstOfPointFromSucker = (fractionDstOfPointFromSucker > 1) ? 0 : fractionDstOfPointFromSucker;

   // o.Albedo.rgb = (dstOfPointFromSucker <= _SuckerRadius * _SuckerRadius) ? o.Albedo.rgb + (_SuckerColor) : o.Albedo.rgb;
   // o.Albedo.rgb = pow(intersectionDiff, _IntersectionSmoothness); // Uncomment this for seeing the depth texture mask
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

   float foamTex = saturate(tex2D(_FoamTexture, IN.worldPos.xz * _FoamTexture_ST.xy + _Time.y * float2(_FoamTextureSpeedX, _FoamTextureSpeedY)));
   float foam = (saturate(foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 10 * UNITY_PI)) * (1.0 - foamDiff))) < saturate(foamTex));
   float intensityAtThisPoint = foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 10 * UNITY_PI)) * (1.0 - foamDiff));
   // o.Albedo.rgb = foamDiff - (saturate(sin((foamDiff - _Time.y * _FoamLinesSpeed) * 8 * UNITY_PI)) * (1.0 - foamDiff));

   // Computing the foam 


   // Applying the foam here (and also the GrabTexture for underwater seen)

    // o.Albedo = 1;
   // o.Albedo = TriplanarNormal(IN.worldPos, o.Normal);

   // o.Emission = foam * foamTex * _FoamIntensity;
   o.Albedo += foam * _FoamIntensity;
   // o.Albedo = foamDiff;

   o.Albedo.rgb = lerp(o.Albedo.rgb, _SuckerColor, fractionDstOfPointFromSucker / 1.5);

   // Applying the foam here (and also the GrabTexture for underwater seen)
}
ENDCG
        }
            FallBack "Diffuse"
    // FallBack Off
}
