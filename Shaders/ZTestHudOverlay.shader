Shader "!M.O.O.N/HUD/ZTestHudOverlay"
{
    Properties
    {
        [HideInInspector]_MainTex ("Reserved", 2D) = "white" {}
		[Space(10)]
		[Header(Gesture Textures)]
		[Space(10)]
		[NoScaleOffset]_Gesture1("Fist",2D) = "white" {}		//Fist
		[NoScaleOffset]_Gesture2("Hand Open",2D) = "white" {}	//Hand Open
		[NoScaleOffset]_Gesture3("Finger Point",2D) = "white" {}	//Finger Point
		[NoScaleOffset]_Gesture4("Victory",2D) = "white" {}	//Victory
		[NoScaleOffset]_Gesture5("Rock N Roll",2D) = "white" {}	//Rock N Roll
		[NoScaleOffset]_Gesture6("Hand Gun",2D) = "white" {}	//Hand Gun
		[NoScaleOffset]_Gesture7("Thumbs Up",2D) = "white" {}	//Thumbs Up
		[Toggle]_Kill("Kill HUD", Int) = 0
		[KeywordEnum(Left,Right)]_WhichHand("Which Hand?",Int) = 0
		[IntRange]_HUDIndex("HUD Gesture Index", Range(0,7)) = 0
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_PositionOffset("Position Offset", Vector) = (0,0,0.08,0)
		_RotateX("Rotate X", float) = -89
		_Scale("Scale", float) = 0.003
    }
    SubShader
    {
		Tags { "Queue" = "Overlay+2" "RenderType" = "Overlay" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "PreviewType" = "None"}
		ZWrite Off
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex,_Gesture0, _Gesture1, _Gesture2, _Gesture3, _Gesture4, _Gesture5, _Gesture6, _Gesture7;
            float4 _MainTex_ST, _TintColor;
			int _Kill, _HUDIndex, _WhichHand;
			float4 _OverlayUV_ST;
			float4 _PositionOffset;
			float _RotateX;
			float _Scale;

			float2x2 rotate(float deg) {
				float s = sin(deg);
				float c = cos(deg);
				return float2x2(c, -s, s, c);
			}

			v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				pos.zy = mul(pos.zy, rotate(_RotateX));
				pos.xyz *= _Scale;

				//Correct Rotation
				pos.y *= -1;
				pos.x *= -1;

				//Inherit UV Coords
				o.uv = TRANSFORM_TEX(uv, _MainTex);

				//Offset from camera
				float4 abspos = pos - _PositionOffset;
				o.pos = mul(UNITY_MATRIX_P, abspos);
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				if (_Kill == 1) {
					//If kill signal is recieved, ignore all pixels.
					discard;
				}
				
				float2 SavedUVs = i.uv;
				//if the hand is right, flip the image horizontally
				[branch]if (_WhichHand == 1) {
					SavedUVs = i.uv * float2(-1,1);
				}

				float4 FinalColor = 0;

				[forcecase] switch (_HUDIndex)
				{
				case 0:
					discard;
					break;
				case 1:
					FinalColor = tex2D(_Gesture1, SavedUVs);
					break;
				case 2:
					FinalColor = tex2D(_Gesture2, SavedUVs);
					break;
				case 3:
					FinalColor = tex2D(_Gesture3, SavedUVs);
					break;
				case 4:
					FinalColor = tex2D(_Gesture4, SavedUVs);
					break;
				case 5:
					FinalColor = tex2D(_Gesture5, SavedUVs);
					break;
				case 6:
					FinalColor = tex2D(_Gesture6, SavedUVs);
					break;
				case 7:
					FinalColor = tex2D(_Gesture7, SavedUVs);
					break;
				}

				return FinalColor;
            }
            ENDCG
        }
    }
}
