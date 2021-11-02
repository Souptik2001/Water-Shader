Shader "SouptikDatta/UnderwaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float3 BoundsMin;
            float3 BoundsMax;
            fixed4 _UnderwaterColor;

            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_TexelSize;



            float remap(float v, float minOld, float maxOld, float minNew, float maxNew) {
                return minNew + (v - minOld) * (maxNew - minNew) / (maxOld - minOld);
            }

            // Checking the intersection with the bounding box of the water // Not understood
            float2 rayBoxDist(float3 boundsMin, float3 boundsMax, float3 rayOrigin, float3 invRayDir) {

                float3 t0 = (boundsMin - rayOrigin) * invRayDir;
                float3 t1 = (boundsMax - rayOrigin) * invRayDir;

                float3 tmin = min(t0, t1);
                float3 tmax = max(t0, t1);

                float dstA = max(max(tmin.x, tmin.y), tmin.z);
                float dstB = min(tmax.x, min(tmax.y, tmax.z));

                float distToBox = max(0, dstA);
                float distInsideBox = max(0, dstB - distToBox);
                return float2(distToBox, distInsideBox);
                // If distInsideBox is zero then the ray does not intersect the box
            }


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewVector : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
                return o;
            }

            fixed4 getUnderWaterColor(fixed4 col, float depth) {
                // return fixed4(depth, depth, depth, 1);
                // return col * _UnderwaterColor;
                _UnderwaterColor.a = 1;
                return lerp(col, _UnderwaterColor, depth);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * float4(0, 0, 1, 1);
                //float3 rayOrigin = _WorldSpaceCameraPos;
                //float3 rayDir = normalize(i.viewVector);
                ////col = float4(BoundsMax, 1);
                ////return col;
                //float nonLinearDepthTexture = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                //float depth = LinearEyeDepth(nonLinearDepthTexture);
                //float2 rayBoxInfo = rayBoxDist(BoundsMin, BoundsMax, rayOrigin, 1.0f/rayDir);
                //float distToBox = rayBoxInfo.x;
                //float distInsideBox = rayBoxInfo.y;
                //bool rayBoxHit = distInsideBox > 0;
                //col = fixed4(abs(rayDir), 1);
                //return col;
                ////if (rayBoxHit && distToBox <= 0) {
                ////    col = 1;
                ////    return col;
                ////}
                //if (rayBoxHit) {
                //    col = 0;
                //}
                //return col;
            }
            ENDCG
        }
    }
}
