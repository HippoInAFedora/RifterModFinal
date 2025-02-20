// Upgrade NOTE: upgraded instancing buffer 'CustomwanderShader' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/wanderShader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_Speed("Speed", Range( 0 , 0.1)) = 0
		_Texture0("Texture 0", 2D) = "white" {}
		_Clip("Clip", Range( 0 , 1)) = 0
		_CellDensity("_CellDensity", Range( 0 , 1000)) = 5
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		GrabPass{ }
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float4 uv2_texcoord2;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform float _CellDensity;
		uniform sampler2D _Texture0;
		uniform float _Speed;
		uniform float _Clip;
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(CustomwanderShader)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color0)
#define _Color0_arr CustomwanderShader
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr CustomwanderShader
		UNITY_INSTANCING_BUFFER_END(CustomwanderShader)


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

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

		//https://www.shadertoy.com/view/XdXGW8
		float2 GradientNoiseDir( float2 x )
		{
			const float2 k = float2( 0.3183099, 0.3678794 );
			x = x * k + k.yx;
			return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
		}
		
		float GradientNoise( float2 UV, float Scale )
		{
			float2 p = UV * Scale;
			float2 i = floor( p );
			float2 f = frac( p );
			float2 u = f * f * ( 3.0 - 2.0 * f );
			return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
					lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
		}


float2 voronoihash21( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi21( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
{
	float2 n = floor( v );
	float2 f = frac( v );
	float F1 = 8.0;
	float F2 = 8.0; float2 mg = 0;
	for ( int j = -2; j <= 2; j++ )
	{
		for ( int i = -2; i <= 2; i++ )
	 	{
	 		float2 g = float2( i, j );
	 		float2 o = voronoihash21( n + g );
			o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
			float d = 0.707 * sqrt(dot( r, r ));
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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float _contrast_Instance = UNITY_ACCESS_INSTANCED_PROP(_contrast_arr, _contrast);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor16_g356 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 temp_output_2_0_g359 = screenColor16_g356;
			float3 temp_output_32_0_g358 = (temp_output_2_0_g359).rgb;
			float3 hsvTorgb39_g358 = RGBToHSV( temp_output_32_0_g358 );
			float3 break33_g358 = temp_output_32_0_g358;
			float dotResult30_g358 = dot( temp_output_32_0_g358 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g358 = (float3(hsvTorgb39_g358.x , ( max( break33_g358.x , max( break33_g358.y , break33_g358.z ) ) - min( break33_g358.x , min( break33_g358.y , break33_g358.z ) ) ) , dotResult30_g358));
			float3 break565_g356 = appendResult40_g358;
			float4 temp_output_2_0_g361 = ( 1.0 - screenColor16_g356 );
			float3 temp_output_32_0_g360 = (temp_output_2_0_g361).rgb;
			float3 hsvTorgb39_g360 = RGBToHSV( temp_output_32_0_g360 );
			float3 break33_g360 = temp_output_32_0_g360;
			float dotResult30_g360 = dot( temp_output_32_0_g360 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g360 = (float3(hsvTorgb39_g360.x , ( max( break33_g360.x , max( break33_g360.y , break33_g360.z ) ) - min( break33_g360.x , min( break33_g360.y , break33_g360.z ) ) ) , dotResult30_g360));
			float3 appendResult567_g356 = (float3(break565_g356.x , break565_g356.y , appendResult40_g360.z));
			float3 HSL564_g356 = appendResult567_g356;
			float3 hsvTorgb3_g357 = HSVToRGB( float3(break565_g356.x,1.0,1.0) );
			float3 RGB564_g356 = hsvTorgb3_g357;
			float3 localHSLtoRGB564_g356 = HSLtoRGB( HSL564_g356 , RGB564_g356 );
			float4 appendResult550_g356 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g356 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g356 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g356 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g356 = appendResult550_g356;
			float4 blendOpDest596_g356 = ( 1.0 - _Near );
			float4 blendOpSrc595_g356 = appendResult550_g356;
			float4 blendOpDest595_g356 = ( 1.0 - _Far );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g356 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g356 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g356 = clamp( ( ( eyeDepth185_g356 - distance( unityObjectToViewPos184_g356 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g356 = lerp( ( saturate( (( blendOpDest596_g356 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g356 ) * ( 1.0 - blendOpSrc596_g356 ) ) : ( 2.0 * blendOpDest596_g356 * blendOpSrc596_g356 ) ) )) , ( saturate( (( blendOpDest595_g356 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g356 ) * ( 1.0 - blendOpSrc595_g356 ) ) : ( 2.0 * blendOpDest595_g356 * blendOpSrc595_g356 ) ) )) , pow( clampResult190_g356 , _TransitionFalloff ));
			o.Normal = ( 1.0 - lerpResult627_g356 ).rgb;
			float3 ase_worldPos = i.worldPos;
			float gradientNoise22 = GradientNoise(( float4( ase_worldPos , 0.0 ) - i.uv2_texcoord2 ).xy,0.001);
			float time21 = 5.0;
			float2 voronoiSmoothId21 = 0;
			float mulTime2 = _Time.y * _Speed;
			float2 coords21 = tex2D( _Texture0, (i.uv_texcoord*0.1 + mulTime2) ).rg * ( _CellDensity * 0.05 );
			float2 id21 = 0;
			float2 uv21 = 0;
			float fade21 = 0.5;
			float voroi21 = 0;
			float rest21 = 0;
			for( int it21 = 0; it21 <2; it21++ ){
			voroi21 += fade21 * voronoi21( coords21, time21, id21, uv21, 0,voronoiSmoothId21 );
			rest21 += fade21;
			coords21 *= 2;
			fade21 *= 0.5;
			}//Voronoi21
			voroi21 /= rest21;
			float3 temp_output_1_0_g355 = float3( uv21 ,  0.0 );
			float3 temp_output_2_0_g355 = ddx( temp_output_1_0_g355 );
			float dotResult4_g355 = dot( temp_output_2_0_g355 , temp_output_2_0_g355 );
			float3 temp_output_3_0_g355 = ddy( temp_output_1_0_g355 );
			float dotResult5_g355 = dot( temp_output_3_0_g355 , temp_output_3_0_g355 );
			float ifLocalVar6_g355 = 0;
			if( dotResult4_g355 <= dotResult5_g355 )
				ifLocalVar6_g355 = dotResult5_g355;
			else
				ifLocalVar6_g355 = dotResult4_g355;
			float temp_output_29_0 = ( ( gradientNoise22 * 0.01 ) + sqrt( ifLocalVar6_g355 ) );
			float4 temp_cast_9 = (temp_output_29_0).xxxx;
			float4 _Color0_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color0_arr, _Color0);
			o.Emission = ( CalculateContrast(0.0,temp_cast_9) * i.vertexColor * _Color0_Instance ).rgb;
			o.Alpha = 1;
			float grayscale30 = Luminance(float3( id21 ,  0.0 ));
			float clampResult37 = clamp( grayscale30 , 0.0 , 0.8 );
			clip( ( temp_output_29_0 + grayscale30 ) - _Clip);
			clip( clampResult37 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.RangedFloatNode;1;-3270.667,90.30878;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;0;False;0;False;0;0.0241;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;2;-2950.667,90.30878;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;4;-2566.667,-741.6912;Inherit;False;1227;603;;9;25;22;17;15;14;10;7;6;5;Noise Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2832,224;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-2534.667,-181.6912;Inherit;True;Property;_Texture0;Texture 0;9;0;Create;True;0;0;0;False;0;False;1b0165733eeed2d499806cdd83d6319f;1b0165733eeed2d499806cdd83d6319f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-2486.667,-693.6912;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;7;-2502.667,-533.6912;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-2502.667,-277.6912;Inherit;False;Property;_CellDensity;_CellDensity;11;0;Create;True;0;0;0;False;0;False;5;19;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;11;-2582.667,42.30878;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-2150.667,-549.6912;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2150.667,-277.6912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-2294.667,-181.6912;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;21;-1766.668,-101.6912;Inherit;True;1;1;1;2;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.NoiseGeneratorNode;22;-1862.668,-565.6912;Inherit;True;Gradient;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1574.668,-565.6912;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;26;-1558.668,-53.69122;Inherit;False;ComputeFilterWidth;-1;;355;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;28;-1254.668,-421.6912;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1222.668,-69.69122;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;30;-1300.778,504.0434;Inherit;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;32;-998.6676,-421.6912;Inherit;False;Pseudo Infrared Depth Filter;1;;356;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.SimpleContrastOpNode;34;-934.6676,-181.6912;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1078.668,666.3088;Inherit;False;Property;_Clip;Clip;10;0;Create;True;0;0;0;False;0;False;0;0.164;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-918.6676,538.3088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;37;-886.6676,394.3088;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;44;-912,32;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;45;-928,208;Inherit;False;InstancedProperty;_Color0;Color 0;7;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;40;-678.6676,-293.6912;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-566.6676,-37.69122;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;42;-566.6676,346.3088;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/wanderShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;False;Transparent;;Overlay;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;11;0;3;0
WireConnection;11;2;2;0
WireConnection;15;0;6;0
WireConnection;15;1;7;0
WireConnection;17;0;10;0
WireConnection;14;0;5;0
WireConnection;14;1;11;0
WireConnection;14;7;5;1
WireConnection;21;0;14;0
WireConnection;21;2;17;0
WireConnection;22;0;15;0
WireConnection;25;0;22;0
WireConnection;26;1;21;2
WireConnection;29;0;25;0
WireConnection;29;1;26;0
WireConnection;30;0;21;1
WireConnection;32;628;28;0
WireConnection;34;1;29;0
WireConnection;36;0;29;0
WireConnection;36;1;30;0
WireConnection;37;0;30;0
WireConnection;40;0;32;78
WireConnection;41;0;34;0
WireConnection;41;1;44;0
WireConnection;41;2;45;0
WireConnection;42;0;37;0
WireConnection;42;1;36;0
WireConnection;42;2;35;0
WireConnection;0;1;40;0
WireConnection;0;2;41;0
WireConnection;0;10;42;0
ASEEND*/
//CHKSM=AAF1DBE480278CD3D0BA7D11621A3AAEA23209A4