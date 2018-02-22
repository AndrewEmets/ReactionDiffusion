using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReactionDiffustionUpdater : MonoBehaviour
{
    [Serializable] 
    public struct UpdatePrefs
    {
        public float feed, kill, da, db;
    }

    [SerializeField] private Material updateMaterial;
    [SerializeField] private RenderTexture targetTexture;
    //[SerializeField] private Material renderMaterial;
    [SerializeField] private Texture2D initialTexture;
    [SerializeField] private int updatesPerFrame = 1;

    public int PrefsCount
    {
        get
        {
            return prefs.Count;
        }
    }

    private event Action<int, UpdatePrefs> currentPrefsChanged;
    public event Action<int, UpdatePrefs> CurrentPrefsChanged
    {
        add
        {
            if (value == null)
                return;

            currentPrefsChanged += value;            
            value.Invoke( currentPrefs, prefs[currentPrefs]);
        }
        remove
        {
            currentPrefsChanged -= value;
        }
    }

    private int repeat(int a, int b)
    {
        return (a % b + b) % b;
    }

    [SerializeField] private int currentPrefs;
    public int CurrentPrefs
    {
        get { return currentPrefs; }
        set
        {
            if (currentPrefs != value)
            {
                currentPrefs = repeat(value, prefs.Count);

                if (currentPrefsChanged != null)
                    currentPrefsChanged.Invoke(currentPrefs, prefs[currentPrefs]);
            }
        }
    }    

    [SerializeField] private List<UpdatePrefs> prefs;

    private RenderTexture temp;

    private void Start()
    {           
        temp = new RenderTexture(targetTexture);
        //GetComponent<Renderer>().sharedMaterial = renderMaterial;

        BlitInitTexture();

        CurrentPrefsChanged += ReactionDiffustionUpdater_CurrentPrefsChanged;
    }

    private void ReactionDiffustionUpdater_CurrentPrefsChanged(int currentIndex, UpdatePrefs prefs)
    {
        UpdateValues();
    }

    [ContextMenu("Blit init texture")]
    public void BlitInitTexture()
    {
        Graphics.Blit(initialTexture, targetTexture);
    }

    private void OnValidate()
    {
        UpdateValues();
    }

    private void UpdateValues()
    {
        currentPrefs = Mathf.Clamp(currentPrefs, 0, prefs.Count - 1);
        var pref = prefs[currentPrefs];
        updateMaterial.SetFloat("_F", pref.feed);
        updateMaterial.SetFloat("_K", pref.kill);
        updateMaterial.SetFloat("_Da", pref.da);
        updateMaterial.SetFloat("_Db", pref.db);
    }

    private void Update()
    {
        RenderTexture t1 = targetTexture;
        RenderTexture t2 = temp;

        for (int i = 0; i < updatesPerFrame; i++)
        {
            Graphics.Blit(t1, t2, updateMaterial);

            var t3 = t1;
            t1 = t2;
            t2 = t3;
        }

        if (updatesPerFrame % 2 == 1)
        {            
            Graphics.Blit(temp, targetTexture);
        }

        //HandleInput();
    }

    private void HandleInput()
    {
        if (Input.GetMouseButtonDown(0))
        {
            if (!Input.GetMouseButton(0))
                return;

            RaycastHit hit;
            if (!Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hit))
                return;

            Renderer rend = hit.transform.GetComponent<Renderer>();
            MeshCollider meshCollider = hit.collider as MeshCollider;

            if (rend == null || rend.sharedMaterial == null || rend.sharedMaterial.mainTexture == null || meshCollider == null)
                return;

            var tex = rend.material.mainTexture as RenderTexture;
            Vector2 pixelUV = hit.textureCoord;
            pixelUV.x *= tex.width;
            pixelUV.y *= tex.height;

            /*tex.SetPixel((int)pixelUV.x, (int)pixelUV.y, Color.black);
            tex.Apply();*/
        }
    }
}
