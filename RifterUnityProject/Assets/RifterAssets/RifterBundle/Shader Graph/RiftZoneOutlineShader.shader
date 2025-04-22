// Upgrade NOTE: upgraded instancing buffer 'CustomRiftZoneOutlineShader' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/RiftZoneOutlineShader"
{
	Properties
	{
		_Power("Power", Float) = 1
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		GrabPass{ }
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.0
		#pragma multi_compile_instancing
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float4 screenPos;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;

		UNITY_INSTANCING_BUFFER_START(CustomRiftZoneOutlineShader)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color0)
#define _Color0_arr CustomRiftZoneOutlineShader
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr CustomRiftZoneOutlineShader
			UNITY_DEFINE_INSTANCED_PROP(float, _Power)
#define _Power_arr CustomRiftZoneOutlineShader
		UNITY_INSTANCING_BUFFER_END(CustomRiftZoneOutlineShader)


inline float4 ASE_ComputeGrabScreenPos( float4 pos )
{
	#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
	#else
	float scale = 1.0;
	#endif
	float4 o = pos;
	o.y = pos.w * 0.5f;
	o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
	return o;
}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 HSLtoRGB( float3 HSL, float3 RGB )
		{
			//float3 HSLtoRGB(in float3 HSL)
			  {
			   // float3 RGB = HUEtoRGB(HSL.x);
			    float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
			    return (RGB - 0.5) * C + HSL.z;
			  }
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 _Color0_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color0_arr, _Color0);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor6 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
			float _contrast_Instance = UNITY_ACCESS_INSTANCED_PROP(_contrast_arr, _contrast);
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor16_g2426 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 temp_output_2_0_g2429 = screenColor16_g2426;
			float3 temp_output_32_0_g2428 = (temp_output_2_0_g2429).rgb;
			float3 hsvTorgb39_g2428 = RGBToHSV( temp_output_32_0_g2428 );
			float3 break33_g2428 = temp_output_32_0_g2428;
			float dotResult30_g2428 = dot( temp_output_32_0_g2428 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g2428 = (float3(hsvTorgb39_g2428.x , ( max( break33_g2428.x , max( break33_g2428.y , break33_g2428.z ) ) - min( break33_g2428.x , min( break33_g2428.y , break33_g2428.z ) ) ) , dotResult30_g2428));
			float3 break565_g2426 = appendResult40_g2428;
			float4 temp_output_2_0_g2431 = ( 1.0 - screenColor16_g2426 );
			float3 temp_output_32_0_g2430 = (temp_output_2_0_g2431).rgb;
			float3 hsvTorgb39_g2430 = RGBToHSV( temp_output_32_0_g2430 );
			float3 break33_g2430 = temp_output_32_0_g2430;
			float dotResult30_g2430 = dot( temp_output_32_0_g2430 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g2430 = (float3(hsvTorgb39_g2430.x , ( max( break33_g2430.x , max( break33_g2430.y , break33_g2430.z ) ) - min( break33_g2430.x , min( break33_g2430.y , break33_g2430.z ) ) ) , dotResult30_g2430));
			float3 appendResult567_g2426 = (float3(break565_g2426.x , break565_g2426.y , appendResult40_g2430.z));
			float3 HSL564_g2426 = appendResult567_g2426;
			float3 hsvTorgb3_g2427 = HSVToRGB( float3(break565_g2426.x,1.0,1.0) );
			float3 RGB564_g2426 = hsvTorgb3_g2427;
			float3 localHSLtoRGB564_g2426 = HSLtoRGB( HSL564_g2426 , RGB564_g2426 );
			float4 appendResult550_g2426 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2426 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2426 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2426 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g2426 = appendResult550_g2426;
			float4 blendOpDest596_g2426 = ( 1.0 - _Near );
			float4 blendOpSrc595_g2426 = appendResult550_g2426;
			float4 blendOpDest595_g2426 = ( 1.0 - _Far );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g2426 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g2426 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g2426 = clamp( ( ( eyeDepth185_g2426 - distance( unityObjectToViewPos184_g2426 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g2426 = lerp( ( saturate( (( blendOpDest596_g2426 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g2426 ) * ( 1.0 - blendOpSrc596_g2426 ) ) : ( 2.0 * blendOpDest596_g2426 * blendOpSrc596_g2426 ) ) )) , ( saturate( (( blendOpDest595_g2426 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g2426 ) * ( 1.0 - blendOpSrc595_g2426 ) ) : ( 2.0 * blendOpDest595_g2426 * blendOpSrc595_g2426 ) ) )) , pow( clampResult190_g2426 , _TransitionFalloff ));
			float eyeDepth2 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float _Power_Instance = UNITY_ACCESS_INSTANCED_PROP(_Power_arr, _Power);
			float4 lerpResult14 = lerp( screenColor6 , ( 1.0 - lerpResult627_g2426 ) , pow( saturate( ( 1.0 - ( eyeDepth2 - ase_screenPos.w ) ) ) , _Power_Instance ));
			o.Emission = ( _Color0_Instance * lerpResult14 ).rgb;
			o.Alpha = lerpResult14.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.ScreenPosInputsNode;1;-1712.482,151.4502;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;2;-1728.482,55.45016;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;3;-1488.482,135.4502;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;4;-1344.482,135.4502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;9;-1584.482,503.4502;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;5;-1200.482,135.4502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;10;-1328.482,503.4502;Inherit;False;Pseudo Infrared Depth Filter;2;;2426;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.RangedFloatNode;11;-1248.482,375.4502;Inherit;False;InstancedProperty;_Power;Power;0;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;6;-1024.482,87.45016;Inherit;False;Global;_GrabScreen0;Grab Screen 0;7;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;12;-992.4824,503.4502;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;13;-1040.482,343.4502;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-800.4824,311.4502;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;21;-816,-112;Inherit;False;InstancedProperty;_Color0;Color 0;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1.592157,1.184314,1.709804,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-1472.482,743.4502;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;16;-1216.482,791.4502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-976.4824,679.4502;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-704.4824,615.4502;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;-489.5051,476.4047;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-497.131,80.71326;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-208,144;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Custom/RiftZoneOutlineShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;2;0
WireConnection;3;1;1;4
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;10;628;9;0
WireConnection;12;0;10;78
WireConnection;13;0;5;0
WireConnection;13;1;11;0
WireConnection;14;0;6;0
WireConnection;14;1;12;0
WireConnection;14;2;13;0
WireConnection;16;0;15;2
WireConnection;17;0;16;0
WireConnection;17;2;16;0
WireConnection;18;0;17;0
WireConnection;19;0;18;0
WireConnection;22;0;21;0
WireConnection;22;1;14;0
WireConnection;0;2;22;0
WireConnection;0;9;14;0
ASEEND*/
//CHKSM=583490D34855BB65B71B92DC64B01228A5D46DF5