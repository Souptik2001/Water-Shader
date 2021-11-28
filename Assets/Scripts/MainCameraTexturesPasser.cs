using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCameraTexturesPasser : MonoBehaviour
{
    public Camera cam_main;
    public Camera cam_sec;
    public Material waterMaterial;
    public LayerMask layersToCaptureDepthFrom;
    public LayerMask layersToCaptureRipplesFrom;
    public RenderTexture sceneDepthTexture;
    public RenderTexture t_rt;
    public RenderTexture waterSplashTexture;
    float prevHeight;
    float prevWidth;
    void Start()
    {

    }

    private void OnPreRender()
    {
        if (waterMaterial != null && sceneDepthTexture != null && waterSplashTexture != null)
        {
            //cam_sec.transform.position = cam_main.transform.position;
            //cam_sec.transform.rotation = cam_main.transform.rotation;
            // cam_sec.rect = cam_main.rect;
            if (prevHeight != Screen.height || prevWidth != Screen.width)
            {
                sceneDepthTexture.Release();
                sceneDepthTexture.width = Screen.width;
                sceneDepthTexture.height = Screen.height;
                sceneDepthTexture.Create();
                t_rt.Release();
                t_rt.width = Screen.width;
                t_rt.height = Screen.height;
                t_rt.Create();
                waterSplashTexture.Release();
                waterSplashTexture.width = Screen.width;
                waterSplashTexture.height = Screen.height;
                waterSplashTexture.Create();
            }
            cam_sec.cullingMask = layersToCaptureRipplesFrom;
            cam_sec.targetTexture = waterSplashTexture;
            cam_sec.Render();
            cam_sec.cullingMask = layersToCaptureDepthFrom;
            cam_sec.SetTargetBuffers(t_rt.colorBuffer, sceneDepthTexture.depthBuffer);
            cam_sec.Render();
            waterMaterial.SetTexture("_CustomCameraDepthTexture", sceneDepthTexture);
            waterMaterial.SetTexture("_WaterRippleMaskTexture", waterSplashTexture);
            float width = sceneDepthTexture.width;
            float height = sceneDepthTexture.height;
            waterMaterial.SetVector("_CustomCameraDepthTexture_TexelSize", new Vector4(1 / width, 1 / height, width, height));
        }
        prevHeight = Screen.height;
        prevWidth = Screen.width;
    }
}
