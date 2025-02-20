// Upgrade NOTE: upgraded instancing buffer 'shatterShader' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "shatterShader"
{
	Properties
	{
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Speed("Speed", Range( 0 , 0.5)) = 0
		_Texture0("Texture 0", 2D) = "white" {}
		[HDR]_Color1("Color 0", Color) = (0,0,0,0)
		_CellDensity("_CellDensity", Range( 0 , 1000)) = 5
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma multi_compile_instancing
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow exclude_path:forward 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float4 uv2_texcoord2;
			float2 uv_texcoord;
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
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(shatterShader)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color1)
#define _Color1_arr shatterShader
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr shatterShader
		UNITY_INSTANCING_BUFFER_END(shatterShader)


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


float2 voronoihash76( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi76( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash76( n + g );
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
			float4 screenColor16_g357 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 temp_output_2_0_g360 = screenColor16_g357;
			float3 temp_output_32_0_g359 = (temp_output_2_0_g360).rgb;
			float3 hsvTorgb39_g359 = RGBToHSV( temp_output_32_0_g359 );
			float3 break33_g359 = temp_output_32_0_g359;
			float dotResult30_g359 = dot( temp_output_32_0_g359 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g359 = (float3(hsvTorgb39_g359.x , ( max( break33_g359.x , max( break33_g359.y , break33_g359.z ) ) - min( break33_g359.x , min( break33_g359.y , break33_g359.z ) ) ) , dotResult30_g359));
			float3 break565_g357 = appendResult40_g359;
			float4 temp_output_2_0_g362 = ( 1.0 - screenColor16_g357 );
			float3 temp_output_32_0_g361 = (temp_output_2_0_g362).rgb;
			float3 hsvTorgb39_g361 = RGBToHSV( temp_output_32_0_g361 );
			float3 break33_g361 = temp_output_32_0_g361;
			float dotResult30_g361 = dot( temp_output_32_0_g361 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g361 = (float3(hsvTorgb39_g361.x , ( max( break33_g361.x , max( break33_g361.y , break33_g361.z ) ) - min( break33_g361.x , min( break33_g361.y , break33_g361.z ) ) ) , dotResult30_g361));
			float3 appendResult567_g357 = (float3(break565_g357.x , break565_g357.y , appendResult40_g361.z));
			float3 HSL564_g357 = appendResult567_g357;
			float3 hsvTorgb3_g358 = HSVToRGB( float3(break565_g357.x,1.0,1.0) );
			float3 RGB564_g357 = hsvTorgb3_g358;
			float3 localHSLtoRGB564_g357 = HSLtoRGB( HSL564_g357 , RGB564_g357 );
			float4 appendResult550_g357 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g357 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g357 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g357 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g357 = appendResult550_g357;
			float4 blendOpDest596_g357 = ( 1.0 - _Near );
			float4 blendOpSrc595_g357 = appendResult550_g357;
			float4 blendOpDest595_g357 = ( 1.0 - _Far );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g357 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g357 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g357 = clamp( ( ( eyeDepth185_g357 - distance( unityObjectToViewPos184_g357 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g357 = lerp( ( saturate( (( blendOpDest596_g357 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g357 ) * ( 1.0 - blendOpSrc596_g357 ) ) : ( 2.0 * blendOpDest596_g357 * blendOpSrc596_g357 ) ) )) , ( saturate( (( blendOpDest595_g357 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g357 ) * ( 1.0 - blendOpSrc595_g357 ) ) : ( 2.0 * blendOpDest595_g357 * blendOpSrc595_g357 ) ) )) , pow( clampResult190_g357 , _TransitionFalloff ));
			o.Albedo = ( 1.0 - lerpResult627_g357 ).rgb;
			float3 ase_worldPos = i.worldPos;
			float gradientNoise77 = GradientNoise(( float4( ase_worldPos , 0.0 ) - i.uv2_texcoord2 ).xy,0.001);
			float dotResult4_g338 = dot( float2( 0,0 ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g338 = lerp( 155.0 , 255.0 , frac( ( sin( dotResult4_g338 ) * 43758.55 ) ));
			float mulTime67 = _Time.y * 5.0;
			float4 temp_cast_8 = (mulTime67).xxxx;
			float div73=256.0/float((int)lerpResult10_g338);
			float4 posterize73 = ( floor( temp_cast_8 * div73 ) / div73 );
			float time76 = posterize73.r;
			float2 voronoiSmoothId76 = 0;
			float mulTime61 = _Time.y * _Speed;
			float2 coords76 = tex2D( _Texture0, (i.uv_texcoord*0.1 + mulTime61) ).rg * ( _CellDensity * 0.05 );
			float2 id76 = 0;
			float2 uv76 = 0;
			float fade76 = 0.5;
			float voroi76 = 0;
			float rest76 = 0;
			for( int it76 = 0; it76 <2; it76++ ){
			voroi76 += fade76 * voronoi76( coords76, time76, id76, uv76, 0,voronoiSmoothId76 );
			rest76 += fade76;
			coords76 *= 2;
			fade76 *= 0.5;
			}//Voronoi76
			voroi76 /= rest76;
			float3 temp_output_1_0_g355 = float3( uv76 ,  0.0 );
			float3 temp_output_2_0_g355 = ddx( temp_output_1_0_g355 );
			float dotResult4_g355 = dot( temp_output_2_0_g355 , temp_output_2_0_g355 );
			float3 temp_output_3_0_g355 = ddy( temp_output_1_0_g355 );
			float dotResult5_g355 = dot( temp_output_3_0_g355 , temp_output_3_0_g355 );
			float ifLocalVar6_g355 = 0;
			if( dotResult4_g355 <= dotResult5_g355 )
				ifLocalVar6_g355 = dotResult5_g355;
			else
				ifLocalVar6_g355 = dotResult4_g355;
			float4 temp_cast_12 = (( ( gradientNoise77 * 0.01 ) + sqrt( ifLocalVar6_g355 ) )).xxxx;
			float4 _Color1_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color1_arr, _Color1);
			float4 temp_output_93_0 = ( CalculateContrast(0.0,temp_cast_12) * _Color1_Instance );
			o.Emission = temp_output_93_0.rgb;
			o.Alpha = 1;
			clip( temp_output_93_0.r - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.RangedFloatNode;60;-3536,-208;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;0;0.0241;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;61;-3216,-208;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-2928,192;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;63;-2768,-1040;Inherit;False;1227;603;;8;80;77;74;72;71;69;66;65;Noise Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;64;-2800,-480;Inherit;True;Property;_Texture0;Texture 0;8;0;Create;True;0;0;0;False;0;False;None;1b0165733eeed2d499806cdd83d6319f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldPosInputsNode;65;-2688,-992;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;66;-2704,-832;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;67;-2400,-240;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;68;-2400,-128;Inherit;False;Random Range;-1;;338;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;155;False;3;FLOAT;255;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2704,-576;Inherit;False;Property;_CellDensity;_CellDensity;10;0;Create;True;0;0;0;False;0;False;5;19;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;70;-2848,-256;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;71;-2560,-480;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-2352,-848;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosterizeNode;73;-2224,-176;Inherit;False;206;2;1;COLOR;0,0,0,0;False;0;INT;206;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2352,-576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;76;-2032,-400;Inherit;False;1;1;1;2;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.NoiseGeneratorNode;77;-2064,-864;Inherit;True;Gradient;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1776,-864;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;81;-1824,-352;Inherit;False;ComputeFilterWidth;-1;;355;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-1488,-368;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;86;-1184,-656;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;89;-1184,-256;Inherit;False;InstancedProperty;_Color1;Color 0;9;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1.098039,1.098039,1.098039,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleContrastOpNode;90;-1200,-480;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;92;-832,-512;Inherit;False;Pseudo Infrared Depth Filter;0;;357;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.OneMinusNode;75;-1824,224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;78;-1792,80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;79;-1664,208;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;82;-1632,-48;Inherit;False;Rectangle;-1;;356;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;-1616,80;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1520,208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1344,-80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-1344,32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-1168,-80;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-832,-336;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;94;-768,-112;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;-480,-384;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-304,-384;Float;False;True;-1;4;ASEMaterialInspector;0;0;Standard;shatterShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Masked;0.5;True;False;0;False;TransparentCutout;;AlphaTest;DeferredOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;6;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;61;0;60;0
WireConnection;70;0;62;0
WireConnection;70;2;61;0
WireConnection;71;0;64;0
WireConnection;71;1;70;0
WireConnection;71;7;64;1
WireConnection;72;0;65;0
WireConnection;72;1;66;0
WireConnection;73;1;67;0
WireConnection;73;0;68;0
WireConnection;74;0;69;0
WireConnection;76;0;71;0
WireConnection;76;1;73;0
WireConnection;76;2;74;0
WireConnection;77;0;72;0
WireConnection;80;0;77;0
WireConnection;81;1;76;2
WireConnection;85;0;80;0
WireConnection;85;1;81;0
WireConnection;90;1;85;0
WireConnection;92;628;86;0
WireConnection;75;0;62;2
WireConnection;78;0;62;1
WireConnection;79;0;75;0
WireConnection;79;2;75;0
WireConnection;83;0;78;0
WireConnection;84;0;79;0
WireConnection;87;0;83;0
WireConnection;87;1;82;0
WireConnection;88;0;84;0
WireConnection;88;1;83;0
WireConnection;91;0;87;0
WireConnection;91;1;88;0
WireConnection;93;0;90;0
WireConnection;93;1;89;0
WireConnection;94;0;91;0
WireConnection;95;0;92;78
WireConnection;0;0;95;0
WireConnection;0;2;93;0
WireConnection;0;10;93;0
ASEEND*/
//CHKSM=7DDE13BC13339CE8ED50595AB9C33D391A30CF4F