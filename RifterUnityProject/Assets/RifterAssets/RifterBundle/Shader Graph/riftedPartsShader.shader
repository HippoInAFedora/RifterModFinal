// Upgrade NOTE: upgraded instancing buffer 'CustomriftedPartsShader' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/riftedPartsShader"
{
	Properties
	{
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		_Texture0("Texture 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow 
		struct Input
		{
			float3 worldRefl;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform sampler2D _TextureSample1;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform sampler2D _Texture0;

		UNITY_INSTANCING_BUFFER_START(CustomriftedPartsShader)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Texture0_ST)
#define _Texture0_ST_arr CustomriftedPartsShader
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr CustomriftedPartsShader
		UNITY_INSTANCING_BUFFER_END(CustomriftedPartsShader)


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

float2 voronoihash69( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi69( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash69( n + g );
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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = WorldReflectionVector( i , UnpackNormal( tex2D( _TextureSample1, (i.uv_texcoord*1.0 + _CosTime.xy) ) ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor87 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
			float _contrast_Instance = UNITY_ACCESS_INSTANCED_PROP(_contrast_arr, _contrast);
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor16_g2433 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 temp_output_2_0_g2436 = screenColor16_g2433;
			float3 temp_output_32_0_g2435 = (temp_output_2_0_g2436).rgb;
			float3 hsvTorgb39_g2435 = RGBToHSV( temp_output_32_0_g2435 );
			float3 break33_g2435 = temp_output_32_0_g2435;
			float dotResult30_g2435 = dot( temp_output_32_0_g2435 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g2435 = (float3(hsvTorgb39_g2435.x , ( max( break33_g2435.x , max( break33_g2435.y , break33_g2435.z ) ) - min( break33_g2435.x , min( break33_g2435.y , break33_g2435.z ) ) ) , dotResult30_g2435));
			float3 break565_g2433 = appendResult40_g2435;
			float4 temp_output_2_0_g2438 = ( 1.0 - screenColor16_g2433 );
			float3 temp_output_32_0_g2437 = (temp_output_2_0_g2438).rgb;
			float3 hsvTorgb39_g2437 = RGBToHSV( temp_output_32_0_g2437 );
			float3 break33_g2437 = temp_output_32_0_g2437;
			float dotResult30_g2437 = dot( temp_output_32_0_g2437 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g2437 = (float3(hsvTorgb39_g2437.x , ( max( break33_g2437.x , max( break33_g2437.y , break33_g2437.z ) ) - min( break33_g2437.x , min( break33_g2437.y , break33_g2437.z ) ) ) , dotResult30_g2437));
			float3 appendResult567_g2433 = (float3(break565_g2433.x , break565_g2433.y , appendResult40_g2437.z));
			float3 HSL564_g2433 = appendResult567_g2433;
			float3 hsvTorgb3_g2434 = HSVToRGB( float3(break565_g2433.x,1.0,1.0) );
			float3 RGB564_g2433 = hsvTorgb3_g2434;
			float3 localHSLtoRGB564_g2433 = HSLtoRGB( HSL564_g2433 , RGB564_g2433 );
			float4 appendResult550_g2433 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2433 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2433 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g2433 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g2433 = appendResult550_g2433;
			float4 blendOpDest596_g2433 = ( 1.0 - _Near );
			float4 blendOpSrc595_g2433 = appendResult550_g2433;
			float4 blendOpDest595_g2433 = ( 1.0 - _Far );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g2433 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g2433 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g2433 = clamp( ( ( eyeDepth185_g2433 - distance( unityObjectToViewPos184_g2433 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g2433 = lerp( ( saturate( (( blendOpDest596_g2433 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g2433 ) * ( 1.0 - blendOpSrc596_g2433 ) ) : ( 2.0 * blendOpDest596_g2433 * blendOpSrc596_g2433 ) ) )) , ( saturate( (( blendOpDest595_g2433 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g2433 ) * ( 1.0 - blendOpSrc595_g2433 ) ) : ( 2.0 * blendOpDest595_g2433 * blendOpSrc595_g2433 ) ) )) , pow( clampResult190_g2433 , _TransitionFalloff ));
			float4 temp_output_80_0 = ( 1.0 - lerpResult627_g2433 );
			float4 _Texture0_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_Texture0_ST_arr, _Texture0_ST);
			float2 uv_Texture0 = i.uv_texcoord * _Texture0_ST_Instance.xy + _Texture0_ST_Instance.zw;
			float4 tex2DNode115 = tex2D( _Texture0, uv_Texture0 );
			float grayscale76 = Luminance(tex2DNode115.rgb);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV72 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode72 = ( 0.0 + 0.01 * pow( max( 1.0 - fresnelNdotV72 , 0.0001 ), -1.6 ) );
			float clampResult77 = clamp( fresnelNode72 , 0.0 , 1.0 );
			float mulTime59 = _Time.y * 5.0;
			float time69 = mulTime59;
			float2 voronoiSmoothId69 = 0;
			float2 coords69 = i.uv_texcoord * 50.0;
			float2 id69 = 0;
			float2 uv69 = 0;
			float voroi69 = voronoi69( coords69, time69, id69, uv69, 0, voronoiSmoothId69 );
			float3 temp_output_1_0_g2439 = float3( id69 ,  0.0 );
			float3 temp_output_2_0_g2439 = ddx( temp_output_1_0_g2439 );
			float dotResult4_g2439 = dot( temp_output_2_0_g2439 , temp_output_2_0_g2439 );
			float3 temp_output_3_0_g2439 = ddy( temp_output_1_0_g2439 );
			float dotResult5_g2439 = dot( temp_output_3_0_g2439 , temp_output_3_0_g2439 );
			float ifLocalVar6_g2439 = 0;
			if( dotResult4_g2439 <= dotResult5_g2439 )
				ifLocalVar6_g2439 = dotResult5_g2439;
			else
				ifLocalVar6_g2439 = dotResult4_g2439;
			float temp_output_75_0 = sqrt( ifLocalVar6_g2439 );
			float clampResult81 = clamp( temp_output_75_0 , 0.0 , 0.8 );
			float4 lerpResult92 = lerp( screenColor87 , ( ( temp_output_80_0 * ( grayscale76 * clampResult77 ) ) + ( temp_output_80_0 * clampResult81 ) ) , clampResult77);
			o.Albedo = lerpResult92.rgb;
			o.Alpha = screenColor87.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.SimpleTimeNode;59;-3152,1232;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;57;-2720,976;Inherit;True;Property;_Texture0;Texture 0;8;0;Create;True;0;0;0;False;0;False;None;491cf31964dcd334daecc76cb22bdc07;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;66;-2496,1328;Inherit;False;Constant;_Float2;Float 1;1;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;69;-2112,1200;Inherit;False;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;50;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SamplerNode;115;-2432,976;Inherit;True;Property;_TextureSample0;Texture Sample 0;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;72;-1744,960;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;3;FLOAT;-1.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;71;-1872,640;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;77;-1440,960;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;74;-1648,640;Inherit;False;Pseudo Infrared Depth Filter;1;;2433;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.FunctionNode;75;-1424,1408;Inherit;True;ComputeFilterWidth;-1;;2439;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;76;-1664,832;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;81;-1104,1152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1232,816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;80;-1312,640;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;55;-1632,192;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosTime;56;-1584,368;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1040,976;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1040,816;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;54;-1344,256;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;87;-912,528;Inherit;False;Global;_GrabScreen0;Grab Screen 0;7;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-864,928;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;50;-1008,208;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;1cb3cf9a0935e594cba53e24782aff01;1cb3cf9a0935e594cba53e24782aff01;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-3360,1488;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;0;-0.0246;-0.1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-3088,1744;Inherit;False;Property;_FresnelPower;Fresnel Power;10;0;Create;True;0;0;0;False;0;False;0;0.71;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-3088,1664;Inherit;False;Property;_FresnelScale;Fresnel Scale;11;0;Create;True;0;0;0;False;0;False;0;0.067;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2960,1552;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2640,1728;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;65;-2784,1504;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;67;-2448,1504;Inherit;True;Twirl;-1;;2410;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;117;-2256,1312;Inherit;True;Property;_TextureSample2;Texture Sample 2;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;70;-2016,1536;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1808,1408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;78;-1648,1232;Inherit;False;Pseudo Infrared Depth Filter;1;;2440;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.FresnelNode;79;-1440,1536;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;83;-1312,1264;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;84;-1152,1408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-1088,1568;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1024,1296;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-880,1456;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;96;-1424,2000;Inherit;True;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;92;-688,1008;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;97;-480,1088;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;114;-275.377,903.7865;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VoronoiNode;68;-2192,1504;Inherit;True;2;0;1;2;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;100;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.WorldReflectionVector;53;-512,240;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;119;48,528;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/riftedPartsShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;False;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;69;1;59;0
WireConnection;69;2;66;0
WireConnection;115;0;57;0
WireConnection;115;7;57;1
WireConnection;77;0;72;0
WireConnection;74;628;71;0
WireConnection;75;1;69;1
WireConnection;76;0;115;0
WireConnection;81;0;75;0
WireConnection;82;0;76;0
WireConnection;82;1;77;0
WireConnection;80;0;74;78
WireConnection;85;0;80;0
WireConnection;85;1;81;0
WireConnection;86;0;80;0
WireConnection;86;1;82;0
WireConnection;54;0;55;0
WireConnection;54;2;56;0
WireConnection;91;0;86;0
WireConnection;91;1;85;0
WireConnection;50;1;54;0
WireConnection;63;0;59;0
WireConnection;63;1;60;0
WireConnection;65;1;63;0
WireConnection;65;2;62;0
WireConnection;65;3;61;0
WireConnection;67;1;65;0
WireConnection;67;4;64;0
WireConnection;117;0;57;0
WireConnection;117;1;67;0
WireConnection;117;7;57;1
WireConnection;70;0;117;3
WireConnection;73;0;115;0
WireConnection;73;1;70;0
WireConnection;78;628;73;0
WireConnection;79;2;73;0
WireConnection;83;0;78;78
WireConnection;84;0;79;0
WireConnection;88;0;75;0
WireConnection;88;1;79;0
WireConnection;89;0;83;0
WireConnection;89;1;84;0
WireConnection;93;0;89;0
WireConnection;93;1;88;0
WireConnection;96;1;70;0
WireConnection;96;2;70;0
WireConnection;96;3;70;0
WireConnection;92;0;87;0
WireConnection;92;1;91;0
WireConnection;92;2;77;0
WireConnection;97;0;92;0
WireConnection;97;1;93;0
WireConnection;97;2;96;0
WireConnection;114;0;97;0
WireConnection;68;0;67;0
WireConnection;68;2;66;0
WireConnection;53;0;50;0
WireConnection;119;0;92;0
WireConnection;119;1;53;0
WireConnection;119;9;87;0
ASEEND*/
//CHKSM=92BC533CDEB3445CE483624DFBC119D06379DC0D