// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/riftShotShader"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};


float2 voronoihash50( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi50( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash50( n + g );
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


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float time50 = 0.0;
			float2 voronoiSmoothId50 = 0;
			float2 temp_cast_0 = (_Time.y).xx;
			float2 uv_TexCoord37 = i.uv_texcoord + temp_cast_0;
			float2 coords50 = uv_TexCoord37 * 1.0;
			float2 id50 = 0;
			float2 uv50 = 0;
			float fade50 = 0.5;
			float voroi50 = 0;
			float rest50 = 0;
			for( int it50 = 0; it50 <2; it50++ ){
			voroi50 += fade50 * voronoi50( coords50, time50, id50, uv50, 0,voronoiSmoothId50 );
			rest50 += fade50;
			coords50 *= 2;
			fade50 *= 0.5;
			}//Voronoi50
			voroi50 /= rest50;
			float4 color49 = IsGammaSpace() ? float4(2.071902,1.427697,3.32549,0) : float4(4.966065,2.188767,14.06315,0);
			o.Emission = ( i.vertexColor * voroi50 * color49 ).rgb;
			float smoothstepResult52 = smoothstep( 0.0 , 0.4 , voroi50);
			float temp_output_2_0_g5 = 0.5;
			float temp_output_3_0_g5 = 0.5;
			float2 appendResult21_g5 = (float2(temp_output_2_0_g5 , temp_output_3_0_g5));
			float Radius25_g5 = max( min( min( abs( ( 0.5 * 2 ) ) , abs( temp_output_2_0_g5 ) ) , abs( temp_output_3_0_g5 ) ) , 1E-05 );
			float2 temp_cast_2 = (0.0).xx;
			float temp_output_30_0_g5 = ( length( max( ( ( abs( (i.uv_texcoord*2.0 + -1.0) ) - appendResult21_g5 ) + Radius25_g5 ) , temp_cast_2 ) ) / Radius25_g5 );
			float temp_output_28_0 = saturate( ( ( 1.0 - temp_output_30_0_g5 ) / fwidth( temp_output_30_0_g5 ) ) );
			float temp_output_2_0_g6 = 1.0;
			float temp_output_3_0_g6 = 1.0;
			float2 appendResult21_g6 = (float2(temp_output_2_0_g6 , temp_output_3_0_g6));
			float Radius25_g6 = max( min( min( abs( ( 0.5 * 2 ) ) , abs( temp_output_2_0_g6 ) ) , abs( temp_output_3_0_g6 ) ) , 1E-05 );
			float2 temp_cast_3 = (0.0).xx;
			float temp_output_30_0_g6 = ( length( max( ( ( abs( (i.uv_texcoord*2.0 + -1.0) ) - appendResult21_g6 ) + Radius25_g6 ) , temp_cast_3 ) ) / Radius25_g6 );
			float lerpResult44 = lerp( temp_output_28_0 , ( ( 1.0 - temp_output_28_0 ) * saturate( ( ( 1.0 - temp_output_30_0_g6 ) / fwidth( temp_output_30_0_g6 ) ) ) ) , voroi50);
			float smoothstepResult47 = smoothstep( 0.0 , 1.0 , ( smoothstepResult52 * lerpResult44 ));
			o.Alpha = smoothstepResult47;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.RangedFloatNode;5;-1280,400;Inherit;False;Constant;_Float7;Float 7;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;28;-1072,80;Inherit;True;Rounded Rectangle;-1;;5;8679f72f5be758f47babb3ba1d5f51d3;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1248,208;Inherit;False;Constant;_Float8;Float 8;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;40;-1344.256,-110.316;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;29;-1008,304;Inherit;True;Rounded Rectangle;-1;;6;8679f72f5be758f47babb3ba1d5f51d3;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-832,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1120,-224;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-672,240;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;50;-800,-112;Inherit;True;0;0;1;0;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.LerpOp;44;-416,544;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;52;-576,48;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;48;-544,-400;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;49;-816,-304;Inherit;False;Constant;_Color0;Color 0;0;1;[HDR];Create;True;0;0;0;False;0;False;2.071902,1.427697,3.32549,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-304,208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-382.9121,-44.88049;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;47;-144,432;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;80,-64;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Unlit/riftShotShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;28;4;5;0
WireConnection;29;2;30;0
WireConnection;29;3;30;0
WireConnection;29;4;5;0
WireConnection;31;0;28;0
WireConnection;37;1;40;0
WireConnection;22;0;31;0
WireConnection;22;1;29;0
WireConnection;50;0;37;0
WireConnection;44;0;28;0
WireConnection;44;1;22;0
WireConnection;44;2;50;0
WireConnection;52;0;50;0
WireConnection;46;0;52;0
WireConnection;46;1;44;0
WireConnection;36;0;48;0
WireConnection;36;1;50;0
WireConnection;36;2;49;0
WireConnection;47;0;46;0
WireConnection;0;2;36;0
WireConnection;0;9;47;0
ASEEND*/
//CHKSM=EB86F9BA560DDBFEF74DD98B97BFB98FD0DEA4F9