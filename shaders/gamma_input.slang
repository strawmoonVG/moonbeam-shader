#version 450

layout(push_constant) uniform Push {
	float GAMMA_INPUT;
} parameters;

#pragma parameter GAMMA_INPUT "Input — Gamma expansion" 2.2 0.1 5.0 0.05

layout(std140, set = 0, binding = 0) uniform UBO {
    mat4 MVP;
    vec4 OutputSize;
    vec4 OriginalSize;
    vec4 SourceSize;
} global;

#pragma format R16G16B16A16_SFLOAT



#pragma stage vertex

layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;

layout(location = 0) out vec2 vTexCoord;

void main() {
    gl_Position = global.MVP * Position;
    vTexCoord = TexCoord;
}



#pragma stage fragment

layout(location = 0) in vec2 vTexCoord;

layout(location = 0) out vec4 FragColor;

layout(set = 0, binding = 1) uniform sampler2D Source;

void main() {
	FragColor = pow(
		texture(Source, vTexCoord),
		vec4(parameters.GAMMA_INPUT)
	);
}