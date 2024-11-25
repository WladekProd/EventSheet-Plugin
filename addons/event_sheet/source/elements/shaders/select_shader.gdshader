shader_type canvas_item;

uniform bool is_active = false;

void fragment(){
	if (is_active) {
		float color_alpha = COLOR.a;
		COLOR = COLOR * vec4(1.8, 1.8, 1.8, 2.0);
		if (color_alpha == 0.0) {
			COLOR.a = 0.1;
		}
	}
}