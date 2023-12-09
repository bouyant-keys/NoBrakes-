extends Control

var tweening := false

@export_node_path() var player_path

@onready var bonus_anim = $BonusLabelAnim
@onready var bonus_label = $Label as Label
@onready var player = get_node(player_path) as Node2D

func _ready():
	bonus_label.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if tweening:
		bonus_anim.play("BonusLabel_Flash")
	else:
		if bonus_anim.is_playing(): bonus_anim.stop()
		bonus_label.position = Vector2(player.position.x, player.position.y - 32.0)

func display_bonus(value:int):
	tweening = true
	print(bonus_label.position)
	bonus_label.text = "+" + str(value) + " "
	var label_tween = create_tween()
	label_tween.tween_property(bonus_label, "position", Vector2(bonus_label.position.x, bonus_label.position.y - 32.0), 0.5)
	
	await label_tween.finished
	bonus_label.position = Vector2.ZERO
	bonus_label.text = " "
	tweening = false
