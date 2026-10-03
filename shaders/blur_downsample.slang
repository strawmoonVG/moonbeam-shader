#version 450

layout(push_constant) uniform Push {
	float OFFSET_X;
	float OFFSET_Y;
} parameters;

#pragma parameter OFFSET_X "Blur pass — Offset X" 0.0 -1.0 1.0 0.125
#pragma parameter OFFSET_Y "Blur pass — Offset Y" 0.0 -1.0 1.0 0.125

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

layout(set = 0, binding = 2) uniform sampler2D Source;

void main() {	
	const int BLUR_STEPS = 13;
	const int LOOKUPS_X[13] = int[13](  -2,  0,  2, -1,  1, -2,  0,  2, -1,  1, -2,  0,  2);
	const int LOOKUPS_Y[13] = int[13](  -2, -2, -2, -1, -1,  0,  0,  0,  1,  1,  2,  2,  2);
	const vec2 OFFSET = vec2(parameters.OFFSET_X, parameters.OFFSET_Y);
	
	const float WEIGHT_FOUR = 0.5;
	const float WEIGHT_NINE = 1. - WEIGHT_FOUR;
	const float W4 = WEIGHT_FOUR / 4.;
		
	const float W9corner = 1. / 16. * WEIGHT_NINE;
	const float W9side = 1. / 8. * WEIGHT_NINE;
	const float W9middle = 1./ 4. * WEIGHT_NINE;
	const float WEIGHTS[13] = float[13](
		W9corner, W9side, W9corner,
				W4, 	W4, 
		W9side, W9middle, W9side,
				W4, 	W4,
		W9corner, W9side, W9corner
	);
	
	vec4 result = vec4(0.);
	for (int i = 0; i < BLUR_STEPS; i++) {
		result += WEIGHTS[i] * texture(Source,
			vTexCoord + global.SourceSize.wz *
			(vec2(LOOKUPS_X[i], LOOKUPS_Y[i]) + OFFSET)
		);
	}
    FragColor = result;
}