using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrossTest : MonoBehaviour
{
    public Transform a;
    public float aLength;
    public Transform b;
    public float bLength;
    public Transform cross;
    void Start()
    {   
    }

    // Update is called once per frame
    void Update()
    {
        a.localScale = new Vector3(1, 1, aLength);
        a.position = a.forward * (aLength/2);
        b.localScale = new Vector3(1, 1, bLength);
        b.position = b.forward * (bLength / 2);
        Vector3 resultant = Vector3.Cross(a.forward * aLength, b.forward * bLength);
        cross.forward = resultant.normalized;
        cross.localScale = new Vector3(1, 1, resultant.magnitude);
        cross.position = cross.forward * (resultant.magnitude/2);
    }
}
