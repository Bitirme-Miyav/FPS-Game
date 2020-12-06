// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GuruToon"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_ColorMultiply("Color Multiply", Color) = (1,1,1,0)
		_HighlightSpeed("Highlight Speed", Float) = 1
		[Toggle(_HIGHLIGHTONOFF_ON)] _HighlightONOFF("Highlight ON/OFF", Float) = 0
		_HighlightColor("Highlight Color", Color) = (0.5,0.5,0.5,0)
		[Toggle(_SOLIDCOLORONOFF_ON)] _SolidColorONOFF("Solid Color ON/OFF", Float) = 0
		_SolidColor("Solid Color", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend One OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _HIGHLIGHTONOFF_ON
		#pragma shader_feature_local _SOLIDCOLORONOFF_ON
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		uniform float4 _ColorMultiply;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _SolidColor;
		uniform float4 _HighlightColor;
		uniform float _HighlightSpeed;

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 color6 = IsGammaSpace() ? float4(0.15,0.15,0.15,0) : float4(0.01960665,0.01960665,0.01960665,0);
			o.Albedo = color6.rgb;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode11 = tex2D( _MainTex, uv_MainTex );
			float grayscale92 = Luminance(tex2DNode11.rgb);
			float4 temp_cast_2 = (grayscale92).xxxx;
			float4 blendOpSrc94 = _SolidColor;
			float4 blendOpDest94 = temp_cast_2;
			#ifdef _SOLIDCOLORONOFF_ON
				float4 staticSwitch95 = (( blendOpDest94 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest94 ) * ( 1.0 - blendOpSrc94 ) ) : ( 2.0 * blendOpDest94 * blendOpSrc94 ) );
			#else
				float4 staticSwitch95 = ( _ColorMultiply * tex2DNode11 );
			#endif
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult19 = dot( ase_worldNormal , ase_worldlightDir );
			float4 temp_output_34_0 = ( staticSwitch95 * ( 1.0 - ( step( dotResult19 , 0.0 ) * 0.1 ) ) );
			float4 color81 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float mulTime87 = _Time.y * _HighlightSpeed;
			float4 lerpResult84 = lerp( color81 , _HighlightColor , (sin( mulTime87 )*0.5 + 0.5));
			#ifdef _HIGHLIGHTONOFF_ON
				float4 staticSwitch89 = ( temp_output_34_0 + lerpResult84 );
			#else
				float4 staticSwitch89 = temp_output_34_0;
			#endif
			o.Emission = staticSwitch89.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Lambert keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
Version=17800
244;142;1243;688;2440.84;1390.339;3.90709;True;False
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;17;-456.4003,-28.09747;Inherit;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;18;-466.9614,-271.0697;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;19;-178.7714,-258.3058;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-373.8486,-845.7077;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-132.5688,13.53653;Inherit;False;Constant;_Step;Step;2;0;Create;True;0;0;False;0;0;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-265.8017,513.8451;Inherit;False;Property;_HighlightSpeed;Highlight Speed;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;96;-36.31906,-1077.58;Inherit;False;Property;_ColorMultiply;Color Multiply;1;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCGrayscale;92;53.25354,-566.1131;Inherit;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;93;70.39629,-761.4819;Inherit;False;Property;_SolidColor;Solid Color;6;0;Create;True;0;0;False;0;1,1,1,0;0,0.5504584,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;32;74.98344,-274.5577;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;87;-88.18777,513.9858;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;140.3012,12.04301;Inherit;False;Constant;_StepPower;StepPower;3;0;Create;True;0;0;False;0;0.1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;232.2083,-967.6461;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;308.3191,-157.2045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;42.74566,650.6344;Inherit;False;Constant;_ScaleOffset;ScaleOffset;4;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;85;145.2596,545.0453;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;94;384.8808,-599.4099;Inherit;True;Overlay;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;82;234.4883,334.5132;Inherit;False;Property;_HighlightColor;Highlight Color;4;0;Create;True;0;0;False;0;0.5,0.5,0.5,0;0.5,0.5,0.5,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;81;234.5002,159.5911;Inherit;False;Constant;_HighlightColorBlack;Highlight Color Black;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;83;338.9365,564.7089;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;95;675.2859,-776.2213;Inherit;False;Property;_SolidColorONOFF;Solid Color ON/OFF;5;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;36;453.9773,-273.9529;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;751.7177,-311.3568;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;84;611.3742,293.8296;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;982.7859,264.845;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;89;1265.914,-10.13829;Inherit;False;Property;_HighlightONOFF;Highlight ON/OFF;3;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;6;1281.047,-260.5629;Inherit;False;Constant;_DeadColor;DeadColor;2;0;Create;True;0;0;False;0;0.15,0.15,0.15,0;0.15,0.15,0.15,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1644.785,-102.5719;Float;False;True;-1;2;ASEMaterialInspector;0;0;Lambert;GuruToon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;3;1;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;1.8;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.096;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;19;0;18;0
WireConnection;19;1;17;0
WireConnection;92;0;11;0
WireConnection;32;0;19;0
WireConnection;32;1;33;0
WireConnection;87;0;86;0
WireConnection;97;0;96;0
WireConnection;97;1;11;0
WireConnection;70;0;32;0
WireConnection;70;1;71;0
WireConnection;85;0;87;0
WireConnection;94;0;93;0
WireConnection;94;1;92;0
WireConnection;83;0;85;0
WireConnection;83;1;80;0
WireConnection;83;2;80;0
WireConnection;95;1;97;0
WireConnection;95;0;94;0
WireConnection;36;0;70;0
WireConnection;34;0;95;0
WireConnection;34;1;36;0
WireConnection;84;0;81;0
WireConnection;84;1;82;0
WireConnection;84;2;83;0
WireConnection;88;0;34;0
WireConnection;88;1;84;0
WireConnection;89;1;34;0
WireConnection;89;0;88;0
WireConnection;0;0;6;0
WireConnection;0;2;89;0
ASEEND*/
//CHKSM=34B9B86112D780FE187C7DF6A5C20F262D593008