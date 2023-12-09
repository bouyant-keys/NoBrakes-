extends Sprite2D

@export_node_path() var player_path

@onready var player = get_node(player_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position.x = player.position.x
