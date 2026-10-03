#version 450
#include "hueshift.inc"
#include "scalefeedback.inc"

layout(push_constant) uniform Push {
	float FEEDBACK_HUE_SHIFT;
	float FEEDBACK_SOURCE_INPUT;
	float FEEDBACK_SOURCE_GAIN;
} parameters;

#pragma parameter FEEDBACK_HUE_SHIFT "Ghosting — Hue shift" 9.00 -180.0 180.0 0.25
#pragma parameter FEEDBACK_SOURCE_INPUT "Vector ghosting — Input" 1.0 0.0 1.0 0.01
#pragma parameter FEEDBACK_SOURCE_GAIN "Vector ghosting — Feedback" 0.7 0.0 1.0 0.01

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
layout(set = 0, binding = 2) uniform sampler2D FeedbackSourceFeedback;

void main() {
	vec4 result = texture(FeedbackSourceFeedback, vTexCoord);
	
	hueShift(result, parameters.FEEDBACK_HUE_SHIFT);
	
	result += parameters.FEEDBACK_SOURCE_INPUT *
		texture(GammaInput, vTexCoord);

	float feedbackAmt = parameters.FEEDBACK_SOURCE_GAIN;
	scaleFeedback(feedbackAmt);
	result *= feedbackAmt;
		
	FragColor = result;
}