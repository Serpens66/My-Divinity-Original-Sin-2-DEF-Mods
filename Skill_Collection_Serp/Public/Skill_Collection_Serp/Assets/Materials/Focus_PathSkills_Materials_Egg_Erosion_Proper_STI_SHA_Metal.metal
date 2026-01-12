//[Vertex shader]


#define __HAVE_MATRIX_MULTIPLE_SCALAR_CONSTRUCTORS__
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/GlobalConstants_MTL.shdh"
#include "Shaders/GlobalConstants_PS_MTL.shdh"

typedef struct
{
	float3 Position SV_POSITION0;
	float4 InstanceMatrix1 COLOR1;
	float4 InstanceMatrix2 COLOR2;
	float4 InstanceMatrix3 COLOR3;
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float4 WorldPosition;
	float ShadowDepth;
} VertexOutput;


vertex VertexOutput Materials_Focus_PathSkills_Materials_Egg_Erosion_Proper_STI_SHA_Metal_vertexMain(constant PerView& perView [[buffer(5)]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	//Create Instance World Matrix
	float4 col1 = float4(In.InstanceMatrix1.x, In.InstanceMatrix1.y, In.InstanceMatrix1.z, 0.0f);
	float4 col2 = float4(In.InstanceMatrix1.w, In.InstanceMatrix2.x, In.InstanceMatrix2.y, 0.0f);
	float4 col3 = float4(In.InstanceMatrix2.z, In.InstanceMatrix2.w, In.InstanceMatrix3.x, 0.0f);
	float4 col4 = float4(In.InstanceMatrix3.y, In.InstanceMatrix3.z, In.InstanceMatrix3.w, 1.0f);
	float4x4 WorldMatrix = float4x4(col1, col2, col3, col4);

	//World space position
	float4 worldPosition = (WorldMatrix * float4(In.Position, 1.0f));

	//Projected position
	float4 projectedPosition = (perView.global_ViewProjection * worldPosition);

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	Out.TexCoords0 = In.TexCoords0;
	//Pass world position to pixel shader
	Out.WorldPosition = worldPosition;

	float vertexDepth;
	vertexDepth = distance(worldPosition.xyz, perView.global_ViewPos.xyz);
	//Pass depth to pixel shader
	Out.ShadowDepth = vertexDepth;


	return Out;
}


//[Fragment shader]



typedef struct
{
	float4 Color0 [[color(0)]];
} PixelOutput;

struct LocalUniformsPS
{
	float FloatParameter_SeeThroughEnabled;
};

static void CalculateMatOpacity(constant LocalUniformsPS& uniforms,
	constant EoCGlobalConstantData& eocGlobal,
	float2 in_0,
	float3 in_1,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_basecolor_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float Local1 = Local0.w;
	float4 Local2 = float4(0.0f, 0.0f, 0.0f, 0.0f);
	if(uniforms.FloatParameter_SeeThroughEnabled > 1.0f)
	{
		Local2 = float4(1.0f, 1.0f, 1.0f, 1.0f);
	}
	else if(uniforms.FloatParameter_SeeThroughEnabled == 1.0f)
	{
		float4 Local3 = Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler.sample(_DefaultWrapSampler, (in_0 * float2(2.0f, 2.0f)));
		//[Local3] Get needed components
		float Local4 = Local3.x;
		float Local5 = (Local4 * 2.0f);
		float Local6 = (Local5 - 1.0f);
		float Local7 = (Local6 * 0.5f);
		//Distance from point to line segment:
		float3 Local8 = (eocGlobal.global_SeeThroughPosition - eocGlobal.global_GameCameraPosition);
		float3 Local9 = (in_1 - eocGlobal.global_GameCameraPosition);
		float Local10 = dot(Local9, Local8);
		float Local11 = dot(Local8, Local8);
		float Local12 = 0.0f;
		float Local13 = (Local10 / Local11);
		float3 Local14 = (eocGlobal.global_GameCameraPosition + (Local13 * Local8));
		float3 Local15 = clamp(Local14, min(eocGlobal.global_GameCameraPosition, eocGlobal.global_SeeThroughPosition), max(eocGlobal.global_GameCameraPosition, eocGlobal.global_SeeThroughPosition));
		Local12 = distance(in_1, Local15);
		//~Distance from point to line segment
		float Local16 = (Local7 + Local12);
		float Local17 = (Local16 / eocGlobal.global_SeeThroughRadius);
		float Local18 = clamp(Local17, 0.0f, 1.0f);
		Local2 = float4(Local18, Local18, Local18, Local18);
	}
	else
	{
		Local2 = float4(1.0f, 1.0f, 1.0f, 1.0f);
	}
	float Local19 = Local2.x;
	float Local20 = (Local1 * Local19);
	out_0 = Local20;
}

fragment PixelOutput Materials_Focus_PathSkills_Materials_Egg_Erosion_Proper_STI_SHA_Metal_fragmentMain(constant LocalUniformsPS& uniforms,
	constant EoCGlobalConstantData& eocGlobal,
	VertexOutput In [[stage_in]],
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler)
{
	PixelOutput Out;

	float matOpacity;
	CalculateMatOpacity(uniforms, eocGlobal, In.TexCoords0, In.WorldPosition.xyz, matOpacity, _DefaultWrapSampler, Texture2DParameter_basecolor_DefaultWrapSampler, Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler);
	if ((matOpacity - 0.5f) < 0) discard_fragment();

	float Local0 = dfdx(In.ShadowDepth);
	float Local1 = dfdy(In.ShadowDepth);
	Out.Color0 = float4(0.0f, 0.0f, 0.0f, 0.0f);
	Out.Color0.x = In.ShadowDepth;
	Out.Color0.y = ((In.ShadowDepth * In.ShadowDepth) + (((Local0 * Local0) + (Local1 * Local1)) * 0.25f));

	return Out;
}
