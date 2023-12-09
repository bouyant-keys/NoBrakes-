extends Control

@onready var orange_arrows = $OrangeArrows
@onready var pink_arrows = $PinkArrows
@onready var arrow_anim = $ArrowFlash

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func on_curve(value:float):
	var facing_right = true if value > 0 else false
	orange_arrows.flip_h = facing_right
	pink_arrows.flip_h = facing_right
	
	arrow_anim.play("Flash_Loop")
	show()
	
	await get_tree().create_timer(1.5).timeout
	hide()
