Shader "Unlit/Camo_hlsl"
{
    Properties
    {
        _PrimaryColor("PrimaryColor", Color) = (0,0,0,1)
        _SecondaryColor("SecondaryColor", Color) = (1,1,1,1)
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

            float4 _PrimaryColor;
            float4 _SecondaryColor;
            float2 hash(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xx + p3.yz) * p3.zy);
}

// Variation de noise : avec interpolation quintique
float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    float2 h0 = hash(i + float2(0.0, 0.0));
    float2 h1 = hash(i + float2(1.0, 0.0));
    float2 h2 = hash(i + float2(0.0, 1.0));
    float2 h3 = hash(i + float2(1.0, 1.0));

    float n0 = dot(h0, f - float2(0.0, 0.0));
    float n1 = dot(h1, f - float2(1.0, 0.0));
    float n2 = dot(h2, f - float2(0.0, 1.0));
    float n3 = dot(h3, f - float2(1.0, 1.0));

    float nx0 = lerp(n0, n1, u.x);
    float nx1 = lerp(n2, n3, u.x);
    float nxy = lerp(nx0, nx1, u.y);

    return nxy * 0.5 + 0.5;
}

// Variation de RotateUV : retourne aussi le sine/cosine pour réutilisation
float2 RotateUV(float2 uv, float2 center, float angle)
{
    float2 dir = uv - center;
    float cs = cos(angle), sn = sin(angle);
    return float2(dir.x * cs - dir.y * sn, dir.x * sn + dir.y * cs) + center;
}
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float n = noise(i.uv);
                float roundedNoise = round(n);
                float Mask1 = 1.0 - roundedNoise;
                fixed4 aa = roundedNoise * _PrimaryColor;
                fixed4 bb = Mask1 * _SecondaryColor;
                fixed4 res = aa + bb; 
                float2 center2 = float2(-0.07, -0.06);
                float angle2 = 1.66;
                float2 rotatedUV2 = RotateUV(i.uv, center2, angle2);
                float n2 = noise(rotatedUV2);
                float roundedNoise2 = round(n);
                float Mask2 = 1.0 - roundedNoise2 ; 
                res = Mask2 * res ;
                return res; 
                
            }
            ENDCG
        }
    }
}
