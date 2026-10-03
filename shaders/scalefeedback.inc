void scaleFeedback(inout float feedback) {
	const float CURVE = 0.2;
	const float OVERDRIVE = 0.0;
	feedback = (1.0 + OVERDRIVE) *
		(1. + CURVE) *
		(1. - CURVE / (feedback + CURVE));
}