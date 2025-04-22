#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

public class SkeleSSSGui : ShaderGUI
{
    private Texture2D banner;

    private static readonly string[] modeNames = { "Alpha", "Cutout" };

    // Keyword toggle
    MaterialProperty albedo;
    MaterialProperty scale;
	MaterialProperty opacity = null;
    MaterialProperty alphaCutoff = null;
    MaterialProperty useChromaKey;
    MaterialProperty chromaColor;
    MaterialProperty chromaThreshold;
    MaterialProperty chromaSoftness;
    MaterialProperty useChromaSpill;
    MaterialProperty spillThreshold;
    MaterialProperty spillSoftness;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        banner = EditorGUIUtility.Load("Packages/com.skeletm.screenspaceshaders/Editor/Textures/Tex_ShaderGuiBanner.tga") as Texture2D;

        if (banner != null)
        {
            float bannerAspect = (float)banner.width / banner.height;
            float bannerWidth = EditorGUIUtility.currentViewWidth - 20;
            float bannerHeight = bannerWidth / bannerAspect;
            Rect bannerRect = GUILayoutUtility.GetRect(bannerWidth, bannerHeight, GUILayout.ExpandWidth(true));

            // Tooltip string
            GUIContent bannerContent = new GUIContent("", "View my VRChat Profile!");

            // Show hand cursor
            EditorGUIUtility.AddCursorRect(bannerRect, MouseCursor.Link);

            // Draw clickable button
            if (GUI.Button(bannerRect, bannerContent, GUIStyle.none))
            {
                Application.OpenURL("https://vrchat.com/home/user/usr_bbf66239-5d7b-4873-a7e6-05e23f90b093");
            }

            // Draw the texture
            GUI.DrawTexture(bannerRect, banner, ScaleMode.ScaleToFit);
        }

        EditorGUILayout.Space(10);
        DrawDivider(3f);
        EditorGUILayout.Space(5);

        Material material = materialEditor.target as Material;

        int currentMode = 0;
        if (material.shader.name.Contains("Cutout")){
            currentMode = 1;
            alphaCutoff = FindProperty("_AlphaCutoff", properties);
        }
		else
		{
			opacity = FindProperty("_Opacity", properties);
		}
            

        // Show dropdown
        EditorGUI.BeginChangeCheck();
        int newMode = EditorGUILayout.Popup("Transparency Mode", currentMode, modeNames);
        if (EditorGUI.EndChangeCheck())
        {
            string shaderName = (newMode == 0)
                ? "SkeleTM/Screen Space"
                : "SkeleTM/Screen Space Cutout";

            Shader newShader = Shader.Find(shaderName);
            if (newShader != null)
            {
                material.shader = newShader;
                // Force refresh Material properties if needed
                EditorUtility.SetDirty(material);
            }
            else
            {
                Debug.LogError("Shader not found: " + shaderName);
            }
            return; // Don't draw old properties for the now-different shader
        }

        EditorGUILayout.Space(5);
        DrawDivider();
        EditorGUILayout.Space(5);

        // Load image properties
        albedo = FindProperty("_Albedo", properties);
        scale = FindProperty("_Scale", properties);
        
        // Load chroma properties
        useChromaKey = FindProperty("_UseChromaKey", properties);
        chromaColor = FindProperty("_ChromaColor", properties);
        chromaThreshold = FindProperty("_ChromaThreshold", properties);
        chromaSoftness = FindProperty("_ChromaSoftness", properties);
        
        // Load spill properties
        useChromaSpill = FindProperty("_UseChromaSpill", properties);
        spillThreshold = FindProperty("_SpillThreshold", properties);
        spillSoftness = FindProperty("_SpillSoftness", properties);

        DrawCategory("Image Options", () =>
        {
            materialEditor.ShaderProperty(albedo, "Image Texture");
            materialEditor.ShaderProperty(scale, "Image Scale");
        });
        
        // Check if Chroma Keying is enabled
        bool showChroma = useChromaKey.floatValue > 0.5f;
        // Check if Chroma Spill Reduction is enabled
        bool showSpillReduction = useChromaSpill.floatValue > 0.5f;
        
        DrawCategory("Alpha Options", () =>
        {
            materialEditor.ShaderProperty(useChromaKey, new GUIContent("Chroma Keying", "Use Image Alpha (Disabled), or Chroma Key (Enabled)"));
            if (currentMode == 1 && showChroma == false)
            {
                materialEditor.ShaderProperty(alphaCutoff, new GUIContent("Alpha Cutoff", "Alpha Clipping, leave at 0.5 if using Chroma Key"));
            }
			if (currentMode == 0)
			{
				materialEditor.ShaderProperty(opacity, new GUIContent("Opacity", "General image opacity, 0 being totally transparent."));
			}
        });
        
        //EditorGUILayout.Space(10);
        
        if (showChroma)
        {
            DrawCategory("Chroma Key Options", () =>
            {
                materialEditor.ShaderProperty(chromaColor, "Chroma Color");
                materialEditor.ShaderProperty(chromaThreshold, "Key Threshold");
                materialEditor.ShaderProperty(chromaSoftness, "Key Softness");
                materialEditor.ShaderProperty(useChromaSpill, new GUIContent("Chroma Spill Reduction", "Desaturate edges of image near transparency?"));
            });
            
            if (showSpillReduction)
            {
                DrawCategory("Chroma Spill Options", () =>
                {
                    materialEditor.ShaderProperty(spillThreshold, "Spill Threshold");
                    materialEditor.ShaderProperty(spillSoftness, "Spill Softness");
                });
            }
            
            if (currentMode == 1) material.SetFloat("_AlphaCutoff", 0.5f);
        }

        EditorGUILayout.Space(5);
        DrawDivider(3f);
        EditorGUILayout.Space(10);

        EditorGUILayout.LabelField("Version 1.1", EditorStyles.boldLabel);

    }


    void DrawCategory(string label, System.Action content)
    {
        GUIStyle boxStyle = new GUIStyle(EditorStyles.helpBox);
        GUIStyle labelStyle = new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 11,
            normal = { textColor = Color.white }
        };
        
        EditorGUILayout.BeginVertical(boxStyle);
        EditorGUILayout.LabelField(label, labelStyle);
        EditorGUI.indentLevel++;
        content?.Invoke();
        EditorGUI.indentLevel--;
        EditorGUILayout.EndVertical();
    }

    void DrawDivider(float thickness = 1f, float padding = 10f)
    {
        Rect rect = EditorGUILayout.GetControlRect(false, thickness + padding);
        rect.height = thickness;
        rect.y += padding / 2f;
        rect.x -= 2; // Optional: shift slightly to span edge-to-edge
        rect.width += 6;

        EditorGUI.DrawRect(rect, new Color(0.2f, 0.2f, 0.2f, 1f)); // dark gray line
    }
}
#endif