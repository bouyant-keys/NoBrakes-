shader_type canvas_item;

//Textures
uniform sampler2D road_main;
uniform sampler2D road_mask;
uniform sampler2D sky_tex;

//Scrolling
uniform float sky_offset = 0.0; //Interp this value to shift sky when turning
uniform float sky_scroll_speed = 0.0;
uniform float line_width = 0.0;
uniform float speed = 0.0;
uniform float road_offset = 0.0;

//Curving
const float z_max = 91.125;
uniform bool curving = false;
uniform float segment_curve = 0;// Curve amount, constant per segment
uniform float segment_begin;
//varying flat int line_curve;// Curve amount, changes per line

void fragment() {
	vec2 sky_uv = SCREEN_UV * 2.0;
	vec2 road_uv = vec2(SCREEN_UV.x * 0.75 + 0.125, SCREEN_UV.y * 2.0); //vec2(SCREEN_UV.x * 0.25 + 0.375, SCREEN_UV.y * 1.5 + 0.30);
	float sky_x = sky_offset; //Total texture x offset
	float road_x = road_offset; //X offset by row on road
	
	if (SCREEN_UV.y < 0.5) //SKY
	{
		vec2 Coord = sky_uv;
		
		//Move clouds along with turns
		float turning_fac = 0.0;
		//if (curving) turning_fac = segment_curve;
		
		sky_x += (sky_scroll_speed + turning_fac) * TIME;
		
		//Sky texture repeats in x
		Coord.x  = (Coord.x + sky_x) * 2.0;
		Coord.x = mod(Coord.x, 2.0);
		Coord.x /= 2.0;
		
		COLOR = texture(sky_tex, Coord);
	}
	else // ROAD UV = 0.0 <-> 0.5
	{
		vec2 Coord = road_uv; //The coordinate system with which to draw the road/mask textures
		Coord.y -= 1.0;
		
		float velocity = TIME * speed;
		
		//Gets pixel row, sets it to be from 0.0 at the bottom to 1.0 at half screen y
		float row = 1.0 - Coord.y; 
		//Defines how z-distance is calculated
		float z_pos = pow(4.5, row * 3.0);
		
		if (curving && segment_curve != 0.0)
		{
			float curve_row = (row - segment_begin) / (1.0 - segment_begin);
			float segment_z = pow(4.5, segment_begin * 3.0);
			float segment_dist = segment_begin - 0.1;
			if (z_pos > segment_z)
			{
				//float center_value = segment_curve * 0.85;
				Coord.x += segment_curve * tan(curve_row);
			}
		}
		
		//Offset tex coord x by the players position, a lot up close, little far away
		Coord.x += road_x * (1.0 - row); 
		
		//Checks if current z_pos falls within masking range, then colors based on that
		if (mod(z_pos + velocity, line_width * 2.0) < line_width)
		{
			COLOR = texture(road_mask, Coord);
		}
		else
		{
			COLOR = texture(road_main, Coord);
		}
		
		//COLOR = vec4(row);
	}
//	for each line of the screen from the bottom to the top:
//		if line of screen's Z Map position is below segment.position:
//			dx = bottom_segment.dx
//		else if line of screen's Z Map position is above segment.position:
//			dx = segment.dx
//		ddx += dx
//		current_x += ddx
//		this_line.x = current_x
//
//	// Move segments
//	segment_y += constant * speed // Constant makes sure the segment doesn't move too fast
//	if segment.position < 0 // 0 is nearest
//		bottom_segment = segment
//		segment.position = zmap.length - 1 // Send segment position to farthest distance
//		segment.dx = GetNextDxFromTrack() // Fetch next curve amount from track data
}