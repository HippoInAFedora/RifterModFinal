// Upgrade NOTE: upgraded instancing buffer 'sideShaderAmplifyEnemyLayeryLayer' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "sideShaderAmplifyEnemyLayeryLayer"
{
	Properties
	{
		[HDR]_Color0("Color 0", Color) = (4.454902,0,0,0)
		_TransitionDistance("TransitionDistance", Float) = 1
		_TransitionFalloff("TransitionFalloff", Float) = 2
		_Near("Near", Color) = (0,0,0,0)
		_Far("Far", Color) = (0,0,0,0)
		_contrast("contrast", Range( 0 , 2)) = 0.7789362
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
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
		#pragma surface surf Unlit keepalpha noshadow exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float2 uv3_texcoord3;
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
			float4 screenPos;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _Near;
		uniform float4 _Far;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;

		UNITY_INSTANCING_BUFFER_START(sideShaderAmplifyEnemyLayeryLayer)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color0)
#define _Color0_arr sideShaderAmplifyEnemyLayeryLayer
			UNITY_DEFINE_INSTANCED_PROP(float, _contrast)
#define _contrast_arr sideShaderAmplifyEnemyLayeryLayer
		UNITY_INSTANCING_BUFFER_END(sideShaderAmplifyEnemyLayeryLayer)


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


float2 voronoihash52( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi52( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash52( n + g );
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


float2 voronoihash40( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi40( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash40( n + g );
			o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
			float d = max(abs(r.x), abs(r.y));
	 		if( d<F1 ) {
	 			F2 = F1;
	 			F1 = d; mg = g; mr = r; id = o;
	 		} else if( d<F2 ) {
	 			F2 = d;
	
	 		}
	 	}
	}
	return F2;
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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float dotResult4_g172 = dot( float2( 0,0 ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g172 = lerp( 155.0 , 255.0 , frac( ( sin( dotResult4_g172 ) * 43758.55 ) ));
			float mulTime49 = _Time.y * 10.0;
			float4 temp_cast_1 = (mulTime49).xxxx;
			float div51=256.0/float((int)lerpResult10_g172);
			float4 posterize51 = ( floor( temp_cast_1 * div51 ) / div51 );
			float time52 = posterize51.r;
			float2 voronoiSmoothId52 = 0;
			float2 coords52 = v.texcoord2.xy * 10.0;
			float2 id52 = 0;
			float2 uv52 = 0;
			float voroi52 = voronoi52( coords52, time52, id52, uv52, 0, voronoiSmoothId52 );
			float3 hsvTorgb64 = HSVToRGB( float3(0.0,0.0,id52.x) );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float fresnelNdotV59 = dot( ase_worldNormal, float3( v.texcoord2.xy ,  0.0 ) );
			float fresnelNode59 = ( 0.0 + 3.0 * pow( 1.0 - fresnelNdotV59, 2.0 ) );
			v.vertex.xyz += ( ( ase_vertex3Pos - v.texcoord1.xyz ) * (float3( 0.1,0.1,0.1 ) + (hsvTorgb64 - float3( 0,0,0 )) * (float3( 1.2,1.2,1.2 ) - float3( 0.1,0.1,0.1 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) * fresnelNode59 );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float dotResult4_g172 = dot( float2( 0,0 ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g172 = lerp( 155.0 , 255.0 , frac( ( sin( dotResult4_g172 ) * 43758.55 ) ));
			float mulTime49 = _Time.y * 10.0;
			float4 temp_cast_1 = (mulTime49).xxxx;
			float div51=256.0/float((int)lerpResult10_g172);
			float4 posterize51 = ( floor( temp_cast_1 * div51 ) / div51 );
			float time52 = posterize51.r;
			float2 voronoiSmoothId52 = 0;
			float2 coords52 = i.uv3_texcoord3 * 10.0;
			float2 id52 = 0;
			float2 uv52 = 0;
			float voroi52 = voronoi52( coords52, time52, id52, uv52, 0, voronoiSmoothId52 );
			float3 temp_output_1_0_g174 = float3( uv52 ,  0.0 );
			float3 temp_output_2_0_g174 = ddx( temp_output_1_0_g174 );
			float dotResult4_g174 = dot( temp_output_2_0_g174 , temp_output_2_0_g174 );
			float3 temp_output_3_0_g174 = ddy( temp_output_1_0_g174 );
			float dotResult5_g174 = dot( temp_output_3_0_g174 , temp_output_3_0_g174 );
			float ifLocalVar6_g174 = 0;
			if( dotResult4_g174 <= dotResult5_g174 )
				ifLocalVar6_g174 = dotResult5_g174;
			else
				ifLocalVar6_g174 = dotResult4_g174;
			float temp_output_54_0 = sqrt( ifLocalVar6_g174 );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV59 = dot( ase_worldNormal, float3( i.uv3_texcoord3 ,  0.0 ) );
			float fresnelNode59 = ( 0.0 + 3.0 * pow( 1.0 - fresnelNdotV59, 2.0 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float time40 = 5.0;
			float2 voronoiSmoothId40 = 0;
			float2 center45_g171 = float2( 0.5,0.5 );
			float2 delta6_g171 = ( i.uv_texcoord - center45_g171 );
			float angle10_g171 = ( length( delta6_g171 ) * 0.2 );
			float x23_g171 = ( ( cos( angle10_g171 ) * delta6_g171.x ) - ( sin( angle10_g171 ) * delta6_g171.y ) );
			float2 break40_g171 = center45_g171;
			float4 temp_cast_5 = (_Time.y).xxxx;
			float div44=256.0/float(66);
			float4 posterize44 = ( floor( temp_cast_5 * div44 ) / div44 );
			float4 temp_cast_6 = (_Time.y).xxxx;
			float div45=256.0/float(212);
			float4 posterize45 = ( floor( temp_cast_6 * div45 ) / div45 );
			float2 break41_g171 = ( posterize44 + posterize45 ).rg;
			float y35_g171 = ( ( sin( angle10_g171 ) * delta6_g171.x ) + ( cos( angle10_g171 ) * delta6_g171.y ) );
			float2 appendResult44_g171 = (float2(( x23_g171 + break40_g171.x + break41_g171.x ) , ( break40_g171.y + break41_g171.y + y35_g171 )));
			float2 coords40 = appendResult44_g171 * 5.0;
			float2 id40 = 0;
			float2 uv40 = 0;
			float fade40 = 0.5;
			float voroi40 = 0;
			float rest40 = 0;
			for( int it40 = 0; it40 <8; it40++ ){
			voroi40 += fade40 * voronoi40( coords40, time40, id40, uv40, 0,voronoiSmoothId40 );
			rest40 += fade40;
			coords40 *= 2;
			fade40 *= 0.5;
			}//Voronoi40
			voroi40 /= rest40;
			float4 temp_cast_8 = (voroi40).xxxx;
			float depthDecodedVal41 = 0;
			float3 normalDecodedVal41 = float3(0,0,0);
			DecodeDepthNormal( temp_cast_8, depthDecodedVal41, normalDecodedVal41 );
			float4 objectToClip7_g173 = UnityObjectToClipPos(( ase_vertex3Pos + normalDecodedVal41 ));
			float3 objectToClip7_g173NDC = objectToClip7_g173.xyz/objectToClip7_g173.w;
			float4 appendResult13_g173 = (float4(objectToClip7_g173NDC , 1.0));
			float4 computeScreenPos10_g173 = ComputeScreenPos( appendResult13_g173 );
			float4 screenColor43 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,computeScreenPos10_g173.xy/computeScreenPos10_g173.w);
			float4 _Color0_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color0_arr, _Color0);
			float4 temp_cast_9 = (( 1.0 - temp_output_54_0 )).xxxx;
			clip( screenColor43 - temp_cast_9);
			float _contrast_Instance = UNITY_ACCESS_INSTANCED_PROP(_contrast_arr, _contrast);
			float4 screenColor16_g175 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,float2( 0,0 ));
			float4 temp_output_2_0_g178 = screenColor16_g175;
			float3 temp_output_32_0_g177 = (temp_output_2_0_g178).rgb;
			float3 hsvTorgb39_g177 = RGBToHSV( temp_output_32_0_g177 );
			float3 break33_g177 = temp_output_32_0_g177;
			float dotResult30_g177 = dot( temp_output_32_0_g177 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g177 = (float3(hsvTorgb39_g177.x , ( max( break33_g177.x , max( break33_g177.y , break33_g177.z ) ) - min( break33_g177.x , min( break33_g177.y , break33_g177.z ) ) ) , dotResult30_g177));
			float3 break565_g175 = appendResult40_g177;
			float4 temp_output_2_0_g180 = ( 1.0 - screenColor16_g175 );
			float3 temp_output_32_0_g179 = (temp_output_2_0_g180).rgb;
			float3 hsvTorgb39_g179 = RGBToHSV( temp_output_32_0_g179 );
			float3 break33_g179 = temp_output_32_0_g179;
			float dotResult30_g179 = dot( temp_output_32_0_g179 , float3(0.299,0.587,0.114) );
			float3 appendResult40_g179 = (float3(hsvTorgb39_g179.x , ( max( break33_g179.x , max( break33_g179.y , break33_g179.z ) ) - min( break33_g179.x , min( break33_g179.y , break33_g179.z ) ) ) , dotResult30_g179));
			float3 appendResult567_g175 = (float3(break565_g175.x , break565_g175.y , appendResult40_g179.z));
			float3 HSL564_g175 = appendResult567_g175;
			float3 hsvTorgb3_g176 = HSVToRGB( float3(break565_g175.x,1.0,1.0) );
			float3 RGB564_g175 = hsvTorgb3_g176;
			float3 localHSLtoRGB564_g175 = HSLtoRGB( HSL564_g175 , RGB564_g175 );
			float4 appendResult550_g175 = (float4(CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g175 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g175 , 0.0 )).r , CalculateContrast(_contrast_Instance,float4( localHSLtoRGB564_g175 , 0.0 )).r , 0.0));
			float4 blendOpSrc596_g175 = appendResult550_g175;
			float4 blendOpDest596_g175 = ( 1.0 - _Near );
			float4 blendOpSrc595_g175 = appendResult550_g175;
			float4 blendOpDest595_g175 = ( 1.0 - _Far );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth185_g175 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float3 unityObjectToViewPos184_g175 = UnityObjectToViewPos( float3( 0,0,0 ) );
			float clampResult190_g175 = clamp( ( ( eyeDepth185_g175 - distance( unityObjectToViewPos184_g175 , float3( 0,0,0 ) ) ) / _TransitionDistance ) , 0.0 , 1.0 );
			float4 lerpResult627_g175 = lerp( ( saturate( (( blendOpDest596_g175 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest596_g175 ) * ( 1.0 - blendOpSrc596_g175 ) ) : ( 2.0 * blendOpDest596_g175 * blendOpSrc596_g175 ) ) )) , ( saturate( (( blendOpDest595_g175 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest595_g175 ) * ( 1.0 - blendOpSrc595_g175 ) ) : ( 2.0 * blendOpDest595_g175 * blendOpSrc595_g175 ) ) )) , pow( clampResult190_g175 , _TransitionFalloff ));
			o.Emission = ( ( temp_output_54_0 * fresnelNode59 * screenColor43 * _Color0_Instance ) * ( 1.0 - lerpResult627_g175 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.SimpleTimeNode;38;-2576,720;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;44;-2352,720;Inherit;False;66;2;1;COLOR;0,0,0,0;False;0;INT;66;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;45;-2352,848;Inherit;False;212;2;1;COLOR;0,0,0,0;False;0;INT;212;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2077.65,627.4942;Inherit;False;Constant;_Float2;Float 1;0;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-2096,736;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;39;-1885.65,627.4942;Inherit;True;Twirl;-1;;171;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;50;-1690.007,275.1591;Inherit;False;Random Range;-1;;172;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;155;False;3;FLOAT;255;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;49;-1706.007,179.1591;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;40;-1597.65,627.4942;Inherit;True;0;3;1;1;8;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;5;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.PosterizeNode;51;-1370.007,275.1591;Inherit;False;206;2;1;COLOR;0,0,0,0;False;0;INT;206;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;76;-1392,112;Inherit;False;2;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DecodeDepthNormalNode;41;-1389.65,627.4942;Inherit;False;1;0;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT3;1
Node;AmplifyShaderEditor.VoronoiNode;52;-1130.007,323.1591;Inherit;True;0;0;1;2;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.FunctionNode;42;-1101.65,643.4942;Inherit;True;Custom Screen Position;-1;;173;35530643343074e4bb5fb02a7011bd50;2,9,0,12,0;2;6;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1200,1088;Inherit;False;1194.934;740.7622;;6;71;69;68;66;65;64;Vertex Displacement;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;43;-800,656;Inherit;False;Global;_GrabScreen2;Grab Screen 0;1;0;Create;True;0;0;0;False;0;False;Object;-1;False;True;False;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;59;-912,192;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;3;False;3;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;54;-901.2537,440.1501;Inherit;False;ComputeFilterWidth;-1;;174;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;-768,848;Inherit;False;InstancedProperty;_Color0;Color 0;0;1;[HDR];Create;True;0;0;0;False;0;False;4.454902,0,0,0;1.059274,0.9317172,0.948355,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.HSVToRGBNode;64;-944,1440;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;66;-800,1120;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;65;-816,1280;Inherit;False;1;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-480,400;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;80;-644.1334,539.3875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;82;-368,832;Inherit;False;Pseudo Infrared Depth Filter;2;;175;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-480,1296;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;69;-720,1440;Inherit;True;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;3;FLOAT3;0.1,0.1,0.1;False;4;FLOAT3;1.2,1.2,1.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClipNode;78;-176,624;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;83;-32,832;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-272,1392;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;79;-144,336;Inherit;False;Constant;_Color1;Color 1;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;208,624;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;464,576;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;sideShaderAmplifyEnemyLayeryLayer;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Overlay;ForwardOnly;12;all;True;True;True;True;0;False;;False;3;False;;255;False;;255;False;;5;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;44;1;38;0
WireConnection;45;1;38;0
WireConnection;48;0;44;0
WireConnection;48;1;45;0
WireConnection;39;3;37;0
WireConnection;39;4;48;0
WireConnection;40;0;39;0
WireConnection;51;1;49;0
WireConnection;51;0;50;0
WireConnection;41;0;40;0
WireConnection;52;0;76;0
WireConnection;52;1;51;0
WireConnection;42;3;41;1
WireConnection;43;0;42;0
WireConnection;59;4;76;0
WireConnection;54;1;52;2
WireConnection;64;2;52;1
WireConnection;56;0;54;0
WireConnection;56;1;59;0
WireConnection;56;2;43;0
WireConnection;56;3;73;0
WireConnection;80;0;54;0
WireConnection;68;0;66;0
WireConnection;68;1;65;0
WireConnection;69;0;64;0
WireConnection;78;0;56;0
WireConnection;78;1;43;0
WireConnection;78;2;80;0
WireConnection;83;0;82;78
WireConnection;71;0;68;0
WireConnection;71;1;69;0
WireConnection;71;2;59;0
WireConnection;81;0;78;0
WireConnection;81;1;83;0
WireConnection;0;2;81;0
WireConnection;0;11;71;0
ASEEND*/
//CHKSM=A1C12AB38D26A76C7D5A49978B89DDEDC5F4718B