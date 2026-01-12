//[Vertex shader]


#define __HAVE_MATRIX_MULTIPLE_SCALAR_CONSTRUCTORS__
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/GlobalConstants_MTL.shdh"
#include "Shaders/GlobalConstants_PS_MTL.shdh"

typedef struct
{
	float4 VertexColor COLOR0;
	float4 LocalQTangent NORMAL0;
	float4 InstanceMatrix1 COLOR1;
	float4 InstanceMatrix2 COLOR2;
	float4 InstanceMatrix3 COLOR3;
	float3 Position SV_POSITION0;
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float4 WorldPosition;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
} VertexOutput;

struct LocalUniformsVS
{
	float FloatParameter_PulseSpeed;
	float FloatParameter_PulseSize;
	float FloatParameter_PulseStrength;
};

static void CalculateMatWorldPositionOffset(constant LocalUniformsVS& uniforms,
	constant PerFrame& perFrame,
	float4 in_0,
	float3 in_1,
	float3 in_2,
	float3 in_3,
	thread float3& out_0)
{
	float3 Local0 = (in_0.y * in_1);
	float Local1 = (perFrame.global_Data.x * uniforms.FloatParameter_PulseSpeed);
	float3 Local2 = in_2;
	float Local3 = length(Local2);
	float Local4 = in_3.y;
	float Local5 = (Local4 / uniforms.FloatParameter_PulseSize);
	float Local6 = (Local3 + Local5);
	float Local7 = (Local6 + in_0.z);
	float Local8 = (Local1 + Local7);
	//TriangleWave
	float Local9 = abs(((fract((Local8 + 0.5f)) * 2.0f) - 1.0f));
	//Smooth TriangleWave
	float Local10 = ((Local9 * Local9) * (3.0f - (2.0f * Local9)));
	//Bring TriangleWave between range [min, max]
	float Local11 = ((Local10 * (uniforms.FloatParameter_PulseStrength - 0.0f)) + 0.0f);
	float3 Local12 = (Local0 * Local11);
	out_0 = Local12;
}

vertex VertexOutput Materials_Focus_PathSkills_Egg_Clean_STI_DEF_Metal_vertexMain(constant LocalUniformsVS& uniforms [[buffer(5)]],
	constant PerView& perView [[buffer(6)]],
	constant PerFrame& perFrame [[buffer(7)]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	//Compute local tangent frame
	float3x3 LocalTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 LocalNormal = LocalTangentFrame[2];

	//Normalize Local Normal
	float3 localNormalNormalized = normalize(LocalNormal);

	//Create Instance World Matrix
	float4 col1 = float4(In.InstanceMatrix1.x, In.InstanceMatrix1.y, In.InstanceMatrix1.z, 0.0f);
	float4 col2 = float4(In.InstanceMatrix1.w, In.InstanceMatrix2.x, In.InstanceMatrix2.y, 0.0f);
	float4 col3 = float4(In.InstanceMatrix2.z, In.InstanceMatrix2.w, In.InstanceMatrix3.x, 0.0f);
	float4 col4 = float4(In.InstanceMatrix3.y, In.InstanceMatrix3.z, In.InstanceMatrix3.w, 1.0f);
	float4x4 WorldMatrix = float4x4(col1, col2, col3, col4);

	//World space Normal
	float3 worldNormal = (float3x3(WorldMatrix[0].xyz, WorldMatrix[1].xyz, WorldMatrix[2].xyz) * localNormalNormalized);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	//Object World Position
	float3 objectWorldPosition = float3(WorldMatrix[3].x, WorldMatrix[3].y, WorldMatrix[3].z);

	CalculateMatWorldPositionOffset(uniforms, perFrame, In.VertexColor, worldNormalNormalized, objectWorldPosition, In.Position.xyz, matWorldPositionOffset);
	//World space position
	float4 worldPosition = (WorldMatrix * float4(In.Position, 1.0f));

	worldPosition = (worldPosition + float4(matWorldPositionOffset, 0.0f));

	//Projected position
	float4 projectedPosition = (perView.global_ViewProjection * worldPosition);

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	Out.TexCoords0 = In.TexCoords0;
	//Pass world position to pixel shader
	Out.WorldPosition = worldPosition;

	Out.WorldNormal = worldNormalNormalized;

	float3 LocalBinormal = LocalTangentFrame[1];

	//Normalize Local Binormal
	float3 localBinormalNormalized = normalize(LocalBinormal);

	//World space Binormal
	float3 worldBinormal = (float3x3(WorldMatrix[0].xyz, WorldMatrix[1].xyz, WorldMatrix[2].xyz) * localBinormalNormalized);

	//Normalize World Binormal
	float3 worldBinormalNormalized = normalize(worldBinormal);

	Out.WorldBinormal = worldBinormalNormalized;

	float3 LocalTangent = LocalTangentFrame[0];

	//Normalize Local Tangent
	float3 localTangentNormalized = normalize(LocalTangent);

	//World space Tangent
	float3 worldTangent = (float3x3(WorldMatrix[0].xyz, WorldMatrix[1].xyz, WorldMatrix[2].xyz) * localTangentNormalized);

	//Normalize World Tangent
	float3 worldTangentNormalized = normalize(worldTangent);

	Out.WorldTangent = worldTangentNormalized;


	return Out;
}


//[Fragment shader]


#include "Shaders/Metal/PBR.shdh"

typedef struct
{
	float4 Color0 [[color(0)]];
	float4 Color1 [[color(1)]];
	float4 Color2 [[color(2)]];
	float4 Color3 [[color(3)]];
} PixelOutput;

struct LocalUniformsPS
{
	float FloatParameter_SeeThroughEnabled;
	float FloatParameter_Reflectance;
	float _OpacityFade;
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
	float3 Local1 = Local0.xyz;
	float Local2 = Local0.w;
	float4 Local3 = float4(0.0f, 0.0f, 0.0f, 0.0f);
	if(uniforms.FloatParameter_SeeThroughEnabled > 1.0f)
	{
		Local3 = float4(1.0f, 1.0f, 1.0f, 1.0f);
	}
	else if(uniforms.FloatParameter_SeeThroughEnabled == 1.0f)
	{
		float4 Local4 = Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler.sample(_DefaultWrapSampler, (in_0 * float2(2.0f, 2.0f)));
		//[Local4] Get needed components
		float Local5 = Local4.x;
		float Local6 = (Local5 * 2.0f);
		float Local7 = (Local6 - 1.0f);
		float Local8 = (Local7 * 0.5f);
		//Distance from point to line segment:
		float3 Local9 = (eocGlobal.global_SeeThroughPosition - eocGlobal.global_GameCameraPosition);
		float3 Local10 = (in_1 - eocGlobal.global_GameCameraPosition);
		float Local11 = dot(Local10, Local9);
		float Local12 = dot(Local9, Local9);
		float Local13 = 0.0f;
		float Local14 = (Local11 / Local12);
		float3 Local15 = (eocGlobal.global_GameCameraPosition + (Local14 * Local9));
		float3 Local16 = clamp(Local15, min(eocGlobal.global_GameCameraPosition, eocGlobal.global_SeeThroughPosition), max(eocGlobal.global_GameCameraPosition, eocGlobal.global_SeeThroughPosition));
		Local13 = distance(in_1, Local16);
		//~Distance from point to line segment
		float Local17 = (Local8 + Local13);
		float Local18 = (Local17 / eocGlobal.global_SeeThroughRadius);
		float Local19 = clamp(Local18, 0.0f, 1.0f);
		Local3 = float4(Local19, Local19, Local19, Local19);
	}
	else
	{
		Local3 = float4(1.0f, 1.0f, 1.0f, 1.0f);
	}
	float Local20 = Local3.x;
	float Local21 = (Local2 * Local20);
	out_0 = Local21;
}

static void CalculateMatNormal(float2 in_0,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_normalmap_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_normalmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Convert normalmaps to tangent space vectors
	Local0.xyzw = Local0.wzyx;
	Local0.xyz = ((Local0.xyz * 2.0f) - 1.0f);
	Local0.z = -(Local0.z);
	Local0.xyz = normalize(Local0.xyz);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	out_0 = Local1;
}

static void CalculateMatBaseColor(float2 in_0,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_basecolor_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	float Local2 = Local0.w;
	out_0 = Local1;
}

static void CalculateMatMetalMask(float2 in_0,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_physicalmap_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_physicalmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float Local1 = Local0.x;
	float Local2 = Local0.y;
	out_0 = Local1;
}

static void CalculateMatReflectance(constant LocalUniformsPS& uniforms,
	thread float& out_0)
{
	out_0 = uniforms.FloatParameter_Reflectance;
}

static void CalculateMatRoughness(float2 in_0,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_physicalmap_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_physicalmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float Local1 = Local0.x;
	float Local2 = Local0.y;
	out_0 = Local2;
}

fragment PixelOutput Materials_Focus_PathSkills_Egg_Clean_STI_DEF_Metal_fragmentMain(constant LocalUniformsPS& uniforms,
	constant PerView& perView,
	constant EoCGlobalConstantData& eocGlobal,
	VertexOutput In [[stage_in]],
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_normalmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_physicalmap_DefaultWrapSampler)
{
	PixelOutput Out;

	float matOpacity;
	CalculateMatOpacity(uniforms, eocGlobal, In.TexCoords0, In.WorldPosition.xyz, matOpacity, _DefaultWrapSampler, Texture2DParameter_basecolor_DefaultWrapSampler, Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler);
	if ((matOpacity - 0.5f) < 0) discard_fragment();

	float3 matNormal;
	CalculateMatNormal(In.TexCoords0, matNormal, _DefaultWrapSampler, Texture2DParameter_normalmap_DefaultWrapSampler);
	//Normalize World Normal
	float3 worldNormalNormalized = normalize(In.WorldNormal);

	//Normalize World Binormal
	float3 worldBinormalNormalized = normalize(In.WorldBinormal);

	//Normalize World Tangent
	float3 worldTangentNormalized = normalize(In.WorldTangent);

	float3x3 NBT = float3x3(float3(worldTangentNormalized.x, worldNormalNormalized.x, worldBinormalNormalized.x), float3(worldTangentNormalized.y, worldNormalNormalized.y, worldBinormalNormalized.y), float3(worldTangentNormalized.z, worldNormalNormalized.z, worldBinormalNormalized.z));

	matNormal = (float3x3(perView.global_View[0].xyz, perView.global_View[1].xyz, perView.global_View[2].xyz) * normalize((matNormal * NBT)));

	float3 matBaseColor;
	CalculateMatBaseColor(In.TexCoords0, matBaseColor, _DefaultWrapSampler, Texture2DParameter_basecolor_DefaultWrapSampler);
	float matMetalMask;
	CalculateMatMetalMask(In.TexCoords0, matMetalMask, _DefaultWrapSampler, Texture2DParameter_physicalmap_DefaultWrapSampler);
	float matReflectance;
	CalculateMatReflectance(uniforms, matReflectance);
	float matRoughness;
	CalculateMatRoughness(In.TexCoords0, matRoughness, _DefaultWrapSampler, Texture2DParameter_physicalmap_DefaultWrapSampler);
	GBufferData gBufferData;
	gBufferData.Emissive = float3(0.0f, 0.0f, 0.0f);
	gBufferData.ViewSpaceNormal = matNormal;
	gBufferData.BaseColor = matBaseColor;
	gBufferData.FadeOpacity = uniforms._OpacityFade;
	gBufferData.Roughness = matRoughness;
	gBufferData.Reflectance = matReflectance;
	gBufferData.MetalMask = matMetalMask;
	gBufferData.FXEmissive = true;
	gBufferData.ShadingModel = 0;
	gBufferData.Custom = float4(0.0f, 0.0f, 0.0f, 0.0f);
	EncodeGBufferData(gBufferData, Out.Color0, Out.Color1, Out.Color2, Out.Color3);

	return Out;
}
