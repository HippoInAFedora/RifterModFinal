// Upgrade NOTE: upgraded instancing buffer 'riftedHeadShader' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "riftedHeadShader"
{
	Properties
	{
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		_Speed("Speed", Range( -0.1 , 0)) = 0
		_Texture0("Texture 0", 2D) = "white" {}
		_FresnelPower("Fresnel Power", Range( 0 , 1)) = 0
		_FresnelScale("Fresnel Scale", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			float4 screenPos;
		};

		uniform sampler2D _Texture0;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _Speed;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;

		UNITY_INSTANCING_BUFFER_START(riftedHeadShader)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Texture0_ST)
#define _Texture0_ST_arr riftedHeadShader
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr riftedHeadShader
		UNITY_INSTANCING_BUFFER_END(riftedHeadShader)


float2 voronoihash11( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi11( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
{
	float2 n = floor( v );
	float2 f = frac( v );
	float F1 = 8.0;
	float F2 = 8.0; float2 mg = 0;
	for ( int j = -1; j <= 1; j++ )
	{
		for ( int i = -1; i <= 1; i++ )
	 	{
	 		float2 g = float2( i, j );
	 		float2 o = voronoihash11( n + g );
			o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
			float d = 0.5 * dot( r, r );
	 		if( d<F1 ) {
	 			F2 = F1;
	 			F1 = d; mg = g; mr = r; id = o;
	 		} else if( d<F2 ) {
	 			F2 = d;
	
	 		}
	 	}
	}
	return F1;
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

float2 voronoihash10( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi10( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
{
	float2 n = floor( v );
	float2 f = frac( v );
	float F1 = 8.0;
	float F2 = 8.0; float2 mg = 0;
	for ( int j = -3; j <= 3; j++ )
	{
		for ( int i = -3; i <= 3; i++ )
	 	{
	 		float2 g = float2( i, j );
	 		float2 o = voronoihash10( n + g );
			o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
			float d = 0.5 * dot( r, r );
	 		if( d<F1 ) {
	 			F2 = F1;
	 			F1 = d; mg = g; mr = r; id = o;
	 		} else if( d<F2 ) {
	 			F2 = d;
	
	 		}
	 	}
	}
	return F2 - F1;
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

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 _Texture0_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_Texture0_ST_arr, _Texture0_ST);
			float2 uv_Texture0 = i.uv_texcoord * _Texture0_ST_Instance.xy + _Texture0_ST_Instance.zw;
			o.Albedo = tex2D( _Texture0, uv_Texture0 ).rgb;
			float mulTime1 = _Time.y * 5.0;
			float time11 = mulTime1;
			float2 voronoiSmoothId11 = 0;
			float2 coords11 = i.uv_texcoord * 50.0;
			float2 id11 = 0;
			float2 uv11 = 0;
			float voroi11 = voronoi11( coords11, time11, id11, uv11, 0, voronoiSmoothId11 );
			float grayscale17 = Luminance(float3( id11 ,  0.0 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV13 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode13 = ( 0.0 + 0.01 * pow( max( 1.0 - fresnelNdotV13 , 0.0001 ), -1.6 ) );
			float clampResult18 = clamp( fresnelNode13 , 0.0 , 1.0 );
			float3 temp_output_1_0_g2432 = float3( id11 ,  0.0 );
			float3 temp_output_2_0_g2432 = ddx( temp_output_1_0_g2432 );
			float dotResult4_g2432 = dot( temp_output_2_0_g2432 , temp_output_2_0_g2432 );
			float3 temp_output_3_0_g2432 = ddy( temp_output_1_0_g2432 );
			float dotResult5_g2432 = dot( temp_output_3_0_g2432 , temp_output_3_0_g2432 );
			float ifLocalVar6_g2432 = 0;
			if( dotResult4_g2432 <= dotResult5_g2432 )
				ifLocalVar6_g2432 = dotResult5_g2432;
			else
				ifLocalVar6_g2432 = dotResult4_g2432;
			float temp_output_16_0 = sqrt( ifLocalVar6_g2432 );
			float clampResult22 = clamp( temp_output_16_0 , 0.0 , 0.8 );
			float4 temp_cast_3 = (( ( 0.0 * ( grayscale17 * clampResult18 ) ) + ( 0.0 * clampResult22 ) )).xxxx;
			float _contrast_Instance = UNITY_ACCESS_INSTANCED_PROP(_contrast_arr, _contrast);
			float time10 = 5.0;
			float2 voronoiSmoothId10 = 0;
			float fresnelNdotV7 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode7 = ( ( mulTime1 * _Speed ) + _FresnelScale * pow( 1.0 - fresnelNdotV7, _FresnelPower ) );
			float2 temp_cast_4 = (fresnelNode7).xx;
			float2 center45_g2410 = float2( 0.5,0.5 );
			float2 delta6_g2410 = ( temp_cast_4 - center45_g2410 );
			float angle10_g2410 = ( length( delta6_g2410 ) * 0.0 );
			float x23_g2410 = ( ( cos( angle10_g2410 ) * delta6_g2410.x ) - ( sin( angle10_g2410 ) * delta6_g2410.y ) );
			float2 break40_g2410 = center45_g2410;
			float2 temp_cast_5 = (35.0).xx;
			float2 break41_g2410 = temp_cast_5;
			float y35_g2410 = ( ( sin( angle10_g2410 ) * delta6_g2410.x ) + ( cos( angle10_g2410 ) * delta6_g2410.y ) );
			float2 appendResult44_g2410 = (float2(( x23_g2410 + break40_g2410.x + break41_g2410.x ) , ( break40_g2410.y + break41_g2410.y + y35_g2410 )));
			float2 coords10 = appendResult44_g2410 * 50.0;
			float2 id10 = 0;
			float2 uv10 = 0;
			float voroi10 = voronoi10( coords10, time10, id10, uv10, 0, voronoiSmoothId10 );
			float2 smoothstepResult12 = smoothstep( float2( 0.5,0.5 ) , float2( 0.8,0.8 ) , id10);
			float2 temp_output_15_0 = ( id11 * smoothstepResult12 );
			float4 screenColor16_g2439 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_15_0);
			float4 temp_output_2_0_g2442 = screenColor16_g2439;
			float3 temp_output_32_0_g2441 = (temp_output_2_0_g2442).rgb;
			float3 hsvTorgb39_g2441 = RGBToHSV( temp_output_32_0_g2441 );
			float3 break33_g2441 = temp_output_32_0_g2441;
			float dotResult30_g2441 = dot( temp_output_32_0_g2441 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g2441 = (float3(hsvTorgb39_g2441.x , ( max( break33_g2441.x , max( break33_g2441.y , break33_g2441.z ) ) - min( break33_g2441.x , min( break33_g2441.y , break33_g2441.z ) ) ) , dotResult30_g2441));
			float3 break565_g2439 = appendResult40_g2441;
			float4 temp_output_2_0_g2444 = ( 1.0 - screenColor16_g2439 );
			float3 temp_output_32_0_g2443 = (temp_output_2_0_g2444).rgb;
			float3 hsvTorgb39_g2443 = RGBToHSV( temp_output_32_0_g2443 );
			float3 break33_g2443 = temp_output_32_0_g2443;
			float dotResult30_g2443 = dot( temp_output_32_0_g2443 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g2443 = (float3(hsvTorgb39_g2443.x , ( max( break33_g2443.x , max( break33_g2443.y , break33_g2443.z ) ) - min( break33_g2443.x , min( break33_g2443.y , break33_g2443.z ) ) ) , dotResult30_g2443));
			float3 appendResult567_g2439 = (float3(break565_g2439.x , break565_g2439.y , appendResult40_g2443.z));
			float3 HSL564_g2439 = appendResult567_g2439;
			float3 hsvTorgb3_g2440 = HSVToRGB( float3(break565_g2439.x,1.0,1.0) );
			float3 RGB564_g2439 = hsvTorgb3_g2440;
			float3 localHSLtoRGB564_g2439 = HSLtoRGB( HSL564_g2439 , RGB564_g2439 );
			float4 appendResult550_g2439 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2439 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2439 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2439 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g2439 = appendResult550_g2439;
			float4 blendOpDest596_g2439 = ( 1.0 - _Near );
			float4 blendOpSrc595_g2439 = appendResult550_g2439;
			float4 blendOpDest595_g2439 = ( 1.0 - _Far );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g2439 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g2439 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g2439 = clamp( ( ( eyeDepth185_g2439 - distance( unityObjectToViewPos184_g2439 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g2439 = lerp( ( saturate( (( blendOpDest596_g2439 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g2439 ) * ( 1.0 - blendOpSrc596_g2439 ) ) : ( 2.0 * blendOpDest596_g2439 * blendOpSrc596_g2439 ) ) )) , ( saturate( (( blendOpDest595_g2439 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g2439 ) * ( 1.0 - blendOpSrc595_g2439 ) ) : ( 2.0 * blendOpDest595_g2439 * blendOpSrc595_g2439 ) ) )) , pow( clampResult190_g2439 , _TransitionFalloff ));
			float fresnelNdotV21 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode21 = ( 0.0 + temp_output_15_0.x * pow( max( 1.0 - fresnelNdotV21 , 0.0001 ), 1.0 ) );
			float clampResult26 = clamp( fresnelNode21 , 0.0 , 1.0 );
			float fresnelNdotV39 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode39 = ( smoothstepResult12.x + smoothstepResult12.x * pow( max( 1.0 - fresnelNdotV39 , 0.0001 ), smoothstepResult12.x ) );
			float4 lerpResult41 = lerp( temp_cast_3 , ( ( ( 1.0 - lerpResult627_g2439 ) * clampResult26 ) + ( temp_output_16_0 * fresnelNode21 ) ) , fresnelNode39);
			o.Emission = lerpResult41.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
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
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
Node;AmplifyShaderEditor.SimpleTimeNode;1;-2750.979,257.7783;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2958.979,513.7783;Inherit;False;Property;_Speed;Speed;6;0;Create;True;0;0;0;False;0;False;0;-0.0187;-0.1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2686.979,769.7783;Inherit;False;Property;_FresnelPower;Fresnel Power;8;0;Create;True;0;0;0;False;0;False;0;0.71;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2686.979,689.7783;Inherit;False;Property;_FresnelScale;Fresnel Scale;9;0;Create;True;0;0;0;False;0;False;0;0.044;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2558.979,577.7783;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2238.979,753.7783;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;7;-2382.979,529.7783;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2094.979,353.7783;Inherit;False;Constant;_Float2;Float 1;1;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;9;-2046.979,529.7783;Inherit;True;Twirl;-1;;2410;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;10;-1790.979,529.7783;Inherit;True;2;0;1;2;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;100;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.VoronoiNode;11;-1710.979,225.7783;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;50;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-1614.979,561.7783;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT2;0.8,0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;13;-1342.979,-14.22174;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;3;FLOAT;-1.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1406.979,433.7783;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;16;-1022.979,433.7783;Inherit;False;ComputeFilterWidth;-1;;2432;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;17;-1262.979,-142.2217;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;18;-1038.979,-14.22174;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;20;-1246.979,257.7783;Inherit;False;Pseudo Infrared Depth Filter;0;;2439;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.FresnelNode;21;-1038.979,561.7783;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-830.9795,-158.2217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;22;-702.9795,177.7783;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-910.9795,289.7783;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;26;-750.9795,433.7783;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-638.9795,1.778259;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-638.9795,-158.2217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-686.9795,593.7783;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-622.9795,321.7783;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-462.9795,-46.22174;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;35;-798.9795,-1086.222;Inherit;True;Property;_Texture0;Texture 0;7;0;Create;True;0;0;0;False;0;False;8654b394aef583b4683eaf99beede1aa;8654b394aef583b4683eaf99beede1aa;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-478.9795,481.7783;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;39;-1022.979,1025.778;Inherit;True;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;29;-1230.979,-782.2217;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosTime;30;-1182.979,-606.2217;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;36;-942.9795,-718.2217;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;40;-606.9795,-766.2217;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;0;False;0;False;-1;1cb3cf9a0935e594cba53e24782aff01;1cb3cf9a0935e594cba53e24782aff01;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;41;-78.97949,113.7783;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;42;-334.9795,-894.2217;Inherit;False;Pseudo Infrared Depth Filter;0;;2445;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.SamplerNode;43;-334.9795,-1086.222;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;8654b394aef583b4683eaf99beede1aa;8654b394aef583b4683eaf99beede1aa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldReflectionVector;44;-110.9795,-734.2217;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;272,-736;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;riftedHeadShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;1;0
WireConnection;5;1;2;0
WireConnection;7;1;5;0
WireConnection;7;2;4;0
WireConnection;7;3;3;0
WireConnection;9;1;7;0
WireConnection;9;4;6;0
WireConnection;10;0;9;0
WireConnection;10;2;8;0
WireConnection;11;1;1;0
WireConnection;11;2;8;0
WireConnection;12;0;10;1
WireConnection;15;0;11;1
WireConnection;15;1;12;0
WireConnection;16;1;11;1
WireConnection;17;0;11;1
WireConnection;18;0;13;0
WireConnection;20;628;15;0
WireConnection;21;2;15;0
WireConnection;23;0;17;0
WireConnection;23;1;18;0
WireConnection;22;0;16;0
WireConnection;25;0;20;78
WireConnection;26;0;21;0
WireConnection;27;1;22;0
WireConnection;28;1;23;0
WireConnection;32;0;16;0
WireConnection;32;1;21;0
WireConnection;33;0;25;0
WireConnection;33;1;26;0
WireConnection;34;0;28;0
WireConnection;34;1;27;0
WireConnection;38;0;33;0
WireConnection;38;1;32;0
WireConnection;39;1;12;0
WireConnection;39;2;12;0
WireConnection;39;3;12;0
WireConnection;36;0;29;0
WireConnection;36;2;30;0
WireConnection;40;0;35;0
WireConnection;40;1;36;0
WireConnection;40;7;35;1
WireConnection;41;0;34;0
WireConnection;41;1;38;0
WireConnection;41;2;39;0
WireConnection;43;0;35;0
WireConnection;43;7;35;1
WireConnection;44;0;40;0
WireConnection;0;0;43;0
WireConnection;0;2;41;0
ASEEND*/
//CHKSM=2FC2A89A002E29226A5186DD03032C22C6A66E80