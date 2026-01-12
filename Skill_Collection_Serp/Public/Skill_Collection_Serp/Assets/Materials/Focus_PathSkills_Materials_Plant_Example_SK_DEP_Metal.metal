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
	uint4 BoneIndices BLENDINDICES0;
	float4 BoneWeights BLENDWEIGHT0;
	float3 Position SV_POSITION0;
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float4 WorldPosition;
} VertexOutput;

struct LocalUniformsVS
{
	float3x4 BoneMatrices[128];
	float4x4 WorldMatrix;
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

vertex VertexOutput Materials_Focus_PathSkills_Materials_Plant_Example_SK_DEP_Metal_vertexMain(constant LocalUniformsVS& uniforms [[buffer(5)]],
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

	float4x3 boneMatrix1 = transpose(uniforms.BoneMatrices[In.BoneIndices.x]);
	float4x3 boneMatrix2 = transpose(uniforms.BoneMatrices[In.BoneIndices.y]);
	float4x3 boneMatrix3 = transpose(uniforms.BoneMatrices[In.BoneIndices.z]);
	float4x3 boneMatrix4 = transpose(uniforms.BoneMatrices[In.BoneIndices.w]);
	//World space Normal
	float3 worldNormal = float3(0.0f, 0.0f, 0.0f);
	worldNormal = (worldNormal + (In.BoneWeights.x * (boneMatrix1 * float4(localNormalNormalized, 0.0f))));
	worldNormal = (worldNormal + (In.BoneWeights.y * (boneMatrix2 * float4(localNormalNormalized, 0.0f))));
	worldNormal = (worldNormal + (In.BoneWeights.z * (boneMatrix3 * float4(localNormalNormalized, 0.0f))));
	worldNormal = (worldNormal + (In.BoneWeights.w * (boneMatrix4 * float4(localNormalNormalized, 0.0f))));
	worldNormal = (uniforms.WorldMatrix * float4(worldNormal, 0.0f)).xyz;

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	//Object World Position
	float3 objectWorldPosition = float3(uniforms.WorldMatrix[3].x, uniforms.WorldMatrix[3].y, uniforms.WorldMatrix[3].z);

	CalculateMatWorldPositionOffset(uniforms, perFrame, In.VertexColor, worldNormalNormalized, objectWorldPosition, In.Position.xyz, matWorldPositionOffset);
	//World space position
	float4 worldPosition = float4(0.0f, 0.0f, 0.0f, 1.0f);
	worldPosition.xyz = (worldPosition.xyz + (In.BoneWeights.x * (boneMatrix1 * float4(In.Position, 1.0f))));
	worldPosition.xyz = (worldPosition.xyz + (In.BoneWeights.y * (boneMatrix2 * float4(In.Position, 1.0f))));
	worldPosition.xyz = (worldPosition.xyz + (In.BoneWeights.z * (boneMatrix3 * float4(In.Position, 1.0f))));
	worldPosition.xyz = (worldPosition.xyz + (In.BoneWeights.w * (boneMatrix4 * float4(In.Position, 1.0f))));
	worldPosition = (uniforms.WorldMatrix * worldPosition);

	worldPosition = (worldPosition + float4(matWorldPositionOffset, 0.0f));

	//Projected position
	float4 projectedPosition = (perView.global_ViewProjection * worldPosition);

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	Out.TexCoords0 = In.TexCoords0;
	//Pass world position to pixel shader
	Out.WorldPosition = worldPosition;


	return Out;
}


//[Fragment shader]



typedef struct
{
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

fragment PixelOutput Materials_Focus_PathSkills_Materials_Plant_Example_SK_DEP_Metal_fragmentMain(constant LocalUniformsPS& uniforms,
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


	return Out;
}
