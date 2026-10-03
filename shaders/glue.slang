#version 450
#include "hueshift.inc"

layout(push_constant) uniform Push {
	float SOURCE_GAMMA;
	float SOURCE_GAIN;
	float SOURCE_FEEDBACK_GAIN;
	float GLOW_GAIN;
	float GLOW_FEEDBACK_GAIN;
	float HUE_CORRECTION;
	float GAMMA_OUTPUT;
	float CONTRAST;
	float CLIP_TO_WHITE;
} parameters;

#pragma parameter SOURCE_GAMMA "Compositing — Vector pre-gamma"	1.1 0.1 5.0 0.05
#pragma parameter SOURCE_GAIN "Compositing — Vector gain" 						3.00 0.0 5.0 0.05
#pragma parameter SOURCE_FEEDBACK_GAIN "Compositing — Vector ghost gain" 		0.25 0.0 5.0 0.05
#pragma parameter GLOW_GAIN "Compositing — Glow gain" 							0.65 0.0 5.0 0.05
#pragma parameter GLOW_FEEDBACK_GAIN "Compositing — Glow ghost gain" 			0.60 0.0 5.0 0.05
#pragma parameter HUE_CORRECTION "Postprocessing — Hue correction" 	-9.0 -180.0 180.0 1.0
#pragma parameter CONTRAST "Postprocessing — Contrast" 				1.0 0.0 5.0 0.01
#pragma parameter CLIP_TO_WHITE "Postprocessing — Clip to white" 	0.20 0.0 2.0 0.01
#pragma parameter GAMMA_OUTPUT "Postprocessing — Gamma compression"	2.20 0.1 5.0 0.05

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

layout(set = 0, binding = 1) uniform sampler2D GammaInput;
layout(set = 0, binding = 2) uniform sampler2D BlurComposite;
layout(set = 0, binding = 3) uniform sampler2D FeedbackSource;
layout(set = 0, binding = 4) uniform sampler2D FeedbackGlow;

void main() {
	const float FEEDBACK_GAIN_FACTOR = 0.20;
	vec4 result = vec4(0.);
	
	result += parameters.SOURCE_GAIN *
		pow(
			texture(GammaInput, vTexCoord),
			vec4(parameters.SOURCE_GAMMA)
		);
	result += FEEDBACK_GAIN_FACTOR *
		parameters.SOURCE_FEEDBACK_GAIN *
		texture(FeedbackSource, vTexCoord);
	result += parameters.GLOW_GAIN *
		texture(BlurComposite, vTexCoord);
	result += FEEDBACK_GAIN_FACTOR * 
		parameters.GLOW_FEEDBACK_GAIN *
		texture(FeedbackGlow, vTexCoord);
	
	if (parameters.HUE_CORRECTION != 0.)
		hueShift(result, parameters.HUE_CORRECTION);
	
	result *= parameters.CONTRAST * result;
	
	vec4 clipped = max(vec4(0.), result - vec4(1.));
	clipped = clipped.gbra + clipped.brga;
	result += 0.1 * parameters.CLIP_TO_WHITE * clipped;
	
	result = pow(result, vec4(1. / parameters.GAMMA_OUTPUT));
	FragColor = result;
}