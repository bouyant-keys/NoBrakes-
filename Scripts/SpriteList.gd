extends Node2D
class_name SpriteList

@onready var short_sprites = [preload("res://Sprites/Short_Obstacles/Logs.png"), preload("res://Sprites/Short_Obstacles/Tires.png"), preload("res://Sprites/Short_Obstacles/TrafficCones_Obstacle.png")]
@onready var tall_sprites = [preload("res://Sprites/Tall_Obstacles/ArrowSign_Obstacle.png"), preload("res://Sprites/Tall_Obstacles/Car_Front_Obstacle.png"), preload("res://Sprites/Tall_Obstacles/Car_Obstacle_2.png"), preload("res://Sprites/Tall_Obstacles/Car_Obstacle_3.png")]

func random_short() ->CompressedTexture2D:
	var index = randi_range(0, short_sprites.size()-1)
	return short_sprites[index]
	
func random_tall() ->CompressedTexture2D:
	var index = randi_range(0, tall_sprites.size()-1)
	return tall_sprites[index]
