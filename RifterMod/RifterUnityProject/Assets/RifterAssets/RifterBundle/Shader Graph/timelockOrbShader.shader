// Upgrade NOTE: upgraded instancing buffer 'CustomtimelockOrbShader' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/timelockOrbShader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		_Speed("Speed", Range( -0.1 , 0)) = 0
		_FresnelScaleInner("FresnelScaleInner", Float) = 0
		_FresnelPower("Fresnel Power", Range( 0 , 1)) = 0
		_FresnelScale("Fresnel Scale", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
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
			float4 screenPosition;
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			half ASEIsFrontFacing : VFACE;
			float eyeDepth;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform float _FresnelScaleInner;
		uniform float _Speed;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(CustomtimelockOrbShader)
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr CustomtimelockOrbShader
		UNITY_INSTANCING_BUFFER_END(CustomtimelockOrbShader)


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

float2 voronoihash72( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi72( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash72( n + g );
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


float2 voronoihash68( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi68( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash68( n + g );
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


inline float Dither8x8Bayer( int x, int y )
{
	const float dither[ 64 ] = {
		 1, 49, 13, 61,  4, 52, 16, 64,
		33, 17, 45, 29, 36, 20, 48, 32,
		 9, 57,  5, 53, 12, 60,  8, 56,
		41, 25, 37, 21, 44, 28, 40, 24,
		 3, 51, 15, 63,  2, 50, 14, 62,
		35, 19, 47, 31, 34, 18, 46, 30,
		11, 59,  7, 55, 10, 58,  6, 54,
		43, 27, 39, 23, 42, 26, 38, 22};
	int r = y * 8 + x;
	return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = i.screenPosition;
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor88 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
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
			float4 temp_output_79_0 = ( 1.0 - lerpResult627_g2426 );
			float mulTime59 = _Time.y * 5.0;
			float time72 = mulTime59;
			float2 voronoiSmoothId72 = 0;
			float2 coords72 = i.uv_texcoord * 50.0;
			float2 id72 = 0;
			float2 uv72 = 0;
			float voroi72 = voronoi72( coords72, time72, id72, uv72, 0, voronoiSmoothId72 );
			float grayscale77 = Luminance(float3( id72 ,  0.0 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV73 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode73 = ( 0.0 + _FresnelScaleInner * pow( max( 1.0 - fresnelNdotV73 , 0.0001 ), -1.6 ) );
			float clampResult78 = clamp( fresnelNode73 , 0.0 , 1.75 );
			float3 temp_output_1_0_g2432 = float3( id72 ,  0.0 );
			float3 temp_output_2_0_g2432 = ddx( temp_output_1_0_g2432 );
			float dotResult4_g2432 = dot( temp_output_2_0_g2432 , temp_output_2_0_g2432 );
			float3 temp_output_3_0_g2432 = ddy( temp_output_1_0_g2432 );
			float dotResult5_g2432 = dot( temp_output_3_0_g2432 , temp_output_3_0_g2432 );
			float ifLocalVar6_g2432 = 0;
			if( dotResult4_g2432 <= dotResult5_g2432 )
				ifLocalVar6_g2432 = dotResult5_g2432;
			else
				ifLocalVar6_g2432 = dotResult4_g2432;
			float temp_output_76_0 = sqrt( ifLocalVar6_g2432 );
			float clampResult82 = clamp( temp_output_76_0 , 0.0 , 0.8 );
			float4 lerpResult96 = lerp( screenColor88 , ( ( temp_output_79_0 * ( grayscale77 * clampResult78 ) ) + ( temp_output_79_0 * clampResult82 ) ) , float4( 0,0,0,0 ));
			float time68 = 5.0;
			float2 voronoiSmoothId68 = 0;
			float fresnelNdotV65 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode65 = ( ( mulTime59 * _Speed ) + _FresnelScale * pow( 1.0 - fresnelNdotV65, _FresnelPower ) );
			float2 temp_cast_6 = (fresnelNode65).xx;
			float2 center45_g2410 = float2( 0.5,0.5 );
			float2 delta6_g2410 = ( temp_cast_6 - center45_g2410 );
			float angle10_g2410 = ( length( delta6_g2410 ) * 0.0 );
			float x23_g2410 = ( ( cos( angle10_g2410 ) * delta6_g2410.x ) - ( sin( angle10_g2410 ) * delta6_g2410.y ) );
			float2 break40_g2410 = center45_g2410;
			float2 temp_cast_7 = (35.0).xx;
			float2 break41_g2410 = temp_cast_7;
			float y35_g2410 = ( ( sin( angle10_g2410 ) * delta6_g2410.x ) + ( cos( angle10_g2410 ) * delta6_g2410.y ) );
			float2 appendResult44_g2410 = (float2(( x23_g2410 + break40_g2410.x + break41_g2410.x ) , ( break40_g2410.y + break41_g2410.y + y35_g2410 )));
			float2 coords68 = appendResult44_g2410 * 50.0;
			float2 id68 = 0;
			float2 uv68 = 0;
			float voroi68 = voronoi68( coords68, time68, id68, uv68, 0, voronoiSmoothId68 );
			float2 smoothstepResult71 = smoothstep( float2( 0.5,0.5 ) , float2( 0.8,0.8 ) , id68);
			float2 temp_output_75_0 = ( id72 * smoothstepResult71 );
			float4 screenColor16_g2433 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_75_0);
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
			float eyeDepth185_g2433 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g2433 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g2433 = clamp( ( ( eyeDepth185_g2433 - distance( unityObjectToViewPos184_g2433 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g2433 = lerp( ( saturate( (( blendOpDest596_g2433 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g2433 ) * ( 1.0 - blendOpSrc596_g2433 ) ) : ( 2.0 * blendOpDest596_g2433 * blendOpSrc596_g2433 ) ) )) , ( saturate( (( blendOpDest595_g2433 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g2433 ) * ( 1.0 - blendOpSrc595_g2433 ) ) : ( 2.0 * blendOpDest595_g2433 * blendOpSrc595_g2433 ) ) )) , pow( clampResult190_g2433 , _TransitionFalloff ));
			float fresnelNdotV81 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode81 = ( 0.0 + temp_output_75_0.x * pow( max( 1.0 - fresnelNdotV81 , 0.0001 ), 1.0 ) );
			float clampResult85 = clamp( fresnelNode81 , 0.0 , 1.0 );
			float fresnelNdotV90 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode90 = ( 0.0 + 2.0 * pow( 1.0 - fresnelNdotV90, 4.0 ) );
			float fresnelNdotV89 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode89 = ( smoothstepResult71.x + smoothstepResult71.x * pow( max( 1.0 - fresnelNdotV89 , 0.0001 ), smoothstepResult71.x ) );
			float4 lerpResult104 = lerp( lerpResult96 , ( ( ( 1.0 - lerpResult627_g2433 ) * clampResult85 ) + ( temp_output_76_0 * fresnelNode81 ) ) , ( fresnelNode90 + fresnelNode89 ));
			o.Emission = lerpResult104.rgb;
			o.Alpha = 1;
			float2 clipScreen99 = abs( ase_screenPosNorm.xy ) * _ScreenParams.xy;
			float dither99 = Dither8x8Bayer( fmod(clipScreen99.x, 8), fmod(clipScreen99.y, 8) );
			float cameraDepthFade94 = (( i.eyeDepth -_ProjectionParams.y - 15.0 ) / 15.0);
			dither99 = step( dither99, cameraDepthFade94 );
			float switchResult111 = (((i.ASEIsFrontFacing>0)?(i.ASEIsFrontFacing):(dither99)));
			clip( switchResult111 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float3 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xyzw = customInputData.screenPosition;
				o.customPack2.xy = customInputData.uv_texcoord;
				o.customPack2.xy = v.texcoord;
				o.customPack2.z = customInputData.eyeDepth;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				surfIN.screenPosition = IN.customPack1.xyzw;
				surfIN.uv_texcoord = IN.customPack2.xy;
				surfIN.eyeDepth = IN.customPack2.z;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
Node;AmplifyShaderEditor.SimpleTimeNode;59;-4080,0;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-4288,256;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;0;-0.0109;-0.1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-4016,512;Inherit;False;Property;_FresnelPower;Fresnel Power;10;0;Create;True;0;0;0;False;0;False;0;0.693;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-3888,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4016,432;Inherit;False;Property;_FresnelScale;Fresnel Scale;11;0;Create;True;0;0;0;False;0;False;0;-0.13;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-3568,496;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;65;-3712,272;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-3424,96;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;67;-3376,272;Inherit;True;Twirl;-1;;2410;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;68;-3120,272;Inherit;True;2;0;1;2;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;100;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;69;-3008,-288;Inherit;False;Property;_FresnelScaleInner;FresnelScaleInner;8;0;Create;True;0;0;0;False;0;False;0;0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;70;-2624,-576;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;71;-2944,304;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT2;0.8,0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;72;-3040,-32;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;50;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.FresnelNode;73;-2672,-272;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.05;False;3;FLOAT;-1.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;74;-2368,-576;Inherit;False;Pseudo Infrared Depth Filter;1;;2426;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2736,176;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;76;-2352,176;Inherit;False;ComputeFilterWidth;-1;;2432;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;77;-2592,-400;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;78;-2368,-272;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-2032,-576;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;80;-2576,0;Inherit;False;Pseudo Infrared Depth Filter;1;;2433;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.FresnelNode;81;-2368,304;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;82;-2032,-80;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2160,-416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;-2224,32;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;85;-2080,176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1968,-256;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1968,-416;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;88;-1840,-704;Inherit;False;Global;_GrabScreen0;Grab Screen 0;7;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;89;-2400,880;Inherit;True;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;90;-2400,624;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;2;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-2016,336;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1952,64;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-1792,-304;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CameraDepthFade;94;-960,544;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;15;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-2016,688;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;96;-1616,-224;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-1808,224;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;99;-688,544;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FaceVariableNode;98;-656,448;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;100;-1520,-560;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;101;-1520,-736;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-1280,-624;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;-1136,-624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;105;-992,-624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1216,-384;Inherit;False;Property;_Power;Power;9;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;108;-832,-416;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;104;-1424,192;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;110;-624,-288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;107;-1024,320;Inherit;False;Alpha Split;-1;;2439;07dab7960105b86429ac8eebd729ed6d;0;1;2;COLOR;0,0,0,0;False;2;FLOAT3;0;FLOAT;6
Node;AmplifyShaderEditor.SaturateNode;109;-576,368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;112;-400,16;Inherit;False;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-352,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;111;-464,464;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-64,128;Float;False;True;-1;4;ASEMaterialInspector;0;0;Standard;Custom/timelockOrbShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;False;TransparentCutout;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;65;1;62;0
WireConnection;65;2;63;0
WireConnection;65;3;61;0
WireConnection;67;1;65;0
WireConnection;67;4;64;0
WireConnection;68;0;67;0
WireConnection;68;2;66;0
WireConnection;71;0;68;1
WireConnection;72;1;59;0
WireConnection;72;2;66;0
WireConnection;73;2;69;0
WireConnection;74;628;70;0
WireConnection;75;0;72;1
WireConnection;75;1;71;0
WireConnection;76;1;72;1
WireConnection;77;0;72;1
WireConnection;78;0;73;0
WireConnection;79;0;74;78
WireConnection;80;628;75;0
WireConnection;81;2;75;0
WireConnection;82;0;76;0
WireConnection;83;0;77;0
WireConnection;83;1;78;0
WireConnection;84;0;80;78
WireConnection;85;0;81;0
WireConnection;86;0;79;0
WireConnection;86;1;82;0
WireConnection;87;0;79;0
WireConnection;87;1;83;0
WireConnection;89;1;71;0
WireConnection;89;2;71;0
WireConnection;89;3;71;0
WireConnection;91;0;76;0
WireConnection;91;1;81;0
WireConnection;92;0;84;0
WireConnection;92;1;85;0
WireConnection;93;0;87;0
WireConnection;93;1;86;0
WireConnection;95;0;90;0
WireConnection;95;1;89;0
WireConnection;96;0;88;0
WireConnection;96;1;93;0
WireConnection;97;0;92;0
WireConnection;97;1;91;0
WireConnection;99;0;94;0
WireConnection;102;0;101;0
WireConnection;102;1;100;4
WireConnection;103;0;102;0
WireConnection;105;0;103;0
WireConnection;108;0;105;0
WireConnection;108;1;106;0
WireConnection;104;0;96;0
WireConnection;104;1;97;0
WireConnection;104;2;95;0
WireConnection;110;0;88;0
WireConnection;110;1;79;0
WireConnection;110;2;108;0
WireConnection;107;2;104;0
WireConnection;109;0;107;6
WireConnection;112;0;108;0
WireConnection;112;2;110;0
WireConnection;112;3;110;0
WireConnection;112;4;104;0
WireConnection;113;0;108;0
WireConnection;113;1;109;0
WireConnection;111;0;98;0
WireConnection;111;1;99;0
WireConnection;0;2;104;0
WireConnection;0;10;111;0
ASEEND*/
//CHKSM=DEB1164A644B6B43C547B942655B9E2323566104