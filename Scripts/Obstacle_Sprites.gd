extends Node2D
class_name Obstacle_Sprites

var short_obs_path = "res://Sprites/Short_Obstacles/"
var tall_obs_path = "res://Sprites/Tall_Obstacles/"
var offroad_obs_path = "res://Sprites/OffRoadObstacles/"

var short_sprites = []
var tall_sprites = []
var offroad_sprites = []

func _ready():
	load_sprites(short_obs_path, short_sprites)
	load_sprites(tall_obs_path, tall_sprites)
	load_sprites(offroad_obs_path, offroad_sprites)

func load_sprites(path:String, array:Array): # Accesses path directory and adds each file to array
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	
	while true:
		var file_name = dir.get_next()
		
		if file_name == "": break # break the while loop when get_next() returns ""
		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
			array.append(load(path + "/" + file_name))
	
	dir.list_dir_end()

func random_short() ->CompressedTexture2D:
	var index = randi_range(0, short_sprites.size()-1)
	return short_sprites[index]
	
func random_tall() ->CompressedTexture2D:
	var index = randi_range(0, tall_sprites.size()-1)
	return tall_sprites[index]

func random_offroad() ->CompressedTexture2D:
	var index = randi_range(0, offroad_sprites.size()-1)
	return offroad_sprites[index]
