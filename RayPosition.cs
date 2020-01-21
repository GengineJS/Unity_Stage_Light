using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayPosition : MonoBehaviour
{
    private Camera mainCamera;
    private Ray ray;
    private RaycastHit hit;
    private Vector3 mousePos, hitPosition;
    public float radius = 11;
    public float softness = 4;
    public float moveSpeed = 15;
    // Start is called before the first frame update
    void Start()
    {
        mainCamera = this.GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        mousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0);
        ray = mainCamera.ScreenPointToRay(mousePos);
        if (Physics.Raycast(ray, out hit)) {
            hitPosition = Vector3.MoveTowards(hitPosition, hit.point, moveSpeed * Time.deltaTime);
            Shader.SetGlobalVector("_Position", new Vector4(hitPosition.x, hitPosition.y, hitPosition.z, 1));
        }
        Shader.SetGlobalFloat("_Radius", this.radius);
        Shader.SetGlobalFloat("_Softness", this.softness);
    }
}
