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
	float4 LocalQTangent NORMAL0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldView;
	float3 ObjectWorldPosition;
	float4 WorldPosition;
} VertexOutput;


vertex VertexOutput Characters_PBR_Characters_PBR_Base_Pulsing_Ooze_STI_DEF_Metal_vertexMain(constant PerView& perView [[buffer(5)]],
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
	//Compute local tangent frame
	float3x3 LocalTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 LocalNormal = LocalTangentFrame[2];

	//Normalize Local Normal
	float3 localNormalNormalized = normalize(LocalNormal);

	//World space Normal
	float3 worldNormal = (float3x3(WorldMatrix[0].xyz, WorldMatrix[1].xyz, WorldMatrix[2].xyz) * localNormalNormalized);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

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

	//World space view vector
	float3 worldView = (perView.global_ViewPos.xyz - worldPosition.xyz);

	Out.WorldView = worldView;

	//Object World Position
	float3 objectWorldPosition = float3(WorldMatrix[3].x, WorldMatrix[3].y, WorldMatrix[3].z);

	//Pass object world position to pixel shader
	Out.ObjectWorldPosition = objectWorldPosition;

	//Pass world position to pixel shader
	Out.WorldPosition = worldPosition;


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
	float FloatParameter_FresnelMultiplier;
	float FloatParameter_GradientStart;
	float FloatParameter_GradientMultiplier;
	float3 Vector3Parameter_GlowColor;
	float2 Vector2Parameter_XYPanningSpeeds;
	float FloatParameter_GlowMultiplier;
	float FloatParameter_AddedColorRepeat;
	float FloatParameter_AddWordPositionColor;
	float3 Vector3Parameter_NoiseNormalCorrection;
	float3 Vector3Parameter_NormalCorrection;
	float FloatParameter_Metalness;
	float FloatParameter_Reflectance;
	float FloatParameter_Roughness;
	float _OpacityFade;
};

static void CalculateMatEmissiveColor(constant LocalUniformsPS& uniforms,
	constant PerFrame& perFrame,
	float2 in_0,
	float3 in_1,
	float3 in_2,
	float3 in_3,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_normalmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_Glowmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_PanningNoise_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_normalmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Convert normalmaps to tangent space vectors
	Local0.xyzw = Local0.wzyx;
	Local0.xyz = ((Local0.xyz * 2.0f) - 1.0f);
	Local0.z = -(Local0.z);
	Local0.xyz = normalize(Local0.xyz);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	float Local2 = pow((1.0f - saturate(dot(Local1, in_1))), 4.0f);
	float Local3 = (Local2 * uniforms.FloatParameter_FresnelMultiplier);
	float3 Local4 = (in_2 - in_3);
	float Local5 = Local4.y;
	float Local6 = (Local5 + uniforms.FloatParameter_GradientStart);
	float Local7 = clamp(Local6, 0.0f, 1.0f);
	float Local8 = pow(Local7, 0.12f);
	float Local9 = (1.0f - Local8);
	float Local10 = (Local3 * Local9);
	float Local11 = (Local9 * uniforms.FloatParameter_GradientMultiplier);
	float4 Local12 = Texture2DParameter_basecolor_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local12] Get needed components
	float3 Local13 = Local12.xyz;
	float Local14 = Local12.w;
	float3 Local15 = (Local11 * Local13);
	float3 Local16 = (Local10 + Local15);
	float3 Local17 = clamp(Local16, 0.0f, 5.0f);
	float4 Local18 = Texture2DParameter_Glowmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local18] Get needed components
	float Local19 = Local18.x;
	float3 Local20 = (uniforms.Vector3Parameter_GlowColor * Local19);
	float2 Local21 = fma(perFrame.global_Data.x, uniforms.Vector2Parameter_XYPanningSpeeds, in_0);
	float4 Local22 = Texture2DParameter_PanningNoise_DefaultWrapSampler.sample(_DefaultWrapSampler, Local21);
	//[Local22] Get needed components
	float Local23 = Local22.x;
	float Local24 = (Local23 * uniforms.FloatParameter_GlowMultiplier);
	float3 Local25 = (Local20 * Local24);
	float3 Local26 = (Local17 + Local25);
	float2 Local27 = (in_0 * uniforms.FloatParameter_AddedColorRepeat);
	float4 Local28 = Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler.sample(_DefaultWrapSampler, (Local27 + (float2(0.05f, 0.03f) * perFrame.global_Data.x)));
	//[Local28] Get needed components
	float Local29 = Local28.x;
	float4 Local30 = Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler.sample(_DefaultWrapSampler, float2(Local29, Local29));
	//[Local30] Get needed components
	float3 Local31 = Local30.xyz;
	float3 Local32 = (Local31 * uniforms.FloatParameter_AddWordPositionColor);
	float Local33 = pow((1.0f - saturate(dot(Local1, in_1))), 2.0f);
	float3 Local34 = (Local32 * Local33);
	float3 Local35 = (Local34 * 3.0f);
	float3 Local36 = (Local35 / 2.0f);
	float3 Local37 = (Local26 + Local36);
	out_0 = Local37;
}

static void CalculateMatNormal(constant LocalUniformsPS& uniforms,
	constant PerFrame& perFrame,
	float2 in_0,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_normalmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_NoiseNormalUVWarp_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_NoiseNormal_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_NoiseNormalUVWarp_DefaultWrapSampler.sample(_DefaultWrapSampler, (in_0 + (float2(-0.2f, 0.0f) * perFrame.global_Data.x)));
	//[Local0] Get needed components
	float Local1 = Local0.y;
	float Local2 = (0.2f * Local1);
	float2 Local3 = ((in_0 * float2(2.0f, 2.0f)) + Local2);
	float4 Local4 = Texture2DParameter_NoiseNormal_DefaultWrapSampler.sample(_DefaultWrapSampler, Local3);
	//[Local4] Convert normalmaps to tangent space vectors
	Local4.xyzw = Local4.wzyx;
	Local4.xyz = ((Local4.xyz * 2.0f) - 1.0f);
	Local4.z = -(Local4.z);
	Local4.xyz = normalize(Local4.xyz);
	//[Local4] Get needed components
	float3 Local5 = Local4.xyz;
	float3 Local6 = (Local5 * uniforms.Vector3Parameter_NoiseNormalCorrection);
	float4 Local7 = Texture2DParameter_normalmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local7] Convert normalmaps to tangent space vectors
	Local7.xyzw = Local7.wzyx;
	Local7.xyz = ((Local7.xyz * 2.0f) - 1.0f);
	Local7.z = -(Local7.z);
	Local7.xyz = normalize(Local7.xyz);
	//[Local7] Get needed components
	float3 Local8 = Local7.xyz;
	float3 Local9 = (Local8 * uniforms.Vector3Parameter_NormalCorrection);
	float3 Local10 = (Local6 + Local9);
	out_0 = Local10;
}

static void CalculateMatBaseColor(constant LocalUniformsPS& uniforms,
	constant PerFrame& perFrame,
	float2 in_0,
	float3 in_1,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_normalmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler)
{
	float2 Local0 = (in_0 * uniforms.FloatParameter_AddedColorRepeat);
	float4 Local1 = Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler.sample(_DefaultWrapSampler, (Local0 + (float2(0.05f, 0.03f) * perFrame.global_Data.x)));
	//[Local1] Get needed components
	float Local2 = Local1.x;
	float4 Local3 = Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler.sample(_DefaultWrapSampler, float2(Local2, Local2));
	//[Local3] Get needed components
	float3 Local4 = Local3.xyz;
	float3 Local5 = (Local4 * uniforms.FloatParameter_AddWordPositionColor);
	float4 Local6 = Texture2DParameter_normalmap_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local6] Convert normalmaps to tangent space vectors
	Local6.xyzw = Local6.wzyx;
	Local6.xyz = ((Local6.xyz * 2.0f) - 1.0f);
	Local6.z = -(Local6.z);
	Local6.xyz = normalize(Local6.xyz);
	//[Local6] Get needed components
	float3 Local7 = Local6.xyz;
	float Local8 = pow((1.0f - saturate(dot(Local7, in_1))), 2.0f);
	float3 Local9 = (Local5 * Local8);
	float3 Local10 = (Local9 * 3.0f);
	float4 Local11 = Texture2DParameter_basecolor_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local11] Get needed components
	float3 Local12 = Local11.xyz;
	float Local13 = Local11.w;
	float3 Local14 = (Local10 + Local12);
	out_0 = Local14;
}

static void CalculateMatMetalMask(constant LocalUniformsPS& uniforms,
	thread float& out_0)
{
	out_0 = uniforms.FloatParameter_Metalness;
}

static void CalculateMatReflectance(constant LocalUniformsPS& uniforms,
	thread float& out_0)
{
	out_0 = uniforms.FloatParameter_Reflectance;
}

static void CalculateMatRoughness(constant LocalUniformsPS& uniforms,
	thread float& out_0)
{
	out_0 = uniforms.FloatParameter_Roughness;
}

fragment PixelOutput Characters_PBR_Characters_PBR_Base_Pulsing_Ooze_STI_DEF_Metal_fragmentMain(constant LocalUniformsPS& uniforms,
	constant PerView& perView,
	constant PerFrame& perFrame,
	VertexOutput In [[stage_in]],
	bool IsFrontFacing [[front_facing]],
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_normalmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_Glowmap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_PanningNoise_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_NoiseNormalUVWarp_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_NoiseNormal_DefaultWrapSampler)
{
	PixelOutput Out;

	float3 matEmissiveColor;
	//Flip back-facing WorldSpace Normal
	float FrontFace = (((float)(IsFrontFacing) * 2.0f) - 1.0f);
	float3 WorldNormal = (In.WorldNormal * FrontFace);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(WorldNormal);

	//Normalize World Binormal
	float3 worldBinormalNormalized = normalize(In.WorldBinormal);

	//Normalize World Tangent
	float3 worldTangentNormalized = normalize(In.WorldTangent);

	float3x3 NBT = float3x3(float3(worldTangentNormalized.x, worldNormalNormalized.x, worldBinormalNormalized.x), float3(worldTangentNormalized.y, worldNormalNormalized.y, worldBinormalNormalized.y), float3(worldTangentNormalized.z, worldNormalNormalized.z, worldBinormalNormalized.z));

	//Normalized world space view vector
	float3 worldViewNormalized = normalize(In.WorldView);

	//Calculate tangent space view vector
	float3 tangentView = (NBT * worldViewNormalized);

	CalculateMatEmissiveColor(uniforms, perFrame, In.TexCoords0, tangentView, In.ObjectWorldPosition, In.WorldPosition.xyz, matEmissiveColor, _DefaultWrapSampler, Texture2DParameter_normalmap_DefaultWrapSampler, Texture2DParameter_basecolor_DefaultWrapSampler, Texture2DParameter_Glowmap_DefaultWrapSampler, Texture2DParameter_PanningNoise_DefaultWrapSampler, Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler, Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler);
	float3 matNormal;
	CalculateMatNormal(uniforms, perFrame, In.TexCoords0, matNormal, _DefaultWrapSampler, Texture2DParameter_normalmap_DefaultWrapSampler, Texture2DParameter_NoiseNormalUVWarp_DefaultWrapSampler, Texture2DParameter_NoiseNormal_DefaultWrapSampler);
	matNormal = (float3x3(perView.global_View[0].xyz, perView.global_View[1].xyz, perView.global_View[2].xyz) * normalize((matNormal * NBT)));

	float3 matBaseColor;
	CalculateMatBaseColor(uniforms, perFrame, In.TexCoords0, tangentView, matBaseColor, _DefaultWrapSampler, Texture2DParameter_normalmap_DefaultWrapSampler, Texture2DParameter_basecolor_DefaultWrapSampler, Texture2DParameter_9dc5807b36974b8fab0fb9c5c1bd7010_DefaultWrapSampler, Texture2DParameter_WorldPositionColorMap_DefaultWrapSampler);
	float matMetalMask;
	CalculateMatMetalMask(uniforms, matMetalMask);
	float matReflectance;
	CalculateMatReflectance(uniforms, matReflectance);
	float matRoughness;
	CalculateMatRoughness(uniforms, matRoughness);
	GBufferData gBufferData;
	gBufferData.Emissive = matEmissiveColor;
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
