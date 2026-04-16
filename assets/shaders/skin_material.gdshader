shader_type spatial;

void fragment() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	ALBEDO = vec3(1.0, 0.147, 0.0);
}
