Shader "Hidden/DiffusionUpdate"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}		

	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			//sampler2D _Multiply;
			//sampler2D _Additive;

			uniform float4 _MainTex_TexelSize;
			uniform float
				_F,
				_K,
				_Da,
				_Db;

			float2 laplace(float2 uv)
			{
				float2 sum = 0;
				
				float2 offset = _MainTex_TexelSize;

				sum += tex2D(_MainTex, uv) * -1;

				sum += tex2D(_MainTex, uv + fixed2(+offset.x, 0)) * 0.2;
				sum += tex2D(_MainTex, uv + fixed2(-offset.x, 0)) * 0.2;
				sum += tex2D(_MainTex, uv + fixed2(0, +offset.y)) * 0.2;
				sum += tex2D(_MainTex, uv + fixed2(0, -offset.y)) * 0.2;

				sum += tex2D(_MainTex, uv + fixed2(+offset.x, +offset.y)) * 0.05;
				sum += tex2D(_MainTex, uv + fixed2(-offset.x, +offset.y)) * 0.05;
				sum += tex2D(_MainTex, uv + fixed2(+offset.x, -offset.y)) * 0.05;
				sum += tex2D(_MainTex, uv + fixed2(-offset.x, -offset.y)) * 0.05;

				return sum;
			}

			float2 diffuseReaction(fixed2 uv)
			{
				float2 c = tex2D(_MainTex, uv).rg;				

				float2 lap = laplace(uv);
				float rgg = c.r * c.g * c.g;
				float R = _Da * lap.r - rgg + _F*(1 - c.r);
				float G = _Db * lap.g + rgg - (_K + _F) * c.g;

				return (saturate(c + float2(R, G)));
			}

			float4 frag (v2f i) : SV_Target
			{
				/*fixed4 col = tex2D(_MainTex, i.uv);				
				col += fixed4(0.01, 0.01, 0.01, 0.01);
				col %= 1;
				return col;*/

				float2 newDifuse = diffuseReaction(i.uv);			
				//float multiply = tex2D(_Multiply, i.uv).r;
				//float add = tex2D(_Additive, i.uv).r;
				return float4(newDifuse, 0, 0);// *multiply + float4(add, add, add, add);
			}
			ENDCG
		}
	}
}
