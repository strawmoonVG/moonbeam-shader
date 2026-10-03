#version 450

layout(push_constant) uniform Push {
	float BLUR_COMPOSITE_FOCUS;
} parameters;

#pragma parameter BLUR_COMPOSITE_FOCUS "Blur compositing — Diffusion" 0.0 -2.0 2.0 0.1

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
layout(location = 1) out float Weights[7];

void main() {
    gl_Position = global.MVP * Position;
    vTexCoord = TexCoord;

	for(int i = 0; i < 7; i++) {
		Weights[i] = 1. +
			parameters.BLUR_COMPOSITE_FOCUS *
			(float(i) / 6. - 0.5);
	}
}



#pragma stage fragment

layout(location = 0) in vec2 vTexCoord;
layout(location = 1) in float Weights[7];

layout(location = 0) out vec4 FragColor;

layout(set = 0, binding = 1) uniform sampler2D BlurPass0;
layout(set = 0, binding = 2) uniform sampler2D BlurPass1;
layout(set = 0, binding = 3) uniform sampler2D BlurPass2;
layout(set = 0, binding = 4) uniform sampler2D BlurPass3;
layout(set = 0, binding = 5) uniform sampler2D BlurPass4;
layout(set = 0, binding = 6) uniform sampler2D BlurPass5;
layout(set = 0, binding = 7) uniform sampler2D BlurPass6;

void main() {
	vec4 result = vec4(0.);
	
	result += Weights[0] * texture(BlurPass0, vTexCoord);
	result += Weights[1] * texture(BlurPass1, vTexCoord);
	result += Weights[2] * texture(BlurPass2, vTexCoord);
	result += Weights[3] * texture(BlurPass3, vTexCoord);
	result += Weights[4] * texture(BlurPass4, vTexCoord);
	result += Weights[5] * texture(BlurPass5, vTexCoord);
	result += Weights[6] * texture(BlurPass6, vTexCoord);
	
    FragColor = result;
}