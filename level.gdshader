shader_type spatial;
render_mode blend_mix, depth_draw_opaque;

uniform float wave_speed = 1.5;
uniform float wave_height = 0.1;
uniform float wave_frequency = 0.8;

uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.7, 1.0);
uniform float color_variation_strength = 0.05;

uniform float roughness = 0.15;
uniform float metallic = 0.0;

void vertex() {
	// Basic wave motion
	float wave_x = sin((VERTEX.x * wave_frequency) + (TIME * wave_speed));
	float wave_z = sin((VERTEX.z * wave_frequency * 0.7) + (TIME * wave_speed * 1.2));

	float wave = (wave_x + wave_z) * 0.5;
	VERTEX.y += wave * wave_height;
}

void fragment() {
	// Subtle animated brightness variation
	float variation = sin(TIME + UV.x * 10.0) * color_variation_strength;

	vec3 final_color = water_color.rgb + variation;

	ALBEDO = final_color;
	ALPHA = water_color.a;

	ROUGHNESS = roughness;
	METALLIC = metallic;
}
