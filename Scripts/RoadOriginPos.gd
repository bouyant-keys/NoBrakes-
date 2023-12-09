extends Node2D

var offset_tween : Tween
var curve_offset = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(curve_offset)
	var x_pos = 320.0 + (1300.0 * -curve_offset)
	
	position = Vector2(x_pos, 240.0)

func update_curve_offset(value:float, time:float):
	print("updating curve offset")
	offset_tween = get_tree().create_tween()
	offset_tween.tween_property(self, "curve_offset", value, time)

func pause_curve_offset(paused:bool):
	print("pausing curve offset: " + str(paused))
	if !offset_tween: return
	if !offset_tween.is_valid(): return
	
	if paused: offset_tween.pause()
	else: offset_tween.play()

func reset_curve_offset():
	print("curve offset reset")
	if offset_tween: offset_tween.stop()
	curve_offset = 0.0
