extends Node2D
class_name Spawner

var tall_obstacle = preload("res://Scenes/tall_obstacle.tscn")
var short_obstacle = preload("res://Scenes/short_obstacle.tscn")

static var boosting := false

var is_tall_obstacle := false
var sprite_index := 0
var pos_index := 0
var prev_pos := 0

var lane_offsets := [-240.0, -80.0, 80.0, 240.0]

@export_node_path() var obstacle_parent_path
@export var boost_curve : Curve
@export var speed_curve : Curve
@export var x_offset_curve : Curve
@export var boost_change := 25.0

@onready var obstacle_parent = get_node(obstacle_parent_path)
@onready var linear_start_pos = $RoadLinearOrigin
@onready var curve_start_pos = $RoadCurveOrigin
@onready var end_road_pos = $RoadEndPos
@onready var sprite_list = $SpriteList as SpriteList
@onready var timer1 = $SpawnTimer
@onready var timer2 = $SpawnTimer2
@onready var timer3 = $SpawnTimer3


func start_timers():
	timer1.start(1.3)
	timer2.start(2.4)
	timer3.start(3.0)

func pause_timers(active:bool):
	timer1.paused = active
	timer2.paused = active
	timer3.paused = active
	
func stop_timers():
	timer1.stop()
	timer2.stop()
	timer3.stop()

func spawn_onroad():
	randomize_obstacle()
	if pos_index == prev_pos: # Prevents doubling-up in a lane
		pos_index = pos_index - 1 if pos_index == lane_offsets.size()-1 else pos_index + 1
	prev_pos = pos_index
	
	var instance
	if is_tall_obstacle: 
		instance = tall_obstacle.instantiate()
		instance.set_sprite(sprite_list.random_tall())
	else: 
		instance = short_obstacle.instantiate()
		instance.set_sprite(sprite_list.random_short())
	
	instance.set_spawner(self)
	instance.set_position_nodes(linear_start_pos, curve_start_pos, end_road_pos, lane_offsets[pos_index])
	instance.position = Vector2(320.0, 240.0)
	obstacle_parent.add_child(instance)

func randomize_obstacle(): # Choose random attributes on spawn
	is_tall_obstacle = true if randf() > 0.5 else false
	pos_index = randi_range(0, lane_offsets.size() - 1)

func clear_obstacles():
	curve_start_pos.reset_curve_offset()
	if obstacle_parent.get_child_count() == 0: return
	for child in obstacle_parent.get_children():
		child.queue_free()

func update_origin_pos(value:float, time:float):
	curve_start_pos.update_curve_offset(value, time)
	
func pause_origin_pos(paused:bool):
	if !GameManager.is_playing: return
	curve_start_pos.pause_curve_offset(paused)

func boost(active:bool):
	boosting = active
