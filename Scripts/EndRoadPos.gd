extends Node2D

var start_x = 0.0
var curve_offset = 0.0
#var has_printed = false
@export var is_mid_point : bool
@export var curve_strength = 325.0
@export var offset_mult = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_x = position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var y_pos = 480.0
	
	if is_mid_point:
		start_x = 320.0 + (curve_strength * -curve_offset)
		y_pos = 260.0
	
	var x_pos = start_x - (Player.centered_x_pos * offset_mult)
	position = Vector2(x_pos, y_pos)

func update_curve_offset(value:float, time:float):
	if value == 0.0:
		var offset_tween = get_tree().create_tween()
		offset_tween.tween_property(self, "curve_offset", value, time)
	else: curve_offset = value
