using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamDepth : MonoBehaviour
{
    Camera cam;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (cam == null)
        {
            cam = this.GetComponent<Camera>();
        }
        //cam.depthTextureMode = DepthTextureMode.DepthNormals;
    }
}
