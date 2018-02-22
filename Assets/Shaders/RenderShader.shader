Shader "Custom/RenderShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Offset("Offset", float) = 1
						
		_NormalStrength ("Normal strength", float)= 1				
		_Color0			("color 0", Color)= (0, 0, 0)	
		_Color1			("color 1", Color)= (1, 1, 1)	
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		float2 _MainTex_TexelSize;

		struct Input {
			float2 uv_MainTex;
		};

		float _NormalStrength = 1;
		float3 
			_Color0 = float3(0, 0, 0),
			_Color1 = float3(1, 1, 1);

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END
			

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float3 duv = float3(_MainTex_TexelSize.xy, 0);

			half v0 = tex2D(_MainTex, IN.uv_MainTex).r;
			half v1 = tex2D(_MainTex, IN.uv_MainTex - duv.xz).y;
			half v2 = tex2D(_MainTex, IN.uv_MainTex + duv.xz).y;
			half v3 = tex2D(_MainTex, IN.uv_MainTex - duv.zy).y;
			half v4 = tex2D(_MainTex, IN.uv_MainTex + duv.zy).y;
						
			half p = smoothstep(0, 1, v0);

			o.Albedo = lerp(_Color0.rgb, _Color1.rgb, p);

			o.Normal = normalize(float3(v1 - v2, v3 - v4, 1 - _NormalStrength));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
