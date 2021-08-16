//Reference : UnityTechnologies/BoatAttack

Shader "WaterFX"
{
    Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			Name "WaterFX"
			Tags{"LightMode" = "WaterFX"}
			HLSLPROGRAM
			#pragma vertex WaterFXVertex
			#pragma fragment WaterFXFragment
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				half4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float2 uv : TEXCOORD0;
				half3 normal : TEXCOORD1;    
    			half3 tangent : TEXCOORD2;    
    			half3 bitangent : TEXCOORD3;    
				half4 color : TEXCOORD4;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			
			Varyings WaterFXVertex (Attributes input)
			{
				Varyings output = (Varyings)0;
				
				VertexPositionInputs vertexPosition = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs vertexTBN = GetVertexNormalInputs(input.normalOS, input.tangentOS);
				
				output.vertex = vertexPosition.positionCS;
				
				output.uv = input.uv;

				output.color = input.color;

                output.normal = vertexTBN.normalWS;
                output.tangent = vertexTBN.tangentWS;
                output.bitangent = vertexTBN.bitangentWS;

				return output;
			}
			
			half4 WaterFXFragment (Varyings input) : SV_Target
			{
				half4 col = tex2D(_MainTex, input.uv);
				half3 tNormal = half3(col.r, col.g, col.b) * 2 - 1;
				half3 normalWS = TransformTangentToWorld(tNormal, half3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz));

				half4 comp = half4(normalWS.xyz, input.color.a * col.a);

				return comp;
			}
			ENDHLSL
		}
	}
}
