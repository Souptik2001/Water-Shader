using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class Waves : MonoBehaviour
{
    public bool centerPivot = true;
    [Range(1, 500)]
    public int Dimensions = 10;
    public Material waterTopMaterial;
    private Octave[] octaves; // This actually is no longer required
    [Range(0, 0.9f)]
    public float LOD = 0f;
    [Range(0, 1)]
    public float UVScale = 0f;
    private MeshFilter meshFilter;
    private Mesh mesh;
    private int prevDimensions;
    private float prevLOD;
    private float prevUVScale;

    [Header("Underwater shader data")]
    public float waterDepth;
    public Shader underwaterShader;
    [HideInInspector]
    public Camera cam_main;

    void Start()
    {
        //if (camera != null)
        //{
        //    underWaterScript = camera.gameObject.AddComponent<UnderWater>();
        //    underWaterScript.underwaterShader = underwaterShader;
        //    underWaterScript.waveScript = this;
        //}
        //else { Debug.LogError("Please assign the camera to see the underwater effect."); }
        InitializeWaterTopMesh();
        GenerateWaterTopMesh(); ;
        prevDimensions = Dimensions;
        prevLOD = LOD;
        prevUVScale = UVScale;
    }

    private void InitializeWaterTopMesh()
    {
        meshFilter = gameObject.AddComponent<MeshFilter>();
        MeshRenderer meshRenderer = gameObject.GetComponent<MeshRenderer>();
        if (waterTopMaterial != null && meshRenderer != null) meshRenderer.material = waterTopMaterial;
    }

    private void GenerateWaterTopMesh()
    {
        mesh = new Mesh();
        mesh.name = gameObject.name;

        mesh.vertices = GenerateVertices();
        mesh.triangles = GenerateTriangles();
        mesh.uv = GenerateUV();
        mesh.RecalculateBounds();
        // mesh.RecalculateNormals();


        meshFilter.mesh = mesh;
    }

    private Vector2[] GenerateUV()
    {
        Vector2[] uvs = new Vector2[mesh.vertices.Length];
        for (int i = 0; i <= Dimensions; i++)
        {
            for (int j = 0; j <= Dimensions; j++)
            {
                Vector2 uv = new Vector2(((float)(i) / (float)(Dimensions)) % 2f, ((float)(j) / (float)(Dimensions)) % 2f);
                uvs[generateIndex(i, j)] = new Vector2(uv.x <= 1 ? uv.x : 2 - uv.x, uv.y <= 1 ? uv.y : 2 - uv.y);
            }
        }
        return uvs;
    }

    private int[] GenerateTriangles()
    {
        // var tries = new int[mesh.vertices.Length * 6];
        var tries = new int[Dimensions * Dimensions * 6];
        for (int i = 0; i < Dimensions; i++)
        {
            for (int j = 0; j < Dimensions; j++)
            {
                int firstIndex = (i * Dimensions) + j;
                int offsetVal = (firstIndex * 6) - 1;
                tries[offsetVal + 1] = generateIndex(i, j);
                tries[offsetVal + 2] = generateIndex(i + 1, j + 1);
                tries[offsetVal + 3] = generateIndex(i + 1, j);
                tries[offsetVal + 4] = generateIndex(i, j + 1);
                tries[offsetVal + 5] = generateIndex(i + 1, j + 1);
                tries[offsetVal + 6] = generateIndex(i, j);
            }
        }
        return tries;
    }

    private Vector3[] GenerateVertices()
    {
        var verts = new Vector3[(Dimensions + 1) * (Dimensions + 1)];
        for (int i = 0; i <= Dimensions; i++)
        {
            for (int j = 0; j <= Dimensions; j++)
            {
                if (centerPivot)
                {
                    verts[generateIndex(i, j)] = new Vector3(i - (LOD * (i + 1)) - ((1 - LOD) * (float)(Dimensions)) / 2, 0, j - (LOD * (j + 1)) - ((1 - LOD) * (float)(Dimensions)) / 2); // This is wrong
                }
                else
                {
                    verts[generateIndex(i, j)] = new Vector3(i - (LOD * (i + 1)), 0, j - (LOD * (j + 1)));
                }
            }
        }
        return verts;
    }

    private int generateIndex(int i, int j)
    {
        return (i * (Dimensions + 1)) + j;
        ;
    }

    void Update()
    {
        if (cam_main != null) { cam_main.depthTextureMode = DepthTextureMode.Depth; } else { Debug.LogError("Please assign the camera to get the depth texture"); }
        if (prevDimensions != Dimensions || prevLOD != LOD || prevUVScale != UVScale)
        {
            GenerateWaterTopMesh();
            prevDimensions = Dimensions;
            prevLOD = LOD;
            prevUVScale = UVScale;
        }
        // ApplyOctaves();
    }

    private void ApplyOctaves()
    {
        var verts = mesh.vertices;
        for (int i = 0; i <= Dimensions; i++)
        {
            for (int j = 0; j <= Dimensions; j++)
            {
                float yVal = 0;

                for (int o = 0; o < octaves.Length; o++)
                {
                    if (octaves[o].enabled)
                    {
                        if (octaves[o].alternate)
                        {
                            var perl = Mathf.PerlinNoise((i * octaves[o].scale.x) / Dimensions, (j * octaves[o].scale.y) / Dimensions) * Mathf.PI * 2f;
                            yVal += Mathf.Cos(perl + octaves[o].speed.magnitude * Time.time) * octaves[o].height;
                        }
                        else
                        {
                            var perl = Mathf.PerlinNoise((i * octaves[o].scale.x + Time.time * octaves[o].speed.x) / Dimensions, (j * octaves[o].scale.y + Time.time * octaves[o].speed.y) / Dimensions) - 0.5f;
                            yVal += perl * octaves[o].height;
                        }
                    }
                }
                int modifyingIndex = generateIndex(i, j);
                verts[modifyingIndex] = new Vector3(verts[modifyingIndex].x, yVal, verts[modifyingIndex].z);
            }
        }
        mesh.vertices = verts;
        mesh.RecalculateNormals();
    }

    [Serializable]
    public struct Octave
    {
        public Vector2 speed;
        public Vector2 scale;
        public float height;
        public bool alternate;
        public bool enabled;
    }


    // Vector2 - Height, OutOfBoundary
    public Vector2 getHeight(Vector3 pos)
    {
        Vector3 scale = new Vector3(1 / transform.lossyScale.x, 0, 1 / transform.lossyScale.z);
        Vector3 localPos = Vector3.Scale(pos - transform.position, scale);
        localPos += new Vector3(LOD, 0, LOD);
        localPos = localPos / (1 - LOD);
        if (localPos.x < 0 || localPos.z < 0 || localPos.x > Dimensions || localPos.z > Dimensions)
        {
            return new Vector2(0, 1);
        }
        int XFloorVal = Mathf.FloorToInt(localPos.x);
        int XCeilVal = Mathf.CeilToInt(localPos.x);
        int ZFloorVal = Mathf.FloorToInt(localPos.z);
        int ZCeilVal = Mathf.CeilToInt(localPos.z);
        Vector2 bl = new Vector2(Mathf.FloorToInt(localPos.x), Mathf.FloorToInt(localPos.z));
        Vector2 br = new Vector2(Mathf.CeilToInt(localPos.x), Mathf.FloorToInt(localPos.z));
        Vector2 tl = new Vector2(Mathf.FloorToInt(localPos.x), Mathf.CeilToInt(localPos.z));
        Vector2 tr = new Vector2(Mathf.CeilToInt(localPos.x), Mathf.CeilToInt(localPos.z));
        var verts = mesh.vertices;
        float i1 = Mathf.Lerp(verts[generateIndex((int)bl.x, (int)bl.y)].y, verts[generateIndex((int)br.x, (int)br.y)].y, ((XCeilVal - XFloorVal) - (XCeilVal - localPos.x)) / (XCeilVal - XFloorVal));
        float i2 = Mathf.Lerp(verts[generateIndex((int)tl.x, (int)tl.y)].y, verts[generateIndex((int)tr.x, (int)tr.y)].y, ((XCeilVal - XFloorVal) - (XCeilVal - localPos.x)) / (XCeilVal - XFloorVal));
        float height = Mathf.Lerp(i1, i2, ((ZCeilVal - ZFloorVal) - (ZCeilVal - localPos.z)) / (ZCeilVal - ZFloorVal));
        return new Vector2(height, 0);
    }
    public Vector2 getBoxHeight()
    {
        if (cam_main != null) return getHeight(cam_main.transform.position + cam_main.transform.forward * 0.01f);
        return new Vector2(0, 1);
    }


    public Vector3 getBoundingBox()
    {
        float height = waterDepth;
        return new Vector3((Dimensions - Dimensions * LOD) * transform.lossyScale.x, height, (Dimensions - Dimensions * LOD) * transform.lossyScale.z);
        // return new Vector3(transform.lossyScale.x, height, transform.lossyScale.z);
    }

    //private void OnDrawGizmosSelected()
    //{
    //    Gizmos.color = Color.green;
    //    //Vector3 boxSize = getBoundingBox();
    //    //Vector3 lowerBound = transform.position - new Vector3(LOD, boxSize.y, LOD);
    //    //if (camera != null)
    //    //{
    //    //    Vector2 extraHeight = getHeight(camera.gameObject.transform.position);
    //    //    if (extraHeight.y == 1) { return; }
    //    //    lowerBound += new Vector3(0, extraHeight.x, 0);
    //    //    Gizmos.DrawCube(transform.position + boxSize / 2 - new Vector3(LOD, boxSize.y, LOD) + new Vector3(0, extraHeight.x, 0), boxSize);
    //    //}
    //    //else
    //    //{
    //    //    Debug.LogError("Please assign the camera objecct in inspector for dynamic underwater bounding box");
    //    //}
    //    Vector3 boxSize = getBoundingBox();
    //    Vector3 lowerBound = transform.position - new Vector3(LOD, boxSize.y/2, LOD);
    //    Vector2 extraHeight = getBoxHeight();
    //    if (extraHeight.y == 1) {  return; }
    //    Gizmos.DrawCube(lowerBound + new Vector3(boxSize.x / 2, 0, boxSize.z / 2), boxSize+new Vector3(0, extraHeight.x, 0));
    //}

}
