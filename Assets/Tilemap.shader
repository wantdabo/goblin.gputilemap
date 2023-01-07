Shader "GoblinGame/GPUTilemap"
{
    Properties
    {
        _TilemapBlockRate ("_TilemapBlockRate", Float) = 1
        _SampleBlockRate ("_SampleBlockRate", Float) = 1

        _TilemapTex ("TilemapTex", 2D) = "white" {}
        _MainTex ("MainTex", 2D) = "white" {}
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

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _TilemapBlockRate; // 数据图，0 - 1 比例，4x4 就是 0.25 = 1/4
            float _SampleBlockRate; // 采样图，0 - 1 比例，2x2 就是 0.5 = 1/2

            sampler2D _MainTex; // 采样图
            float4 _MainTex_ST;

            sampler2D _TilemapTex; // 数据图
            float4 _TilemapTex_ST;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _TilemapTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 读取数据体中 rgba
                // r 表示 自身 x
                // g 表示 自身 y
                // b 表示映射采样图 x
                // a 表示映射采样图 y
                // 注意，此处的 x，y 均为贴图的左下角
                fixed4 dataTileMapCol = tex2D(_TilemapTex, i.uv);

                // 计算，mesh uv 移除自身左下角的 uv 值。
                fixed2 overflowUv = i.uv - dataTileMapCol.rg;

                // 溢出的部分，用来 / block 的缩放比例。得到缩放比例，用来映射采样图的 uv 比例。
                fixed2 scaleUv = overflowUv / _TilemapBlockRate;

                // 映射采样图比例
                fixed2 mapping2SampleUv = scaleUv * _SampleBlockRate;

                // 开始最终采样，这是一个加法，需要加上 ba 采样的 uv 偏移，以及映射的比例即可。
                fixed4 col = tex2D(_MainTex, dataTileMapCol.ba + mapping2SampleUv);

                return col;
            }
            ENDCG
        }
    }
}
