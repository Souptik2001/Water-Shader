using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnderWater : MonoBehaviour
{

    public Shader underwaterShader;
    Material underwaterMat;
    public Waves waveScript;
    Color underwaterColor = Color.HSVToRGB(175, 100, 100);

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Initialize the underwaterMat
        if (underwaterMat == null)
        {
            underwaterMat = new Material(underwaterShader);
        }
        // Set underwaterMat variables
        //Vector3 boxSize = waveScript.getBoundingBox();
        //Vector3 lowerBound = waveScript.transform.position - new Vector3(waveScript.LOD, boxSize.y, waveScript.LOD);
        //Vector2 extraHeight = waveScript.getBoxHeight();
        //if (extraHeight.y == 1) { Graphics.Blit(source, destination); return; }
        //// lowerBound += new Vector3(0, extraHeight.x, 0);
        //Vector3 upperBound = lowerBound + boxSize + new Vector3(0, extraHeight.x, 0);
        //underwaterMat.SetVector("BoundsMin", lowerBound);
        //underwaterMat.SetVector("BoundsMax", upperBound);
        //underwaterMat.SetColor("_UnderwaterColor", underwaterColor);

        // Pass that material in the render texture
        Graphics.Blit(source, destination, underwaterMat);
    }
}
