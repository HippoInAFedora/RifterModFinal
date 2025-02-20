// Upgrade NOTE: upgraded instancing buffer 'riftInsideShaderAmplify' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "riftInsideShaderAmplify"
{
	Properties
	{
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		_Speed("Speed", Range( -0.1 , 0)) = 0
		_FresnelScaleInner("FresnelScaleInner", Float) = 0
		_FresnelPower("Fresnel Power", Range( 0 , 1)) = 0
		_FresnelScale("Fresnel Scale", Range( -1 , 1)) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
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
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
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

		UNITY_INSTANCING_BUFFER_START(riftInsideShaderAmplify)
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr riftInsideShaderAmplify
		UNITY_INSTANCING_BUFFER_END(riftInsideShaderAmplify)


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

float2 voronoihash1419( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi1419( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash1419( n + g );
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


float2 voronoihash1312( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi1312( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash1312( n + g );
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


inline float Dither4x4Bayer( int x, int y )
{
	const float dither[ 16 ] = {
		 1,  9,  3, 11,
		13,  5, 15,  7,
		 4, 12,  2, 10,
		16,  8, 14,  6 };
	int r = y * 4 + x;
	return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = i.screenPosition;
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor1451 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
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
			float4 temp_output_1443_0 = ( 1.0 - lerpResult627_g2426 );
			float mulTime1307 = _Time.y * 5.0;
			float time1419 = mulTime1307;
			float2 voronoiSmoothId1419 = 0;
			float2 coords1419 = i.uv_texcoord * 50.0;
			float2 id1419 = 0;
			float2 uv1419 = 0;
			float voroi1419 = voronoi1419( coords1419, time1419, id1419, uv1419, 0, voronoiSmoothId1419 );
			float grayscale1445 = Luminance(float3( id1419 ,  0.0 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV1449 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1449 = ( 0.0 + _FresnelScaleInner * pow( max( 1.0 - fresnelNdotV1449 , 0.0001 ), -1.2 ) );
			float clampResult1455 = clamp( fresnelNode1449 , 0.0 , 1.75 );
			float3 temp_output_1_0_g2432 = float3( id1419 ,  0.0 );
			float3 temp_output_2_0_g2432 = ddx( temp_output_1_0_g2432 );
			float dotResult4_g2432 = dot( temp_output_2_0_g2432 , temp_output_2_0_g2432 );
			float3 temp_output_3_0_g2432 = ddy( temp_output_1_0_g2432 );
			float dotResult5_g2432 = dot( temp_output_3_0_g2432 , temp_output_3_0_g2432 );
			float ifLocalVar6_g2432 = 0;
			if( dotResult4_g2432 <= dotResult5_g2432 )
				ifLocalVar6_g2432 = dotResult5_g2432;
			else
				ifLocalVar6_g2432 = dotResult4_g2432;
			float temp_output_1343_0 = sqrt( ifLocalVar6_g2432 );
			float clampResult1453 = clamp( temp_output_1343_0 , 0.0 , 0.8 );
			float4 lerpResult1450 = lerp( screenColor1451 , ( ( temp_output_1443_0 * ( grayscale1445 * clampResult1455 ) ) + ( temp_output_1443_0 * clampResult1453 ) ) , clampResult1455);
			float time1312 = 5.0;
			float2 voronoiSmoothId1312 = 0;
			float fresnelNdotV1416 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1416 = ( ( mulTime1307 * _Speed ) + _FresnelScale * pow( 1.0 - fresnelNdotV1416, _FresnelPower ) );
			float2 temp_cast_6 = (fresnelNode1416).xx;
			float2 center45_g2410 = float2( 0.5,0.5 );
			float2 delta6_g2410 = ( temp_cast_6 - center45_g2410 );
			float angle10_g2410 = ( length( delta6_g2410 ) * 0.0 );
			float x23_g2410 = ( ( cos( angle10_g2410 ) * delta6_g2410.x ) - ( sin( angle10_g2410 ) * delta6_g2410.y ) );
			float2 break40_g2410 = center45_g2410;
			float2 temp_cast_7 = (35.0).xx;
			float2 break41_g2410 = temp_cast_7;
			float y35_g2410 = ( ( sin( angle10_g2410 ) * delta6_g2410.x ) + ( cos( angle10_g2410 ) * delta6_g2410.y ) );
			float2 appendResult44_g2410 = (float2(( x23_g2410 + break40_g2410.x + break41_g2410.x ) , ( break40_g2410.y + break41_g2410.y + y35_g2410 )));
			float2 coords1312 = appendResult44_g2410 * 50.0;
			float2 id1312 = 0;
			float2 uv1312 = 0;
			float voroi1312 = voronoi1312( coords1312, time1312, id1312, uv1312, 0, voronoiSmoothId1312 );
			float2 smoothstepResult1438 = smoothstep( float2( 0.5,0.5 ) , float2( 0.8,0.8 ) , id1312);
			float2 temp_output_1432_0 = ( id1419 * smoothstepResult1438 );
			float4 screenColor16_g2433 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_1432_0);
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
			float fresnelNdotV1348 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1348 = ( 0.0 + temp_output_1432_0.x * pow( max( 1.0 - fresnelNdotV1348 , 0.0001 ), 1.0 ) );
			float clampResult1437 = clamp( fresnelNode1348 , 0.0 , 1.0 );
			float fresnelNdotV1456 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1456 = ( 0.0 + 2.0 * pow( 1.0 - fresnelNdotV1456, 4.0 ) );
			float fresnelNdotV1316 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1316 = ( smoothstepResult1438.x + smoothstepResult1438.x * pow( max( 1.0 - fresnelNdotV1316 , 0.0001 ), smoothstepResult1438.x ) );
			float4 lerpResult1336 = lerp( lerpResult1450 , ( ( ( 1.0 - lerpResult627_g2433 ) * clampResult1437 ) + ( temp_output_1343_0 * fresnelNode1348 ) ) , ( fresnelNode1456 + fresnelNode1316 ));
			float4 temp_cast_15 = (temp_output_1343_0).xxxx;
			float4 clampResult1492 = clamp( temp_output_1443_0 , float4( 0,0,0,0 ) , temp_cast_15 );
			float4 switchResult1490 = (((i.ASEIsFrontFacing>0)?(lerpResult1336):(clampResult1492)));
			o.Emission = switchResult1490.rgb;
			o.Alpha = 1;
			float2 clipScreen1385 = abs( ase_screenPosNorm.xy ) * _ScreenParams.xy;
			float dither1385 = Dither4x4Bayer( fmod(clipScreen1385.x, 4), fmod(clipScreen1385.y, 4) );
			float cameraDepthFade1406 = (( i.eyeDepth -_ProjectionParams.y - 12.0 ) / 12.0);
			dither1385 = step( dither1385, cameraDepthFade1406 );
			float switchResult1408 = (((i.ASEIsFrontFacing>0)?(i.ASEIsFrontFacing):(dither1385)));
			clip( switchResult1408 - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.SimpleTimeNode;1307;-2512,-512;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1439;-2720,-256;Inherit;False;Property;_Speed;Speed;6;0;Create;True;0;0;0;False;0;False;0;-0.0402;-0.1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1435;-2448,0;Inherit;False;Property;_FresnelPower;Fresnel Power;9;0;Create;True;0;0;0;False;0;False;0;0.062;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1418;-2320,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1434;-2448,-80;Inherit;False;Property;_FresnelScale;Fresnel Scale;10;0;Create;True;0;0;0;False;0;False;0;0.336;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1422;-2000,-16;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1416;-2144,-240;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1304;-1856,-416;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1409;-1808,-240;Inherit;True;Twirl;-1;;2410;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;1312;-1552,-240;Inherit;True;2;0;1;2;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;100;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;1458;-1424,-784;Inherit;False;Property;_FresnelScaleInner;FresnelScaleInner;7;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;1442;-1056,-1088;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;1438;-1376,-208;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT2;0.8,0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;1419;-1472,-544;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;50;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.FresnelNode;1449;-1104,-784;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.05;False;3;FLOAT;-1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1440;-800,-1088;Inherit;False;Pseudo Infrared Depth Filter;0;;2426;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1432;-1168,-336;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;1343;-784,-336;Inherit;False;ComputeFilterWidth;-1;;2432;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;1445;-1024,-912;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1455;-800,-768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1443;-464,-1088;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1329;-1008,-512;Inherit;False;Pseudo Infrared Depth Filter;0;;2433;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.FresnelNode;1348;-800,-208;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1453;-464,-592;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1447;-592,-928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1342;-656,-480;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;1437;-512,-336;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1454;-400,-768;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1444;-400,-928;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;1451;-272,-1216;Inherit;False;Global;_GrabScreen0;Grab Screen 0;7;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;1316;-832,368;Inherit;True;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1456;-832,112;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;2;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1345;-448,-176;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1428;-384,-448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1452;-224,-816;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CameraDepthFade;1406;608,32;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;12;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1457;-448,176;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1450;-48,-736;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1346;-240,-288;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FaceVariableNode;1407;688,-80;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;1385;880,32;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1336;144,-320;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;1492;528,-496;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.735849,0.735849,0.735849,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;1460;48,-1072;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;1459;48,-1248;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1461;288,-1136;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1462;432,-1136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1463;576,-1136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1465;352,-896;Inherit;False;Property;_Power;Power;8;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1464;736,-928;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1467;944,-800;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1472;544,-192;Inherit;False;Alpha Split;-1;;2439;07dab7960105b86429ac8eebd729ed6d;0;1;2;COLOR;0,0,0,0;False;2;FLOAT3;0;FLOAT;6
Node;AmplifyShaderEditor.SaturateNode;1486;992,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;1490;960,-320;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;1485;1168,-496;Inherit;False;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;1408;1104,-48;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1487;1216,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1197;2096,-352;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;riftInsideShaderAmplify;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;TransparentCutout;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;11;0;7;-1;0;False;0;0;False;;-1;0;False;_DitherDistance;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1418;0;1307;0
WireConnection;1418;1;1439;0
WireConnection;1416;1;1418;0
WireConnection;1416;2;1434;0
WireConnection;1416;3;1435;0
WireConnection;1409;1;1416;0
WireConnection;1409;4;1422;0
WireConnection;1312;0;1409;0
WireConnection;1312;2;1304;0
WireConnection;1438;0;1312;1
WireConnection;1419;1;1307;0
WireConnection;1419;2;1304;0
WireConnection;1449;2;1458;0
WireConnection;1440;628;1442;0
WireConnection;1432;0;1419;1
WireConnection;1432;1;1438;0
WireConnection;1343;1;1419;1
WireConnection;1445;0;1419;1
WireConnection;1455;0;1449;0
WireConnection;1443;0;1440;78
WireConnection;1329;628;1432;0
WireConnection;1348;2;1432;0
WireConnection;1453;0;1343;0
WireConnection;1447;0;1445;0
WireConnection;1447;1;1455;0
WireConnection;1342;0;1329;78
WireConnection;1437;0;1348;0
WireConnection;1454;0;1443;0
WireConnection;1454;1;1453;0
WireConnection;1444;0;1443;0
WireConnection;1444;1;1447;0
WireConnection;1316;1;1438;0
WireConnection;1316;2;1438;0
WireConnection;1316;3;1438;0
WireConnection;1345;0;1343;0
WireConnection;1345;1;1348;0
WireConnection;1428;0;1342;0
WireConnection;1428;1;1437;0
WireConnection;1452;0;1444;0
WireConnection;1452;1;1454;0
WireConnection;1457;0;1456;0
WireConnection;1457;1;1316;0
WireConnection;1450;0;1451;0
WireConnection;1450;1;1452;0
WireConnection;1450;2;1455;0
WireConnection;1346;0;1428;0
WireConnection;1346;1;1345;0
WireConnection;1385;0;1406;0
WireConnection;1336;0;1450;0
WireConnection;1336;1;1346;0
WireConnection;1336;2;1457;0
WireConnection;1492;0;1443;0
WireConnection;1492;2;1343;0
WireConnection;1459;0;1451;0
WireConnection;1461;0;1459;0
WireConnection;1461;1;1460;4
WireConnection;1462;0;1461;0
WireConnection;1463;0;1462;0
WireConnection;1464;0;1463;0
WireConnection;1464;1;1465;0
WireConnection;1467;0;1451;0
WireConnection;1467;1;1443;0
WireConnection;1467;2;1464;0
WireConnection;1472;2;1336;0
WireConnection;1486;0;1472;6
WireConnection;1490;0;1336;0
WireConnection;1490;1;1492;0
WireConnection;1485;0;1464;0
WireConnection;1485;2;1467;0
WireConnection;1485;3;1467;0
WireConnection;1485;4;1336;0
WireConnection;1408;0;1407;0
WireConnection;1408;1;1385;0
WireConnection;1487;0;1464;0
WireConnection;1487;1;1486;0
WireConnection;1197;2;1490;0
WireConnection;1197;10;1408;0
ASEEND*/
//CHKSM=31C70B1B401F7672573C7BDBFB98457DCF747C1B