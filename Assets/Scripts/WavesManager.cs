using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WavesManager : MonoBehaviour
{
    public Transform player;
    Camera cam_main;
    Camera cam_sec;
    // Camera cam_ripple_ortho;
    RenderTexture waterRipple_rt;
    RenderTexture waterSplash_rt;
    MainCameraTexturesPasser mainCameraDepthPasser;
    public Material waterMaterial;
    RenderTexture sceneDepthTexture;
    RenderTexture t_rt;
    public LayerMask layersToCaptureDepthFrom;
    public LayerMask layersToCaptureRipplesFrom;
    public GameObject waterPrefab;
    [Range(0f, 1f)]
    public float waveRotationRate;
    public Vector2 totalWaterDimension;
    public Material[] material;
    public AllWaves[] allWaves;
    [HideInInspector]
    public static WavesManager instance;


    [System.Serializable]
    public class WaveProperties
    {
        public Vector2 direction = new Vector2(1, 0);
        public float steepness = 0.5f;
        public float wavelength = 10;
        public WaveProperties()
        {
            direction = new Vector2(1, 0);
            steepness = 0.5f;
            wavelength = 10;
        }

    }

    [System.Serializable]
    public struct AllWaves
    {
        public WaveProperties[] waveProperties;
    }

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if (instance != this)
        {
            Debug.Log("Instace already present, destroying object");
            Destroy(this);
            return;
        }
        if (cam_main == null) cam_main = Camera.main;
        mainCameraDepthPasser = cam_main.gameObject.AddComponent<MainCameraTexturesPasser>();
        mainCameraDepthPasser.waterMaterial = waterMaterial;
        mainCameraDepthPasser.cam_main = cam_main;
        mainCameraDepthPasser.layersToCaptureDepthFrom = layersToCaptureDepthFrom;
        mainCameraDepthPasser.layersToCaptureRipplesFrom = layersToCaptureRipplesFrom;
        if (sceneDepthTexture == null)
        {
            sceneDepthTexture = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
            mainCameraDepthPasser.sceneDepthTexture = sceneDepthTexture;
        }
        if (waterSplash_rt == null)
        {
            waterSplash_rt = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBFloat);
            mainCameraDepthPasser.waterSplashTexture = waterSplash_rt;
        }
        if (cam_sec == null)
        {
            GameObject cam_sec_GO = new GameObject("DepthPlusRipplesCaptureCam");
            // cam_sec_GO.transform.position = Vector3.zero;
            // cam_sec_GO.transform.rotation = Quaternion.identity;
            cam_sec_GO.transform.parent = cam_main.transform;
            cam_sec = cam_sec_GO.AddComponent<Camera>();
            cam_sec.CopyFrom(cam_main);
            cam_sec.enabled = false;
            cam_sec.clearFlags = CameraClearFlags.SolidColor;
            cam_sec.backgroundColor = Color.black;
            mainCameraDepthPasser.cam_sec = cam_sec;
            cam_sec.depthTextureMode = DepthTextureMode.Depth;
            // cam_sec.cullingMask = layersToCaptureDepthFrom;
            t_rt = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
            mainCameraDepthPasser.t_rt = t_rt;
            cam_sec.SetTargetBuffers(t_rt.colorBuffer, sceneDepthTexture.depthBuffer);
        }
        float startingPointX = transform.position.x - (totalWaterDimension.x / 2);
        float startingPointY = transform.position.z - (totalWaterDimension.y / 2);
        for (float x = startingPointX; x < transform.position.x + (totalWaterDimension.x / 2); x += 20)
        {
            for (float z = startingPointY; z < transform.position.z + (totalWaterDimension.y / 2); z += 20)
            {
                GameObject newWaterChunk = Instantiate(waterPrefab, new Vector3(x, transform.position.y, z), Quaternion.identity, transform);
                newWaterChunk.GetComponent<Waves>().cam_main = cam_main;
            }
        }
    }


    Vector2 RotateWaveDirection(Vector2 waveDir)
    {
        return Quaternion.AngleAxis(waveRotationRate, Vector3.forward) * waveDir;
    }


    void Update()
    {
        if (cam_sec == null)
        {
            GameObject cam_sec_GO = new GameObject("DepthPlusRipplesCaptureCam");
            // cam_sec_GO.transform.position = Vector3.zero;
            // cam_sec_GO.transform.rotation = Quaternion.identity;
            cam_sec_GO.transform.parent = cam_main.transform;
            cam_sec = cam_sec_GO.AddComponent<Camera>();
            cam_sec.CopyFrom(cam_main);
            cam_sec.enabled = false;
            mainCameraDepthPasser.cam_sec = cam_sec;
            mainCameraDepthPasser.layersToCaptureDepthFrom = layersToCaptureDepthFrom;
            mainCameraDepthPasser.layersToCaptureRipplesFrom = layersToCaptureRipplesFrom;
            cam_sec.clearFlags = CameraClearFlags.Nothing;
            cam_sec.cullingMask = layersToCaptureDepthFrom;
            t_rt = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
            mainCameraDepthPasser.t_rt = t_rt;
            cam_sec.SetTargetBuffers(t_rt.colorBuffer, sceneDepthTexture.depthBuffer);
        }
        // cam_sec.CopyFrom(cam_main);
        if (sceneDepthTexture == null)
        {
            sceneDepthTexture = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth, RenderTextureReadWrite.Linear);
            mainCameraDepthPasser.sceneDepthTexture = sceneDepthTexture;
        }
        if (waterSplash_rt == null)
        {
            waterSplash_rt = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBFloat);
            mainCameraDepthPasser.waterSplashTexture = waterSplash_rt;
        }
        for (int i = 0; i < material.Length; i++)
        {
            if (i >= allWaves.Length)
            {
                return;
            }
            for (int j = 0; j < allWaves[i].waveProperties.Length; j++)
            {
                allWaves[i].waveProperties[j].direction = RotateWaveDirection(allWaves[i].waveProperties[j].direction);
                WaveProperties waveProperty = allWaves[i].waveProperties[j];
                material[i].SetVector("_Wave" + j, new Vector4(waveProperty.direction.x, waveProperty.direction.y, waveProperty.steepness, waveProperty.wavelength));
            }
        }
    }

    Vector3 GerstnerWave(Vector4 wave, Vector3 worldPos)
    {
        float steepness = wave.z;
        float wavelength = wave.w;
        float k = 2 * Mathf.PI / wavelength;
        float c = Mathf.Sqrt(9.8f / k);
        Vector2 d = new Vector2(wave.x, wave.y).normalized;
        float f = k * (Vector2.Dot(d, new Vector2(worldPos.x, worldPos.z)) - c * Time.time);
        float a = steepness / k;
        // return a * Mathf.Sin(f-Mathf.Cos(f));
        //p.x += d.x * (a * cos(f));
        //p.y = a * sin(f);
        //p.z += d.y * (a * cos(f));
        return new Vector3(
            d.x * (a * Mathf.Cos(f)),
            // a * Mathf.Sin(f - Mathf.Cos(f)),
            a * Mathf.Sin(f),
            d.y * (a * Mathf.Cos(f))
            );
    }



    public Vector3 getHeight(int i, Vector3 worldPos)
    {
        Vector3 h = new Vector3(worldPos.x, transform.position.y, worldPos.z);
        if (i < allWaves.Length)
        {
            for (int j = 0; j < allWaves[i].waveProperties.Length; j++)
            {
                h += GerstnerWave(new Vector4(allWaves[i].waveProperties[j].direction.x, allWaves[i].waveProperties[j].direction.y, allWaves[i].waveProperties[j].steepness, allWaves[i].waveProperties[j].wavelength), worldPos);
            }
        }
        return h;
    }

    public Vector2 waveSpeed(int i)
    {
        Vector2 finalWaveDirection = Vector2.zero;
        if (i < allWaves.Length)
        {
            for (int j = 0; j < allWaves[i].waveProperties.Length; j++)
            {
                float k = 2 * Mathf.PI / allWaves[i].waveProperties[j].wavelength;
                finalWaveDirection += allWaves[i].waveProperties[j].direction.normalized * Mathf.Sqrt(9.8f / k) * allWaves[i].waveProperties[j].steepness;
            }
        }
        return finalWaveDirection;
    }

}
