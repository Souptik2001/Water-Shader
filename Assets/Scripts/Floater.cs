using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Floater : MonoBehaviour
{

    public Rigidbody rb;
    public float underwaterDrag = 1;
    public float underwaterAngularDrag = 0.5f;
    public float depthBeforeSubmerged = 1f;
    public float displacementAmount = 3f;
    public int floaters;


    void Start()
    {
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
            rb.AddForceAtPosition(Physics.gravity / floaters, transform.position, ForceMode.Acceleration);
            float waveHeight = WavesManager.instance.getHeight(0, transform.position);
            if (transform.position.y < waveHeight)
            {
                rb.drag = Mathf.Lerp(rb.drag, underwaterDrag, 0.85f);
                float displacementMultiplier = Mathf.Clamp01((waveHeight - transform.position.y) / depthBeforeSubmerged) * displacementAmount;
                rb.AddForceAtPosition(new Vector3(0f, Mathf.Abs(Physics.gravity.y) * displacementMultiplier, 0f), transform.position, ForceMode.Acceleration);
                rb.AddForce(displacementMultiplier * -rb.velocity * underwaterDrag * Time.fixedDeltaTime, ForceMode.VelocityChange);
                rb.AddTorque(displacementMultiplier * -rb.velocity * underwaterAngularDrag * Time.fixedDeltaTime, ForceMode.VelocityChange);
            }
        }
    }
}
