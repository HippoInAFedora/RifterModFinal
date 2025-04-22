// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/wanderShader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0
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
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha noshadow 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 worldPos;
			float4 uv2_texcoord2;
			float2 uv_texcoord;
		};

		uniform float _CellDensity;
		uniform sampler2D _Texture0;
		uniform float _Speed;
		uniform float _Clip;
		uniform float _Cutoff = 0;


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


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
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
			float3 temp_output_1_0_g362 = float3( id21 ,  0.0 );
			float3 temp_output_2_0_g362 = ddx( temp_output_1_0_g362 );
			float dotResult4_g362 = dot( temp_output_2_0_g362 , temp_output_2_0_g362 );
			float3 temp_output_3_0_g362 = ddy( temp_output_1_0_g362 );
			float dotResult5_g362 = dot( temp_output_3_0_g362 , temp_output_3_0_g362 );
			float ifLocalVar6_g362 = 0;
			if( dotResult4_g362 <= dotResult5_g362 )
				ifLocalVar6_g362 = dotResult5_g362;
			else
				ifLocalVar6_g362 = dotResult4_g362;
			float temp_output_29_0 = ( ( gradientNoise22 * 0.01 ) + sqrt( ifLocalVar6_g362 ) );
			float4 temp_cast_4 = (temp_output_29_0).xxxx;
			o.Emission = CalculateContrast(0.0,temp_cast_4).rgb;
			o.Alpha = 1;
			float grayscale30 = Luminance(float3( uv21 ,  0.0 ));
			float clampResult37 = clamp( grayscale30 , 0.0 , 0.8 );
			clip( ( temp_output_29_0 + grayscale30 ) - _Clip);
			clip( clampResult37 - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.RangedFloatNode;1;-3270.667,90.30878;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;0;0.0205;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;4;-2566.667,-741.6912;Inherit;False;1227;603;;9;25;22;17;15;14;10;7;6;5;Noise Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;2;-2950.667,90.30878;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2832,224;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-2534.667,-181.6912;Inherit;True;Property;_Texture0;Texture 0;8;0;Create;True;0;0;0;False;0;False;1b0165733eeed2d499806cdd83d6319f;1f3b77d4458146d459aec2757eab4b5e;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;10;-2502.667,-277.6912;Inherit;False;Property;_CellDensity;_CellDensity;10;0;Create;True;0;0;0;False;0;False;5;689;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;11;-2582.667,42.30878;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-2486.667,-693.6912;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;7;-2502.667,-533.6912;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2150.667,-277.6912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-2294.667,-181.6912;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-2150.667,-549.6912;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VoronoiNode;21;-1766.668,-101.6912;Inherit;True;1;1;1;2;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.NoiseGeneratorNode;22;-1862.668,-565.6912;Inherit;True;Gradient;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1574.668,-565.6912;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;26;-1520,-64;Inherit;False;ComputeFilterWidth;-1;;362;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;30;-1300.778,504.0434;Inherit;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1222.668,-69.69122;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;37;-886.6676,394.3088;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1078.668,666.3088;Inherit;False;Property;_Clip;Clip;9;0;Create;True;0;0;0;False;0;False;0;0.293;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-918.6676,538.3088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;50;-1248,-432;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;32;-998.6676,-421.6912;Inherit;False;Pseudo Infrared Depth Filter;1;;356;4bc39d876d298f146ab93bfb360a07ba;0;1;628;FLOAT2;0,0;False;1;COLOR;78
Node;AmplifyShaderEditor.SimpleContrastOpNode;34;-934.6676,-181.6912;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;49;-546.5303,-256.2576;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;42;-512,496;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;-554.4487,386.3096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-208,-288;Float;False;True;-1;4;ASEMaterialInspector;0;0;Standard;Custom/wanderShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0;True;False;0;True;Transparent;;Overlay;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;11;0;3;0
WireConnection;11;2;2;0
WireConnection;17;0;10;0
WireConnection;14;0;5;0
WireConnection;14;1;11;0
WireConnection;14;7;5;1
WireConnection;15;0;6;0
WireConnection;15;1;7;0
WireConnection;21;0;14;0
WireConnection;21;2;17;0
WireConnection;22;0;15;0
WireConnection;25;0;22;0
WireConnection;26;1;21;1
WireConnection;30;0;21;2
WireConnection;29;0;25;0
WireConnection;29;1;26;0
WireConnection;37;0;30;0
WireConnection;36;0;29;0
WireConnection;36;1;30;0
WireConnection;32;628;50;0
WireConnection;34;1;29;0
WireConnection;49;0;32;78
WireConnection;42;0;37;0
WireConnection;42;1;36;0
WireConnection;42;2;35;0
WireConnection;47;0;37;0
WireConnection;0;2;34;0
WireConnection;0;10;42;0
ASEEND*/
//CHKSM=23851EE36D75F67CD03627B2D17913F05C12A4F0