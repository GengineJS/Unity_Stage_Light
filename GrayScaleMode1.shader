// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/GrayScaleMode1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (0.5,0.5,0.5,1.0)
        _ColorStrength("Color Strength", Range(1,8)) = 1
        _EmissionTex ("Emission Texture", 2D) = "white" {}
        _EmissionColor ("Emission Color", Color) = (0.5,0.5,0.5,1.0)
        _EmissionStrength("Emission Strength", Range(1,8)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 w_p: TEXCOORD1;
                float2 uv2: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _EmissionTex;
            float4 _EmissionTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.w_p = mul(unity_ObjectToWorld, v.vertex),
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _EmissionTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            uniform float4 _Position;
            uniform half _Radius;
            uniform half _Softness;
            half _ColorStrength;
            half _EmissionStrength;
            
            fixed4 _MainColor;
            fixed4 _EmissionColor;
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                fixed4 emissionCol = tex2D(_EmissionTex, i.uv2) * _EmissionColor * _EmissionStrength;
                fixed val = 0.299*col.r+0.578*col.g+0.114*col.b;
                fixed3 grayScale = fixed3(val, val, val);
                half d = saturate((_Radius - distance(_Position.xyz, i.w_p.xyz))/_Softness);
                col = lerp(fixed4(grayScale,1.0),col * _ColorStrength, d);
                col += lerp(fixed4(grayScale,1.0),emissionCol, d)
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
