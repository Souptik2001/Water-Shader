using UnityEngine;
using System.Collections;

public class CamScreenSplit : MonoBehaviour {
	public float split;
	
	Camera topCam;
	

	void Start () {
		Transform topTrans = transform.Find("WaterCam");
		topCam = (Camera) topTrans.gameObject.GetComponent("Camera");
	}
	

	void Update () {
		split = Mathf.Clamp01(split);
		SetSplitPoint(split);
	}
	
	
	void SetSplitPoint(float sp) {
		float halfHeight = Mathf.Tan(GetComponent<Camera>().fieldOfView * Mathf.Deg2Rad * .5f) * GetComponent<Camera>().nearClipPlane;
		float upperTop = halfHeight;
		float upperBottom = (split - .5f) * halfHeight * 2f;
		float lowerTop = upperBottom;
		float lowerBottom = -halfHeight;
		
		Matrix4x4 upperMat = topCam.projectionMatrix;
		upperMat[1, 1] = (2f * GetComponent<Camera>().nearClipPlane) / (upperTop - upperBottom);
		upperMat[1, 2] = (upperTop + upperBottom) / (upperTop - upperBottom);
		topCam.projectionMatrix = upperMat;
		
		Matrix4x4 lowerMat = GetComponent<Camera>().projectionMatrix;
		lowerMat[1, 1] = (2f * GetComponent<Camera>().nearClipPlane) / (lowerTop - lowerBottom);
		lowerMat[1, 2] = (lowerTop + lowerBottom) / (lowerTop - lowerBottom);
		GetComponent<Camera>().projectionMatrix = lowerMat;
		
		Rect botCamRect = GetComponent<Camera>().rect;
		botCamRect.height = split;
		GetComponent<Camera>().rect = botCamRect;
		
		Rect topCamRect = topCam.rect;
		topCamRect.height = 1f - split;
		topCamRect.y = split;
		topCam.rect = topCamRect;
	}
}
