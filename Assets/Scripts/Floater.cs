using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Floater : MonoBehaviour
{

    Rigidbody rb;
    public float underwaterDrag = 1;
    public float underwaterAngularDrag = 0.5f;
    public float depthBeforeSubmerged = 1f;
    public float displacementAmount = 3f;
    int floatersCount;
    public Transform[] floaters;


    void Start()
    {
        floatersCount = floaters.Length;
        rb = GetComponent<Rigidbody>();
        if(rb) rb.useGravity = false;
    }

    void FixedUpdate()
    {
        //if(Physics.SphereCast(transform.position, ))
        //if(transform.position.y < waterHeightAtThisPoint)
        //{
        //    float displacementMultiplier = Mathf.Clamp01(-transform.position.y / depthBeforeSubmerged) * displacementAmount;
        //    rb.AddForce(new Vector3(0f, Mathf.Abs(Physics.gravity.y) * displacementMultiplier, 0f), ForceMode.Acceleration);
        //}
        if (rb)
        {

            for(int i=0; i<floatersCount; i++)
            {
                Transform thisFloater = floaters[i];
                rb.AddForceAtPosition(Physics.gravity / floatersCount, thisFloater.position, ForceMode.Acceleration); // Gravity
                // float waveHeight = WavesManager.instance.getHeight(0, transform.position);
                Vector3 waveHeight = WavesManager.instance.getHeight(0, thisFloater.position);
                Vector2 waveSpeed = WavesManager.instance.waveSpeed(0);
                if (thisFloater.position.y < waveHeight.y)
                {
                    float displacementMultiplier = Mathf.Clamp01((waveHeight.y - thisFloater.position.y) / depthBeforeSubmerged) * displacementAmount;
                    Vector3 objToWave = waveHeight - thisFloater.position;
                    float xForce = waveSpeed.x;
                    float zForce = waveSpeed.y;
                    rb.AddForceAtPosition(new Vector3(xForce, Mathf.Abs(Physics.gravity.y) * displacementMultiplier, zForce), thisFloater.position, ForceMode.Acceleration);
                    rb.AddForce(displacementMultiplier * -rb.velocity * underwaterDrag * Time.fixedDeltaTime, ForceMode.VelocityChange);
                    rb.AddTorque(displacementMultiplier * -rb.velocity * underwaterAngularDrag * Time.fixedDeltaTime, ForceMode.VelocityChange);
                }

            }
        }
    }
}
