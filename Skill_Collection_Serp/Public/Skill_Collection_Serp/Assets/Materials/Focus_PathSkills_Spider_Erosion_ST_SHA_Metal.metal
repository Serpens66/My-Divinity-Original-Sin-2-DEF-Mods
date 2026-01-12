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
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float ShadowDepth;
} VertexOutput;

struct LocalUniformsVS
{
	float4x4 WorldMatrix;
};

vertex VertexOutput Materials_Focus_PathSkills_Spider_Erosion_ST_SHA_Metal_vertexMain(constant LocalUniformsVS& uniforms [[buffer(5)]],
	constant PerView& perView [[buffer(6)]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	//World space position
	float4 worldPosition = (uniforms.WorldMatrix * float4(In.Position, 1.0f));

	//Projected position
	float4 projectedPosition = (perView.global_ViewProjection * worldPosition);

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	Out.TexCoords0 = In.TexCoords0;
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
	float2 Vector2Parameter_ErosionCloudUV;
	float4 _MeshVertexColor;
	float FloatParameter_ErosionGlowSize;
};

static void CalculateMatOpacity(constant LocalUniformsPS& uniforms,
	float2 in_0,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_ErosionCloud_DefaultWrapSampler)
{
	float2 Local0 = (in_0 * uniforms.Vector2Parameter_ErosionCloudUV);
	float4 Local1 = Texture2DParameter_ErosionCloud_DefaultWrapSampler.sample(_DefaultWrapSampler, Local0);
	//[Local1] Get needed components
	float Local2 = Local1.x;
	float Local3 = (1.0f + uniforms.FloatParameter_ErosionGlowSize);
	float Local4 = (uniforms._MeshVertexColor.w * Local3);
	float Local5 = (Local4 - uniforms.FloatParameter_ErosionGlowSize);
	float Local6 = (1.0f - Local5);
	float Local7 = (Local6 - uniforms.FloatParameter_ErosionGlowSize);
	float Local8 = smoothstep(Local7, Local6, Local2);
	out_0 = Local8;
}

fragment PixelOutput Materials_Focus_PathSkills_Spider_Erosion_ST_SHA_Metal_fragmentMain(constant LocalUniformsPS& uniforms,
	VertexOutput In [[stage_in]],
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_ErosionCloud_DefaultWrapSampler)
{
	PixelOutput Out;

	float matOpacity;
	CalculateMatOpacity(uniforms, In.TexCoords0, matOpacity, _DefaultWrapSampler, Texture2DParameter_ErosionCloud_DefaultWrapSampler);
	if ((matOpacity - 0.5f) < 0) discard_fragment();

	float Local0 = dfdx(In.ShadowDepth);
	float Local1 = dfdy(In.ShadowDepth);
	Out.Color0 = float4(0.0f, 0.0f, 0.0f, 0.0f);
	Out.Color0.x = In.ShadowDepth;
	Out.Color0.y = ((In.ShadowDepth * In.ShadowDepth) + (((Local0 * Local0) + (Local1 * Local1)) * 0.25f));

	return Out;
}
