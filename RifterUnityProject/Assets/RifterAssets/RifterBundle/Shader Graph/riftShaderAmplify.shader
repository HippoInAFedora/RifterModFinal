// Upgrade NOTE: upgraded instancing buffer 'riftShaderAmplify' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "riftShaderAmplify"
{
	Properties
	{
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_CellDensity("_CellDensity", Range( 0 , 50)) = 5
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Off
		AlphaToMask On
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.0
		#pragma multi_compile_instancing
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 worldPos;
			float4 uv2_texcoord2;
			float2 uv3_texcoord3;
			float4 screenPos;
			float4 vertexColor : COLOR;
			float4 uv_texcoord;
		};

		uniform float _CellDensity;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;

		UNITY_INSTANCING_BUFFER_START(riftShaderAmplify)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color0)
#define _Color0_arr riftShaderAmplify
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr riftShaderAmplify
		UNITY_INSTANCING_BUFFER_END(riftShaderAmplify)


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


float2 voronoihash15( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi15( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash15( n + g );
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


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


float2 voronoihash760( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi760( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash760( n + g );
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


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
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


		float3 HSLtoRGB( float3 HSL, float3 RGB )
		{
			//float3 HSLtoRGB(in float3 HSL)
			  {
			   // float3 RGB = HUEtoRGB(HSL.x);
			    float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
			    return (RGB - 0.5) * C + HSL.z;
			  }
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float temp_output_129_0 = ( _CellDensity * 1.0 );
			float4 temp_cast_0 = (_Time.y).xxxx;
			float div786=256.0/float(110);
			float4 posterize786 = ( floor( temp_cast_0 * div786 ) / div786 );
			float time15 = ( posterize786 + ( _Time.y * 0.2 ) ).r;
			float2 voronoiSmoothId15 = 0;
			float voronoiSmooth15 = 0.0;
			float2 coords15 = v.texcoord2.xy * temp_output_129_0;
			float2 id15 = 0;
			float2 uv15 = 0;
			float voroi15 = voronoi15( coords15, time15, id15, uv15, voronoiSmooth15, voronoiSmoothId15 );
			float3 hsvTorgb672 = HSVToRGB( float3(0.0,0.0,id15.x) );
			float3 appendResult569 = (float3(v.texcoord.y , v.texcoord.y , v.texcoord.y));
			v.vertex.xyz += ( ( ase_vertex3Pos - v.texcoord1.xyz ) * (float3( 0.2,0.2,0.2 ) + (hsvTorgb672 - float3( 0,0,0 )) * (appendResult569 - float3( 0.2,0.2,0.2 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) );
			v.vertex.w = 1;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float simplePerlin3D64 = snoise( ( float4( ase_worldPos , 0.0 ) - v.texcoord1 ).xyz*( _CellDensity * 0.05 ) );
			simplePerlin3D64 = simplePerlin3D64*0.5 + 0.5;
			float dotResult4_g85 = dot( float2( 0,0 ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g85 = lerp( 155.0 , 255.0 , frac( ( sin( dotResult4_g85 ) * 43758.55 ) ));
			float mulTime778 = _Time.y * 5.0;
			float4 temp_cast_6 = (mulTime778).xxxx;
			float div780=256.0/float((int)lerpResult10_g85);
			float4 posterize780 = ( floor( temp_cast_6 * div780 ) / div780 );
			float time760 = posterize780.r;
			float2 voronoiSmoothId760 = 0;
			float2 coords760 = v.texcoord2.xy * temp_output_129_0;
			float2 id760 = 0;
			float2 uv760 = 0;
			float fade760 = 0.5;
			float voroi760 = 0;
			float rest760 = 0;
			for( int it760 = 0; it760 <2; it760++ ){
			voroi760 += fade760 * voronoi760( coords760, time760, id760, uv760, 0,voronoiSmoothId760 );
			rest760 += fade760;
			coords760 *= 2;
			fade760 *= 0.5;
			}//Voronoi760
			voroi760 /= rest760;
			float3 temp_output_1_0_g330 = float3( uv760 ,  0.0 );
			float dotResult4_g330 = dot( temp_output_1_0_g330 , temp_output_1_0_g330 );
			float dotResult5_g330 = dot( temp_output_1_0_g330 , temp_output_1_0_g330 );
			float ifLocalVar6_g330 = 0;
			if( dotResult4_g330 <= dotResult5_g330 )
				ifLocalVar6_g330 = dotResult5_g330;
			else
				ifLocalVar6_g330 = dotResult4_g330;
			float temp_output_61_0 = ( ( simplePerlin3D64 * 0.01 ) + sqrt( ifLocalVar6_g330 ) );
			float grayscale698 = dot(float3( id15 ,  0.0 ), float3(0.299,0.587,0.114));
			float2 temp_cast_10 = (grayscale698).xx;
			float simplePerlin2D726 = snoise( temp_cast_10 );
			float2 temp_cast_11 = (( temp_output_61_0 * simplePerlin2D726 )).xx;
			float2 temp_output_1_0_g351 = temp_cast_11;
			float dotResult4_g351 = dot( temp_output_1_0_g351 , temp_output_1_0_g351 );
			float3 appendResult10_g351 = (float3((temp_output_1_0_g351).x , (temp_output_1_0_g351).y , sqrt( ( 1.0 - saturate( dotResult4_g351 ) ) )));
			float3 normalizeResult12_g351 = normalize( appendResult10_g351 );
			v.normal = normalizeResult12_g351;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float simplePerlin3D64 = snoise( ( float4( ase_worldPos , 0.0 ) - i.uv2_texcoord2 ).xyz*( _CellDensity * 0.05 ) );
			simplePerlin3D64 = simplePerlin3D64*0.5 + 0.5;
			float temp_output_129_0 = ( _CellDensity * 1.0 );
			float dotResult4_g85 = dot( float2( 0,0 ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g85 = lerp( 155.0 , 255.0 , frac( ( sin( dotResult4_g85 ) * 43758.55 ) ));
			float mulTime778 = _Time.y * 5.0;
			float4 temp_cast_3 = (mulTime778).xxxx;
			float div780=256.0/float((int)lerpResult10_g85);
			float4 posterize780 = ( floor( temp_cast_3 * div780 ) / div780 );
			float time760 = posterize780.r;
			float2 voronoiSmoothId760 = 0;
			float2 coords760 = i.uv3_texcoord3 * temp_output_129_0;
			float2 id760 = 0;
			float2 uv760 = 0;
			float fade760 = 0.5;
			float voroi760 = 0;
			float rest760 = 0;
			for( int it760 = 0; it760 <2; it760++ ){
			voroi760 += fade760 * voronoi760( coords760, time760, id760, uv760, 0,voronoiSmoothId760 );
			rest760 += fade760;
			coords760 *= 2;
			fade760 *= 0.5;
			}//Voronoi760
			voroi760 /= rest760;
			float3 temp_output_1_0_g330 = float3( uv760 ,  0.0 );
			float3 temp_output_2_0_g330 = ddx( temp_output_1_0_g330 );
			float dotResult4_g330 = dot( temp_output_2_0_g330 , temp_output_2_0_g330 );
			float3 temp_output_3_0_g330 = ddy( temp_output_1_0_g330 );
			float dotResult5_g330 = dot( temp_output_3_0_g330 , temp_output_3_0_g330 );
			float ifLocalVar6_g330 = 0;
			if( dotResult4_g330 <= dotResult5_g330 )
				ifLocalVar6_g330 = dotResult5_g330;
			else
				ifLocalVar6_g330 = dotResult4_g330;
			float temp_output_61_0 = ( ( simplePerlin3D64 * 0.01 ) + sqrt( ifLocalVar6_g330 ) );
			float4 temp_cast_6 = (temp_output_61_0).xxxx;
			float4 _Color0_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color0_arr, _Color0);
			float _contrast_Instance = UNITY_ACCESS_INSTANCED_PROP(_contrast_arr, _contrast);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor16_g345 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 temp_output_2_0_g348 = screenColor16_g345;
			float3 temp_output_32_0_g347 = (temp_output_2_0_g348).rgb;
			float3 hsvTorgb39_g347 = RGBToHSV( temp_output_32_0_g347 );
			float3 break33_g347 = temp_output_32_0_g347;
			float dotResult30_g347 = dot( temp_output_32_0_g347 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g347 = (float3(hsvTorgb39_g347.x , ( max( break33_g347.x , max( break33_g347.y , break33_g347.z ) ) - min( break33_g347.x , min( break33_g347.y , break33_g347.z ) ) ) , dotResult30_g347));
			float3 break565_g345 = appendResult40_g347;
			float4 temp_output_2_0_g350 = ( 1.0 - screenColor16_g345 );
			float3 temp_output_32_0_g349 = (temp_output_2_0_g350).rgb;
			float3 hsvTorgb39_g349 = RGBToHSV( temp_output_32_0_g349 );
			float3 break33_g349 = temp_output_32_0_g349;
			float dotResult30_g349 = dot( temp_output_32_0_g349 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g349 = (float3(hsvTorgb39_g349.x , ( max( break33_g349.x , max( break33_g349.y , break33_g349.z ) ) - min( break33_g349.x , min( break33_g349.y , break33_g349.z ) ) ) , dotResult30_g349));
			float3 appendResult567_g345 = (float3(break565_g345.x , break565_g345.y , appendResult40_g349.z));
			float3 HSL564_g345 = appendResult567_g345;
			float3 hsvTorgb3_g346 = HSVToRGB( float3(break565_g345.x,1.0,1.0) );
			float3 RGB564_g345 = hsvTorgb3_g346;
			float3 localHSLtoRGB564_g345 = HSLtoRGB( HSL564_g345 , RGB564_g345 );
			float4 appendResult550_g345 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g345 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g345 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g345 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g345 = appendResult550_g345;
			float4 blendOpDest596_g345 = ( 1.0 - _Near );
			float4 blendOpSrc595_g345 = appendResult550_g345;
			float4 blendOpDest595_g345 = ( 1.0 - _Far );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g345 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g345 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g345 = clamp( ( ( eyeDepth185_g345 - distance( unityObjectToViewPos184_g345 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g345 = lerp( ( saturate( (( blendOpDest596_g345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g345 ) * ( 1.0 - blendOpSrc596_g345 ) ) : ( 2.0 * blendOpDest596_g345 * blendOpSrc596_g345 ) ) )) , ( saturate( (( blendOpDest595_g345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g345 ) * ( 1.0 - blendOpSrc595_g345 ) ) : ( 2.0 * blendOpDest595_g345 * blendOpSrc595_g345 ) ) )) , pow( clampResult190_g345 , _TransitionFalloff ));
			float4 temp_output_822_0 = ( 1.0 - lerpResult627_g345 );
			float4 temp_cast_11 = (_Time.y).xxxx;
			float div786=256.0/float(110);
			float4 posterize786 = ( floor( temp_cast_11 * div786 ) / div786 );
			float time15 = ( posterize786 + ( _Time.y * 0.2 ) ).r;
			float2 voronoiSmoothId15 = 0;
			float voronoiSmooth15 = 0.0;
			float2 coords15 = i.uv3_texcoord3 * temp_output_129_0;
			float2 id15 = 0;
			float2 uv15 = 0;
			float voroi15 = voronoi15( coords15, time15, id15, uv15, voronoiSmooth15, voronoiSmoothId15 );
			float grayscale698 = dot(float3( id15 ,  0.0 ), float3(0.299,0.587,0.114));
			float clampResult704 = clamp( grayscale698 , 0.0 , 0.8 );
			float3 temp_output_1_0_g329 = float3( id15 ,  0.0 );
			float3 temp_output_2_0_g329 = ddx( temp_output_1_0_g329 );
			float dotResult4_g329 = dot( temp_output_2_0_g329 , temp_output_2_0_g329 );
			float3 temp_output_3_0_g329 = ddy( temp_output_1_0_g329 );
			float dotResult5_g329 = dot( temp_output_3_0_g329 , temp_output_3_0_g329 );
			float ifLocalVar6_g329 = 0;
			if( dotResult4_g329 <= dotResult5_g329 )
				ifLocalVar6_g329 = dotResult5_g329;
			else
				ifLocalVar6_g329 = dotResult4_g329;
			float clampResult389 = clamp( ( sqrt( ifLocalVar6_g329 ) + grayscale698 ) , 0.0 , 1.0 );
			float4 break16 = i.uv_texcoord;
			clip( clampResult389 - break16.x);
			o.Emission = ( ( CalculateContrast(0.0,temp_cast_6) * _Color0_Instance * temp_output_822_0 ) + ( temp_output_822_0 * (0.0 + (clampResult704 - 0.0) * (0.8 - 0.0) / (0.8 - 0.0)) * i.vertexColor * clampResult704 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.SimpleTimeNode;785;-2272,384;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2224,-16;Inherit;False;Property;_CellDensity;_CellDensity;8;0;Create;True;0;0;0;False;0;False;5;26.2;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;786;-2048,320;Inherit;False;110;2;1;COLOR;0,0,0,0;False;0;INT;110;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;791;-2048,464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;778;-2144,-256;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;781;-2128,-160;Inherit;False;Random Range;-1;;85;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;155;False;3;FLOAT;255;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;673;-2192,-896;Inherit;False;1227;603;;6;222;223;224;130;64;71;Noise Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-1856,224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;638;-1872,48;Inherit;False;2;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;789;-1866.7,373.9921;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;780;-1808,-160;Inherit;False;206;2;1;COLOR;0,0,0,0;False;0;INT;206;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;223;-2112,-848;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;222;-2128,-688;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;675;-880,-432;Inherit;False;1364;579;;13;362;388;119;389;386;698;704;726;822;905;910;911;915;Alpha and Emissions;1,1,1,1;0;0
Node;AmplifyShaderEditor.VoronoiNode;15;-1632,160;Inherit;True;1;1;1;2;1;False;1;False;True;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;7;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.VoronoiNode;760;-1568,-112;Inherit;False;1;1;1;2;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;224;-1776,-704;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1776,-432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;698;-864,-16;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;775;-1232,-240;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;64;-1488,-720;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;362;-864,-304;Inherit;True;ComputeFilterWidth;-1;;329;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;910;-352,-480;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;761;-864,-576;Inherit;False;ComputeFilterWidth;-1;;330;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1200,-720;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;676;-912,208;Inherit;False;1246.064;589.9991;;6;18;73;679;88;16;834;Misc Alpha and Emissions (Fresnels);1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;89;-1392,656;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;388;-480,-32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-432,-720;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;16;-832,272;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;389;-320,0;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;704;-320,-224;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;674;-912,880;Inherit;False;1194.934;740.7622;;6;650;221;216;672;693;692;Vertex Displacement;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;678;-1392,976;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;905;32,-368;Inherit;False;Pseudo Infrared Depth Filter;1;;345;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.NoiseGeneratorNode;726;-576,-304;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;896;-464,-944;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;119;128,-256;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;3;FLOAT;0;False;4;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;834;160,256;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;822;336,-368;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;888;256,-880;Inherit;False;InstancedProperty;_Color0;Color 0;7;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;4.855478,4.248543,4.32441,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClipNode;386;272,-32;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;672;-864,1232;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;569;-1072,1376;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;650;-512,928;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;693;-512,1072;Inherit;False;1;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;889;624,-944;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;802;608,-160;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;692;-192,1088;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;216;-432,1232;Inherit;True;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;3;FLOAT3;0.2,0.2,0.2;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;689;0,-720;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;915;-272,-320;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;911;-109.4688,-344.9411;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;891;912,-192;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;684;240,-720;Inherit;True;Normal Reconstruct Z;-1;;351;63ba85b764ae0c84ab3d698b86364ae9;0;1;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;679;-816,448;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;88;-848,624;Inherit;False;1;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-528,640;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;18;-288,464;Inherit;False;Standard;WorldNormal;ViewDir;True;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;5;False;3;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;16,1184;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;902;1408,-208;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;riftShaderAmplify;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Overlay;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;True;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;786;1;785;0
WireConnection;791;0;785;0
WireConnection;129;0;12;0
WireConnection;789;0;786;0
WireConnection;789;1;791;0
WireConnection;780;1;778;0
WireConnection;780;0;781;0
WireConnection;15;0;638;0
WireConnection;15;1;789;0
WireConnection;15;2;129;0
WireConnection;760;0;638;0
WireConnection;760;1;780;0
WireConnection;760;2;129;0
WireConnection;224;0;223;0
WireConnection;224;1;222;0
WireConnection;130;0;12;0
WireConnection;698;0;15;1
WireConnection;775;0;760;2
WireConnection;64;0;224;0
WireConnection;64;1;130;0
WireConnection;362;1;15;1
WireConnection;761;1;775;0
WireConnection;71;0;64;0
WireConnection;388;0;362;0
WireConnection;388;1;698;0
WireConnection;61;0;71;0
WireConnection;61;1;761;0
WireConnection;16;0;89;0
WireConnection;389;0;388;0
WireConnection;704;0;698;0
WireConnection;678;0;15;1
WireConnection;905;628;910;0
WireConnection;726;0;698;0
WireConnection;896;1;61;0
WireConnection;119;0;704;0
WireConnection;822;0;905;78
WireConnection;386;0;704;0
WireConnection;386;1;389;0
WireConnection;386;2;16;0
WireConnection;672;2;678;0
WireConnection;569;0;89;2
WireConnection;569;1;89;2
WireConnection;569;2;89;2
WireConnection;889;0;896;0
WireConnection;889;1;888;0
WireConnection;889;2;822;0
WireConnection;802;0;822;0
WireConnection;802;1;119;0
WireConnection;802;2;834;0
WireConnection;802;3;386;0
WireConnection;692;0;650;0
WireConnection;692;1;693;0
WireConnection;216;0;672;0
WireConnection;216;4;569;0
WireConnection;689;0;61;0
WireConnection;689;1;726;0
WireConnection;915;0;726;0
WireConnection;915;1;726;0
WireConnection;915;2;726;0
WireConnection;915;3;726;0
WireConnection;911;0;910;0
WireConnection;911;1;915;0
WireConnection;891;0;889;0
WireConnection;891;1;802;0
WireConnection;684;1;689;0
WireConnection;73;0;679;0
WireConnection;73;1;88;0
WireConnection;18;0;73;0
WireConnection;18;2;16;2
WireConnection;221;0;692;0
WireConnection;221;1;216;0
WireConnection;902;2;891;0
WireConnection;902;11;221;0
WireConnection;902;12;684;0
ASEEND*/
//CHKSM=A8409CF924925D5689B11BEF8B2F80A3921954E8