extends Area2D

var start_z = 1.0
var end_z = 4.0
var z_pos = 0.0

var start_node_x
var end_node_x

var move_time = 180
var elapsed_time = 0.0

var spawner : Node2D
var linear_node : Node2D
var curve_node : Node2D
var end_node : Node2D
var end_offset = 0.0

func _enter_tree():
	scale = Vector2.ZERO
	position.x = 320.0
	
	move_time = 180.0 - GameManager.speed
	z_pos = start_z

func _process(_delta):
	if GameManager.speed == 0.0: return
	elif position.y >= 480.0: 
		#print("Freeing " + name + " from queue")
		queue_free()
	var move_ratio = elapsed_time / move_time
	
	# Alters the speed at which obstacles move based on a curve
	var curved_interp = spawner.speed_curve.sample(move_ratio) #if !spawner.boosting else spawner.boost_curve.sample(move_ratio)
	var y_pos = 240.0 + (curved_interp * 240.0)
	z_index = ceili(y_pos)
	
	# Establish start and end points based on if the road is curving
	end_node_x = end_node.position.x + end_offset
	if GameManager.is_road_curving: #&& y_pos < GameManager.segment_y_pos:
		start_node_x = curve_node.position.x
	else:
		start_node_x = linear_node.position.x
	
	# Determine x_pos from line between start and end points, curved if road is curving
	var x_pos = linear_x_pos(y_pos, start_node_x, end_node_x) 
	if GameManager.is_road_curving:
		var curve_x_offset = spawner.x_offset_curve.sample(move_ratio) * (200.0 * GameManager.curve_amt)
		x_pos += curve_x_offset
	position = Vector2(x_pos, y_pos)
	
	# Object scaling follows curve along with y_pos
	var obj_size = 0.05 + (curved_interp * 3.5)
	scale = Vector2(obj_size, obj_size)
	
	# Enable/disable collision detection based on y_pos
	if (position.y > 450.0 and position.y < 465.0): monitorable = true
	else: set_deferred("monitorable", false)
	
	elapsed_time += 1.0

func linear_x_pos(y_pos:float, start_x:float, end_x:float) -> float:
	# Find slope of line through two points, then calculate x_pos on that line using y_pos
	# First m(slope) = y2-y1 / x2-x1
	# Point-Slope Form: (y-y1)=m(x-x1) -> (y_pos-240)=m(x-start_x), solving for x
	var slope = -240.0 / (start_x - end_x) 
	var x_pos = ((y_pos -240.0) / slope) + start_x 
	return x_pos

#func parabolic_x_pos(y_pos:float, start_x:float, end_x:float) -> float: #
	## Parabola vertex: (start_x, 240) | 'end' point: (end_x, 480)
	## y = a(x-start_x)^2 + 240
	## a = (y - 240) / (x - start_x)^2
	## x = sqrt((y - 240) / a) + start_x
	#var direction = 1 if GameManager.curve_amt > 0 else -1
	#var a = ((240.0) / square(end_node.position.x - start_x))
	#var x_pos = direction * sqrt((y_pos - 240.0) / a) + start_x 
	#return x_pos

#func square(num:float) ->float:
	#return num * num

func set_position_nodes(line_start:Node2D, curve_start:Node2D, end:Node2D, offset:float):
	linear_node = line_start
	curve_node = curve_start
	end_node = end
	end_offset = offset

func set_sprite(new_sprite:CompressedTexture2D):
	get_node("Sprite2D").texture = new_sprite

func set_spawner(obs_spawner:Node2D):
	spawner = obs_spawner
