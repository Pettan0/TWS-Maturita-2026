shader_type spatial;
render_mode cull_disabled; // Shows both sides of the leaf

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform float roughness : hint_range(0.0, 1.0) = 0.8;

group_uniforms Wind_Settings;
uniform vec3 wind_direction = vec3(0.5, 0.15, 0.15);
uniform float wind_speed = 1.1;
uniform float wind_strength = 0.12;
uniform sampler2D noise_tex; // Drag a FastNoiseLite here for organic gusts

void vertex() {
	float time = TIME * wind_speed;
	
	// Sample noise for organic "gusts" 
	// We use world coordinates so the wind "flows" across the whole tree
	float noise_sample = texture(noise_tex, (NODE_POSITION_WORLD.xz + VERTEX.xz) * 0.1 + (time * 0.1)).r;
	
	float sway = sin(time + VERTEX.x) * cos(time * 0.5 + VERTEX.z);
	
	// COLOR.r acts as the weight (Paint tips white, stems black)
	float strength = wind_strength * noise_sample * COLOR.r;
	
	VERTEX += wind_direction * sway * strength;
}

void fragment() {
	vec4 tex_color = texture(albedo_texture, UV);
	ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a; // Enable "Transparency" in Material settings if needed
	ALPHA_SCISSOR_THRESHOLD = 0.5; // Standard for foliage performance
	
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	ROUGHNESS = roughness;
}