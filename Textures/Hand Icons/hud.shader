// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "HUD/HUD Shader"
{
    Properties
    {
        _DetailTex ("Base (RGB)", 2D) = "white" {} // VR Stereo image
		_DetailTex2 ("Non-VR (RBG)", 2D) = "white" {} // Single image for desktop users
        _alpha ("Alpha", Range (0.0, 1.0)) = 0.5
		_range ("Range (radius from center)", Range (0.0, 20.0)) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent+40" "RenderType"="Transparent" }
        LOD 100
        
        Cull off
        Zwrite Off
        
        Ztest Always
        
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass {
			//Stencil {
			//		Ref 13
			//		Comp Equal
			//		Pass Keep
			//}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 refl : TEXCOORD1;
                float4 pos : SV_POSITION;
            };
            half4 _DetailTex_ST;
            half _alpha;
			half _range;
            v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
            {
                v2f o;
				//#if UNITY_SINGLE_PASS_STEREO
				//float2 uv2 = float2(1,0) + uv*float2(-1,1);
				//uv2 = 5*uv2 - float2(2,2);
				o.uv = TRANSFORM_TEX(uv, _DetailTex);
				
				float4 dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, float4(0,0,0,1)));
				
				float4 abspos = pos + float4(0.075*(0.5-unity_StereoEyeIndex), 0, 0, 0);
				
				//float4 abspos = pos*float4(2.1,2.1,0.75,1);
				
				float4 worldPos  = mul(unity_CameraToWorld, abspos);   // Transform View to World
				float4 objectPos = mul(unity_WorldToObject, worldPos); // Transform World To Object
				
				//o.pos = UnityObjectToClipPos(pos);
				o.pos = UnityObjectToClipPos(objectPos);
				o.pos = o.pos - o.pos*step(_range, dist);
				
				
				// Multiply the x coordinate by the aspect ratio of the screen so square textures
				// aren't stretched across the entire screen. Also centers the image on the screen.
				// This distorts the textures to 1:1 aspect ratio on desktop, but for some reason
				// it distorts them to 2:1 in VR
                //o.refl = ComputeScreenPos (o.pos*float4((_ScreenParams[0]/_ScreenParams[1]),1,1,1));
				//#else
				//o.pos = float4(0,0,0,0);
				//#endif
                return o;
            }

            sampler2D _DetailTex;
			sampler2D _DetailTex2;
			
            fixed4 frag(v2f i) : SV_Target
            {                
				
				fixed4 uv;
				//#if UNITY_SINGLE_PASS_STEREO
				//#if UNITY_SINGLE_PASS_STEREO // use stereo image if in VR, otherwise use single image 
                //uv = tex2Dproj(_DetailTex, i.refl);
				//#else
				//uv = tex2Dproj(_DetailTex2, i.refl);
				//#endif
				uv = tex2D(_DetailTex2, i.uv);
               
				return uv*float4(1, 1, 1, 1);// + _alpha*float4(0, 0, 0, 1);
				//#else
				//return float4(0, 0, 0, 0);
				//#endif
				
            }
            ENDCG
        }
    }
}