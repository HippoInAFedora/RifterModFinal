// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "crackedGlassShader"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_Opacity("Opacity", Float) = 0.25
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustom keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float2 uv2_texcoord2;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
		};

		uniform sampler2D _Texture0;
		uniform float4 _EmissionColor;
		uniform float _Opacity;
		uniform float _Cutoff = 0.5;


float2 voronoihash24( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi24( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
	 		float2 o = voronoihash24( n + g );
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


		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float3 tex2DNode19 = UnpackNormal( tex2D( _Texture0, i.uv_texcoord ) );
			o.Normal = tex2DNode19;
			float4 tex2DNode1 = tex2D( _Texture0, i.uv_texcoord );
			o.Albedo = ( i.vertexColor * tex2DNode1 ).rgb;
			o.Emission = ( i.vertexColor * _EmissionColor ).rgb;
			o.Transmission = tex2DNode19;
			o.Alpha = _Opacity;
			float mulTime25 = _Time.y * 5.0;
			float time24 = mulTime25;
			float2 voronoiSmoothId24 = 0;
			float2 temp_cast_2 = (tex2DNode1.r).xx;
			float2 coords24 = temp_cast_2 * 1.0;
			float2 id24 = 0;
			float2 uv24 = 0;
			float fade24 = 0.5;
			float voroi24 = 0;
			float rest24 = 0;
			for( int it24 = 0; it24 <6; it24++ ){
			voroi24 += fade24 * voronoi24( coords24, time24, id24, uv24, 0,voronoiSmoothId24 );
			rest24 += fade24;
			coords24 *= 2;
			fade24 *= 0.5;
			}//Voronoi24
			voroi24 /= rest24;
			float3 temp_cast_3 = (voroi24).xxx;
			float3 temp_output_1_0_g3 = temp_cast_3;
			float3 temp_output_2_0_g3 = ddx( temp_output_1_0_g3 );
			float dotResult4_g3 = dot( temp_output_2_0_g3 , temp_output_2_0_g3 );
			float3 temp_output_3_0_g3 = ddy( temp_output_1_0_g3 );
			float dotResult5_g3 = dot( temp_output_3_0_g3 , temp_output_3_0_g3 );
			float ifLocalVar6_g3 = 0;
			if( dotResult4_g3 <= dotResult5_g3 )
				ifLocalVar6_g3 = dotResult5_g3;
			else
				ifLocalVar6_g3 = dotResult4_g3;
			clip( ( ( sqrt( ifLocalVar6_g3 ) + tex2DNode1.a ) * i.uv2_texcoord2.x ) - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.TexturePropertyNode;5;-960,32;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;b1ed3832134ed394c970303f3f74cf8a;b1ed3832134ed394c970303f3f74cf8a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexCoordVertexDataNode;18;-976,-176;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-608,0;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;25;-585.1772,415.7554;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;24;-320,448;Inherit;False;0;0;1;2;6;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.FunctionNode;22;-144,512;Inherit;True;ComputeFilterWidth;-1;;3;326bea850683cca44ae7af083d880d70;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;2;-528,-192;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;15;-528,528;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;23;96,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-144,208;Inherit;False;Property;_EmissionColor;EmissionColor;3;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.4399492,0.3728195,1.113208,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-272,-16;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;19;-608,160;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;208,544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;96,304;Inherit;False;Property;_Opacity;Opacity;1;0;Create;True;0;0;0;False;0;False;0.25;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;96,80;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;7;400,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;crackedGlassShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;1;0;-1;0;False;0;0;False;;-1;0;False;_Float0;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;5;0
WireConnection;1;1;18;0
WireConnection;1;7;5;1
WireConnection;24;0;1;1
WireConnection;24;1;25;0
WireConnection;22;1;24;0
WireConnection;23;0;22;0
WireConnection;23;1;1;4
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;19;0;5;0
WireConnection;19;1;18;0
WireConnection;19;7;5;1
WireConnection;16;0;23;0
WireConnection;16;1;15;1
WireConnection;27;0;2;0
WireConnection;27;1;10;0
WireConnection;7;0;3;0
WireConnection;7;1;19;0
WireConnection;7;2;27;0
WireConnection;7;6;19;0
WireConnection;7;9;26;0
WireConnection;7;10;16;0
ASEEND*/
//CHKSM=1DF12D8D51B36D6D45DDF564D813D01C85ADF4FD