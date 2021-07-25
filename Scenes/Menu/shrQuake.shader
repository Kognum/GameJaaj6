shader_type canvas_item;

const float PI = 3.141592653589793238462;
uniform float strenth :hint_range(-0.2, 0.2) = 0.1;

void fragment(){
	vec2 uv = UV;
	
	float scale = PI;
	uv += vec2(sin(TIME + uv.y * scale),cos(TIME + uv.x * scale)) * strenth;
	vec4 col = texture(TEXTURE, uv);
	
	COLOR = col;
}