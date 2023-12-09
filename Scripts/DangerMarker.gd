extends TextureRect

#var start_x = 0.0
@export var is_marker_right : bool
@onready var marker_anim = $"../../MarkerAnim" as AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func set_marker_active(_body:Node2D):
	show()
	if is_marker_right: marker_anim.play("MarkerRightBlink")
	else: marker_anim.play("MarkerLeftBlink")

func set_marker_inactive(_body:Node2D):
	marker_anim.stop()
	hide()
