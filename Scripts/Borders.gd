extends Node2D

@export var floor_boost_offset = 10.0

@onready var floor_border = $Floor
@onready var fall_area_l = $FallAreaLeft
@onready var fall_area_r = $FallAreaRight

var fall_offset : float
var offset_pos : Vector2
var original_pos

func _ready():
	original_pos = floor_border.position
	offset_pos = floor_border.position - Vector2(0.0, floor_boost_offset)

func boost(active:bool):
	if active: floor_border.position = offset_pos
	else: floor_border.position = original_pos

func update_fall_areas(value:float, _time:float):
	if value != 0.0: fall_offset = value
	
	fall_area_l.position.x += fall_offset
	fall_area_r.position.x += fall_offset
