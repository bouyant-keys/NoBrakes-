shader_type canvas_item;

uniform float tex_offset;
uniform float scroll_speed = 0.5;

void fragment() {
	vec2 new_tex_coords = SCREEN_UV;
	float tex_y = tex_offset;
	
	tex_y += scroll_speed * TIME;
		
	//Sky texture repeats in x
	new_tex_coords.y  = (new_tex_coords.y + tex_y) * 2.0;
	new_tex_coords.y = mod(new_tex_coords.y, 2.0);
	new_tex_coords.y /= 2.0;
	
	COLOR = texture(TEXTURE, new_tex_coords);
}
