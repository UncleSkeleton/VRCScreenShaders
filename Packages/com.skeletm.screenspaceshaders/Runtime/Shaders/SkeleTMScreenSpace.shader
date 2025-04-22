Shader "SkeleTM/Screen Space"
{
    Properties
    {
        [NoScaleOffset]_Albedo("Image", 2D) = "grey" {}
        _Scale("Scale", Float) = 1
        _Opacity("Opacity", Range(0, 1)) = 1
        [ToggleUI]_UseChromaKey("UseChromaKey", Float) = 0
        _ChromaColor("ChromaColor", Color) = (0, 1, 0, 1)
        _ChromaThreshold("ChromaThreshold", Range(0, 1)) = 0.05
        _ChromaSoftness("ChromaSoftness", Range(0, 1)) = 0.02
        [ToggleUI]_UseChromaSpill("UseChromaSpill", Float) = 0
        _SpillThreshold("SpillThreshold", Float) = 0.08
        _SpillSoftness("SpillSoftness", Range(0, 1)) = 0.02
        [HideInInspector]_QueueOffset("Float", Float) = 0
        [HideInInspector]_QueueControl("Float", Float) = -1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType"="Transparent"
            "BuiltInMaterialType" = "Unlit"
            "VRCFallback" = "HiddenCutout"
            "Queue"="Overlay+1"
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="BuiltInUnlitSubTarget"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                "LightMode" = "ForwardBase"
            }
        
        // Render State
        Cull Front
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest Always
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        #define PIPELINE_BUILTIN
        #define GENERATION_GRAPH
        
        // Pragmas
        #pragma target 4.5
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag
        
        /* WARNING: $splice Could not find named fragment 'DotsInstancingOptions' */
        /* WARNING: $splice Could not find named fragment 'HybridV1InjectedBuiltinProperties' */
        
        // GraphKeywords: <None>
        
        // Keywords
        #define SHADERPASS SHADERPASS_UNLIT
        
        #define _SURFACE_TYPE_TRANSPARENT 1
        // PassKeywords: <None>
        
        // Defines
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/io.z3y.github.shadergraph/ShaderLibrary/ShaderPass.hlsl"
        #include "Packages/io.z3y.github.shadergraph/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
             float fogCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
             float fogCoord : INTERP0;
            #endif
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
            output.fogCoord = input.fogCoord;
            #endif
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
            output.fogCoord = input.fogCoord;
            #endif
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        #include "Packages/io.z3y.github.shadergraph/ShaderLibrary/Structs.hlsl"
        // splice(PreGraph)
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Albedo_TexelSize;
        half _Scale;
        half _ChromaThreshold;
        half _ChromaSoftness;
        half4 _ChromaColor;
        half _UseChromaKey;
        half _UseChromaSpill;
        half _SpillThreshold;
        half _SpillSoftness;
        half _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Subtract_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_half3(half3 In, out half3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Add_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Negate_half(half In, out half Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Divide_half(half A, half B, out half Out)
        {
            Out = A / B;
        }
        
        void Unity_Combine_half(half R, half G, half B, half A, out half4 RGBA, out half3 RGB, out half2 RG)
        {
            RGBA = half4(R, G, B, A);
            RGB = half3(R, G, B);
            RG = half2(R, G);
        }
        
        void Unity_Divide_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_half2(half2 A, half2 B, out half2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_ColorMask_half(half3 In, half3 MaskColor, half Range, out half Out, half Fuzziness)
        {
            half Distance = distance(MaskColor, In);
            Out = saturate(1 - (Distance - Range) / max(Fuzziness, 1e-5));
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturation_half(half3 In, half Saturation, out half3 Out)
        {
            half luma = dot(In, half3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        void Unity_Branch_half3(half Predicate, half3 True, half3 False, out half3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Distance_half3(half3 A, half3 B, out half Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Multiply_half3_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Less_half(half A, half B, out half Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_half(half Predicate, half True, half False, out half Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            half Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _Property_601084739d1949b298bb215b55de83e6_Out_0_Boolean = _UseChromaSpill;
            UnityTexture2D _Property_d9368d62a11b4dc7940333316f3a5926_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Albedo);
            half3 _Subtract_be2f3f5cdb744600b473ffd1c0789cc6_Out_2_Vector3;
            Unity_Subtract_half3(_WorldSpaceCameraPos, IN.WorldSpacePosition, _Subtract_be2f3f5cdb744600b473ffd1c0789cc6_Out_2_Vector3);
            half3 _Normalize_df5257b13fe149e6890d4036904fc80c_Out_1_Vector3;
            Unity_Normalize_half3(_Subtract_be2f3f5cdb744600b473ffd1c0789cc6_Out_2_Vector3, _Normalize_df5257b13fe149e6890d4036904fc80c_Out_1_Vector3);
            half3 _Add_186042e2844e43e080c5b4c5c9e64595_Out_2_Vector3;
            Unity_Add_half3(_Normalize_df5257b13fe149e6890d4036904fc80c_Out_1_Vector3, _WorldSpaceCameraPos, _Add_186042e2844e43e080c5b4c5c9e64595_Out_2_Vector3);
            half3 _Transform_b957f7f4f5a943cc980de8a5fb35949d_Out_1_Vector3;
            _Transform_b957f7f4f5a943cc980de8a5fb35949d_Out_1_Vector3 = TransformWorldToView(_Add_186042e2844e43e080c5b4c5c9e64595_Out_2_Vector3.xyz);
            half _Split_405e4cdad52749e8aaa1dd0a9cc66597_R_1_Float = _Transform_b957f7f4f5a943cc980de8a5fb35949d_Out_1_Vector3[0];
            half _Split_405e4cdad52749e8aaa1dd0a9cc66597_G_2_Float = _Transform_b957f7f4f5a943cc980de8a5fb35949d_Out_1_Vector3[1];
            half _Split_405e4cdad52749e8aaa1dd0a9cc66597_B_3_Float = _Transform_b957f7f4f5a943cc980de8a5fb35949d_Out_1_Vector3[2];
            half _Split_405e4cdad52749e8aaa1dd0a9cc66597_A_4_Float = 0;
            half _Negate_70c2865fc30948a4afdc7faea8d84b9e_Out_1_Float;
            Unity_Negate_half(_Split_405e4cdad52749e8aaa1dd0a9cc66597_R_1_Float, _Negate_70c2865fc30948a4afdc7faea8d84b9e_Out_1_Float);
            half _Divide_db86931332b54d3f9e45bfb081824a0b_Out_2_Float;
            Unity_Divide_half(_Negate_70c2865fc30948a4afdc7faea8d84b9e_Out_1_Float, _Split_405e4cdad52749e8aaa1dd0a9cc66597_B_3_Float, _Divide_db86931332b54d3f9e45bfb081824a0b_Out_2_Float);
            half _Negate_43973311fc8642fba03935e0b258a1be_Out_1_Float;
            Unity_Negate_half(_Split_405e4cdad52749e8aaa1dd0a9cc66597_G_2_Float, _Negate_43973311fc8642fba03935e0b258a1be_Out_1_Float);
            half _Divide_9b70a44a5d2c41009edb042634027c78_Out_2_Float;
            Unity_Divide_half(_Negate_43973311fc8642fba03935e0b258a1be_Out_1_Float, _Split_405e4cdad52749e8aaa1dd0a9cc66597_B_3_Float, _Divide_9b70a44a5d2c41009edb042634027c78_Out_2_Float);
            half4 _Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RGBA_4_Vector4;
            half3 _Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RGB_5_Vector3;
            half2 _Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RG_6_Vector2;
            Unity_Combine_half(_Divide_db86931332b54d3f9e45bfb081824a0b_Out_2_Float, _Divide_9b70a44a5d2c41009edb042634027c78_Out_2_Float, 0, 0, _Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RGBA_4_Vector4, _Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RGB_5_Vector3, _Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RG_6_Vector2);
            half _Property_bb50aed84cec4aefa9e3cdec89367db3_Out_0_Float = _Scale;
            half4 _Divide_410fae9cd6614d0aa4e77f8c2b199149_Out_2_Vector4;
            Unity_Divide_half4(_Combine_7dce2ffdd6644f2f9f623584e08bd8dd_RGBA_4_Vector4, (_Property_bb50aed84cec4aefa9e3cdec89367db3_Out_0_Float.xxxx), _Divide_410fae9cd6614d0aa4e77f8c2b199149_Out_2_Vector4);
            half2 _Vector2_db96c5e599a24a27ad89730ddd5e83e6_Out_0_Vector2 = half2(0.5, 0.5);
            half2 _Add_b510e1364c944e54bbfa49a4f9a47843_Out_2_Vector2;
            Unity_Add_half2((_Divide_410fae9cd6614d0aa4e77f8c2b199149_Out_2_Vector4.xy), _Vector2_db96c5e599a24a27ad89730ddd5e83e6_Out_0_Vector2, _Add_b510e1364c944e54bbfa49a4f9a47843_Out_2_Vector2);
            half4 _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d9368d62a11b4dc7940333316f3a5926_Out_0_Texture2D.tex, _Property_d9368d62a11b4dc7940333316f3a5926_Out_0_Texture2D.samplerstate, _Property_d9368d62a11b4dc7940333316f3a5926_Out_0_Texture2D.GetTransformedUV(_Add_b510e1364c944e54bbfa49a4f9a47843_Out_2_Vector2) );
            half _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_R_4_Float = _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.r;
            half _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_G_5_Float = _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.g;
            half _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_B_6_Float = _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.b;
            half _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_A_7_Float = _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.a;
            half4 _Property_60346b917bc44941ab411316a2fb2337_Out_0_Vector4 = _ChromaColor;
            half _Property_2f86dafe68114299bebb244547ab557c_Out_0_Float = _ChromaThreshold;
            half _Property_8f3990a9b0974e7a891338e6957084b7_Out_0_Float = _SpillThreshold;
            half _Add_8ed84ef52b1342aa8d1df3bc0e46144e_Out_2_Float;
            Unity_Add_half(_Property_2f86dafe68114299bebb244547ab557c_Out_0_Float, _Property_8f3990a9b0974e7a891338e6957084b7_Out_0_Float, _Add_8ed84ef52b1342aa8d1df3bc0e46144e_Out_2_Float);
            half _Property_49d934274aa445ce8cfc4f537bd5dc07_Out_0_Float = _ChromaSoftness;
            half _Property_cf09dc780848443489944cd838fa8a3e_Out_0_Float = _SpillSoftness;
            half _Add_19e5a6aa3adf484e9af18fa1fe1d68bb_Out_2_Float;
            Unity_Add_half(_Property_49d934274aa445ce8cfc4f537bd5dc07_Out_0_Float, _Property_cf09dc780848443489944cd838fa8a3e_Out_0_Float, _Add_19e5a6aa3adf484e9af18fa1fe1d68bb_Out_2_Float);
            half _ColorMask_48f9a82d8c1640698eb65e4a359bd51d_Out_3_Float;
            Unity_ColorMask_half((_SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.xyz), (_Property_60346b917bc44941ab411316a2fb2337_Out_0_Vector4.xyz), _Add_8ed84ef52b1342aa8d1df3bc0e46144e_Out_2_Float, _ColorMask_48f9a82d8c1640698eb65e4a359bd51d_Out_3_Float, _Add_19e5a6aa3adf484e9af18fa1fe1d68bb_Out_2_Float);
            half _OneMinus_4036b3b374b44ccaacdf4ce9d4ad08bf_Out_1_Float;
            Unity_OneMinus_half(_ColorMask_48f9a82d8c1640698eb65e4a359bd51d_Out_3_Float, _OneMinus_4036b3b374b44ccaacdf4ce9d4ad08bf_Out_1_Float);
            half3 _Saturation_b255678ffbb74b119d29ccb11abadf7b_Out_2_Vector3;
            Unity_Saturation_half((_SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.xyz), _OneMinus_4036b3b374b44ccaacdf4ce9d4ad08bf_Out_1_Float, _Saturation_b255678ffbb74b119d29ccb11abadf7b_Out_2_Vector3);
            half3 _Branch_55a65298e6d348649f28bb04bf9f5722_Out_3_Vector3;
            Unity_Branch_half3(_Property_601084739d1949b298bb215b55de83e6_Out_0_Boolean, _Saturation_b255678ffbb74b119d29ccb11abadf7b_Out_2_Vector3, (_SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.xyz), _Branch_55a65298e6d348649f28bb04bf9f5722_Out_3_Vector3);
            half _Distance_354bb131aa494f7eaac603b4bea08668_Out_2_Float;
            Unity_Distance_half3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_354bb131aa494f7eaac603b4bea08668_Out_2_Float);
            half _Float_ad42117165024ebc8ad357103183e346_Out_0_Float = 0.5;
            half3 _Multiply_f4c93db6b1a145209047833231046e67_Out_2_Vector3;
            Unity_Multiply_half3_half3((_Float_ad42117165024ebc8ad357103183e346_Out_0_Float.xxx), half3(length(half3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                     length(half3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                     length(half3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_f4c93db6b1a145209047833231046e67_Out_2_Vector3);
            half _Comparison_7fd820714d8948b89c41bfc7e273819f_Out_2_Boolean;
            Unity_Comparison_Less_half(_Distance_354bb131aa494f7eaac603b4bea08668_Out_2_Float, (_Multiply_f4c93db6b1a145209047833231046e67_Out_2_Vector3).x, _Comparison_7fd820714d8948b89c41bfc7e273819f_Out_2_Boolean);
            half _Property_a22800a7faf145b7a16ccbd830867967_Out_0_Boolean = _UseChromaKey;
            half _Property_e0180462a07a4faaba286fa484cfcac2_Out_0_Float = _ChromaThreshold;
            half _Property_63be73b6b0ec472cbb9cf5c707ca2add_Out_0_Float = _ChromaSoftness;
            half _ColorMask_29a21b569ee443ccb57efbcd31d5438b_Out_3_Float;
            Unity_ColorMask_half((_SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_RGBA_0_Vector4.xyz), (_Property_60346b917bc44941ab411316a2fb2337_Out_0_Vector4.xyz), _Property_e0180462a07a4faaba286fa484cfcac2_Out_0_Float, _ColorMask_29a21b569ee443ccb57efbcd31d5438b_Out_3_Float, _Property_63be73b6b0ec472cbb9cf5c707ca2add_Out_0_Float);
            half _OneMinus_c8b0f14a9fb5439290b04e201928e0a2_Out_1_Float;
            Unity_OneMinus_half(_ColorMask_29a21b569ee443ccb57efbcd31d5438b_Out_3_Float, _OneMinus_c8b0f14a9fb5439290b04e201928e0a2_Out_1_Float);
            half _Branch_736c9b8418234e3198e4cee5146cd2b4_Out_3_Float;
            Unity_Branch_half(_Property_a22800a7faf145b7a16ccbd830867967_Out_0_Boolean, _OneMinus_c8b0f14a9fb5439290b04e201928e0a2_Out_1_Float, _SampleTexture2D_e367d48155c04ca8a3cd649fc87061b4_A_7_Float, _Branch_736c9b8418234e3198e4cee5146cd2b4_Out_3_Float);
            half _Branch_a016c9fd75554d2296602eec7a0a07f8_Out_3_Float;
            Unity_Branch_half(_Comparison_7fd820714d8948b89c41bfc7e273819f_Out_2_Boolean, _Branch_736c9b8418234e3198e4cee5146cd2b4_Out_3_Float, 0, _Branch_a016c9fd75554d2296602eec7a0a07f8_Out_3_Float);
            half _Property_6d53c7bcf604406fa2a01bd4a6dad418_Out_0_Float = _Opacity;
            half _Multiply_25b60f02cb0f41fcbe283e797445d7a2_Out_2_Float;
            Unity_Multiply_half_half(_Branch_a016c9fd75554d2296602eec7a0a07f8_Out_3_Float, _Property_6d53c7bcf604406fa2a01bd4a6dad418_Out_0_Float, _Multiply_25b60f02cb0f41fcbe283e797445d7a2_Out_2_Float);
            surface.BaseColor = _Branch_55a65298e6d348649f28bb04bf9f5722_Out_3_Vector3;
            surface.Alpha = _Multiply_25b60f02cb0f41fcbe283e797445d7a2_Out_2_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
            
            #ifdef VARYINGS_NEED_POSITION_WS
                float4 positionCS = TransformWorldToHClip(input.positionWS);
                float4 screenPos = ComputeGrabScreenPos(positionCS);
                screenPos.xy /= screenPos.w;
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/io.z3y.github.shadergraph/ShaderLibrary/Vertex.hlsl"
        #include "Packages/io.z3y.github.shadergraph/ShaderLibrary/FragmentUnlit.hlsl"
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "SkeleSSSGui" ""
    FallBack "Hidden/Shader Graph/FallbackError"
}