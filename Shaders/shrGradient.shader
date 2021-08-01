shader_type canvas_item;

// MODES
// 0 - DEBUG
// 1 - MULTIPLY
// 2 - SCREEN
// 3 - SOFTLIGHT
// 4 - HARDLIGHT
// 5 - OVERLAY
uniform int mode :hint_range(0,5) = 5;
uniform bool linearColorSpace = false;
uniform vec4 color1 :hint_color = vec4(1, 0.5, 0.8, 1);
uniform vec4 color2 :hint_color = vec4(0.4, 0.8, 1, 1);
uniform vec2 direction = vec2(1.0, 1.0);
uniform float opacity :hint_range(0, 1) = 0.5;

 vec3 srgb_to_linear(vec3 c){
	return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

vec3 linear_to_srgb(vec3 c){
	return max(1.055 * pow(c, vec3(0.416666667)) - 0.055, 0.0);
}

void fragment(){
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
	vec4 src = texture(SCREEN_TEXTURE, uv);
	
	vec3 c_a = src.rgb;
	vec3 grad1 = color1.rgb;
	vec3 grad2 = color2.rgb;
	vec3 c_f;
	
	if (linearColorSpace){ 
		c_a = linear_to_srgb(c_a);
		grad1 = linear_to_srgb(grad1);
		grad2 = linear_to_srgb(grad2);
	}

	float param = dot(uv - 0.5, direction);
	vec3 c_b = mix(grad1, grad2, param + 0.5);
	
	if (mode == 0){       // DEBUG
		c_f = c_b;
	}else if (mode == 1){ // MULTIPLY
		c_f = c_a * c_b;
	}else if (mode == 2){ // SCREEN
		c_f = 1.0 - (1.0 - c_a) * (1.0 - c_b);
	}else if (mode == 3){ // SOFTLIGHT
		vec3 c_u = c_a * c_b * 2.0 + (1.0 - c_b * 2.0) * c_a * c_a;
		vec3 c_d = (1.0 - c_b) * c_a * 2.0 + (c_b * 2.0 - 1.0) * sqrt(c_a);
		c_f = mix(c_u, c_d, c_b + 0.5);
	}else if (mode == 4){ // HARDLIGHT
		vec3 c_u = c_a * c_b * 2.0;
		vec3 c_d = 1.0 - (1.0 - c_a) * (1.0 - c_b) * 2.0;
		c_f = mix(c_u, c_d, c_b + 0.5);
	}else if (mode == 5){ // OVERLAY
		vec3 c_u = c_a * c_b * 2.0;
		vec3 c_d = 1.0 - (1.0 - c_a) * (1.0 - c_b) * 2.0;
		c_f = mix (c_u, c_d, c_a + 0.5);
	}
	
	if (linearColorSpace){
		c_f = srgb_to_linear(c_f);
	}

	COLOR = vec4(c_f, opacity);
    }