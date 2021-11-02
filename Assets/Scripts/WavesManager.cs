using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WavesManager : MonoBehaviour
{
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
        else if(instance != this)
        {
            Debug.Log("Instace already present, destroying object");
            Destroy(this);
        }
    }

    void Update()
    {
        for(int i=0; i<material.Length; i++)
        {
            if (i >= allWaves.Length)
            {
                return;
            }
            for(int j=0; j < allWaves[i].waveProperties.Length; j++)
            {
                WaveProperties waveProperty = allWaves[i].waveProperties[j];
                material[i].SetVector("_Wave" + j, new Vector4(waveProperty.direction.x, waveProperty.direction.y, waveProperty.steepness, waveProperty.wavelength));
            }
        }
    }

    float GerstnerWave(Vector4 wave, Vector3 worldPos)
    {
        float steepness = wave.z;
        float wavelength = wave.w;
        float k = 2 * Mathf.PI / wavelength;
        float c = Mathf.Sqrt(9.8f / k);
        Vector2 d = new Vector2(wave.x, wave.y).normalized;
        float f = k * (Vector2.Dot(d, new Vector2(worldPos.x, worldPos.z)) - c * Time.time);
        float a = steepness / k;
        return a * Mathf.Sin(f-Mathf.Cos(f));
        //p.x += d.x * (a * cos(f));
        //p.y = a * sin(f);
        //p.z += d.y * (a * cos(f));
        //return new Vector3(
        //    d.x * (a * Mathf.Cos(f)),
        //    a * Mathf.Sin(f),
        //    d.y * (a * Mathf.Cos(f))
        //    );
    }

    public float getHeight(int i, Vector3 worldPos)
    {
        float h = 0;
        if (i < allWaves.Length)
        {
            for(int j=0; j<allWaves[i].waveProperties.Length; j++)
            {
                h += GerstnerWave(new Vector4(allWaves[i].waveProperties[j].direction.x, allWaves[i].waveProperties[j].direction.y, allWaves[i].waveProperties[j].steepness, allWaves[i].waveProperties[j].wavelength), worldPos);
            }
        }
        return h;
    }

}
