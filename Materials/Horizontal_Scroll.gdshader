shader_type canvas_item;

uniform float tex_offset;
uniform float scroll_speed = 0.5;

void fragment() {
	vec2 new_tex_coords = SCREEN_UV;
	float tex_x = tex_offset;
	
	tex_x += scroll_speed * TIME;
		
	//Sky texture repeats in x
	new_tex_coords.x  = (new_tex_coords.x + tex_x) * 2.0;
	new_tex_coords.x = mod(new_tex_coords.x, 2.0);
	new_tex_coords.x /= 2.0;
	
	COLOR = texture(TEXTURE, new_tex_coords);
}
