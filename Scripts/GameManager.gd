extends Node2D
class_name GameManager

static var boosting := false
static var is_playing := false
static var paused := false
static var speed := 0.0
static var road_offset := 0.0
static var is_road_curving := false
static var curve_amt := 0.0
static var segment_y_pos := 0.0

@export var start_speed = 45.0
@export var boost_speed_increase = 5.0
@export var curve_tween_time = 2.0
@export var curve_range : Vector2
@export var time_til_curve_range : Vector2
@export var curve_wait_range : Vector2

@export_node_path() var spawner_path
@export_node_path() var player_path
@export_node_path() var road_bg
@export_node_path() var speed_overlay

@onready var obstacle_spawner = get_node(spawner_path)
@onready var player = get_node(player_path)
@onready var road_shader = get_node(road_bg).material
@onready var speed_shader = get_node(speed_overlay).material
@onready var curve_timer = $CurveTimer

var prev_speed = 0.0
var intro_wait_time = 6.0
var curve_tween : Tween

signal reset_game
signal begin_playing
signal end_playing
signal pause_obstacles(pause:bool)
signal upcoming_curve(value:float)
signal curving(value:float, time:float)
signal pause_curving(pause:bool)


func _ready():
	road_offset = 0.0
	road_shader.set_shader_parameter("speed", 0.0)
	speed_shader.set_shader_parameter("enabled", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !is_playing: return
	
	# Use to affect road perspective effect
	road_offset = (player.position.x - 320.0) / 640.0
	road_shader.set_shader_parameter("road_offset", road_offset)

func start_process():
	emit_signal("reset_game")
	pause_road_tween(false)
	if curve_tween: curve_tween.stop()
	road_shader.set_shader_parameter("road_offset", 0.0)
	road_shader.set_shader_parameter("segment_curve", 0.0)
	# Wait for start_light intro to finish
	await get_tree().create_timer(intro_wait_time).timeout
	
	is_playing = true
	is_road_curving = false
	road_shader.set_shader_parameter("speed", start_speed)
	speed = start_speed
	curve_timer.start()
	obstacle_spawner.start_timers()
	
	emit_signal("begin_playing")

func end_process():
	is_playing = false
	speed = 0.0
	prev_speed = 0.0
	road_shader.set_shader_parameter("speed", speed)
	curve_timer.stop()
	obstacle_spawner.stop_timers()
	pause_road_tween(true)

func boost(active:bool):
	if active:
		speed = start_speed + boost_speed_increase
		road_shader.set_shader_parameter("speed", speed)
		road_shader.set_shader_parameter("line_width", 1.5)
		speed_shader.set_shader_parameter("enabled", true)
	else:
		speed = start_speed
		road_shader.set_shader_parameter("speed", speed)
		road_shader.set_shader_parameter("line_width", 2.5)
		speed_shader.set_shader_parameter("enabled", false)

func curve_road():
	#set initial vars for random curve
	curve_timer.stop()
	var hold_time = randf_range(curve_wait_range.x, curve_wait_range.y)
	var curve_dir = 1 if randf() > 0.5 else -1
	curve_amt = randf_range(curve_range.x, curve_range.y) * curve_dir
	emit_signal("upcoming_curve", curve_dir)
	await get_tree().create_timer(1.5).timeout
	
	is_road_curving = true
	road_shader.set_shader_parameter("curving", true)
	emit_signal("curving", curve_amt, curve_tween_time)
	tween_road(curve_amt, curve_tween_time)
	
	await curve_tween.finished
	await get_tree().create_timer(hold_time).timeout
	
	emit_signal("curving", 0.0, curve_tween_time)
	tween_road(0.0, curve_tween_time)
	await curve_tween.finished
	
	curve_amt = 0.0
	is_road_curving = false
	road_shader.set_shader_parameter("curving", false)
	curve_timer.wait_time = randf_range(time_til_curve_range.x, time_til_curve_range.y)
	curve_timer.start()

func pause_game(is_paused:bool):
	curve_timer.paused = is_paused
	pause_road_tween(is_paused)
	if is_paused:
		paused = true
		prev_speed = speed
		speed = 0.0
		road_shader.set_shader_parameter("speed", 0.0)
		speed_shader.set_shader_parameter("animation_speed", 0.0)
		
	else:
		paused = false
		speed = prev_speed
		road_shader.set_shader_parameter("speed", speed)
		speed_shader.set_shader_parameter("animation_speed", 8.0)

func tween_road(amount:float, time:float):
	if curve_tween: curve_tween.kill()
	
	curve_tween = get_tree().create_tween()
	curve_tween.tween_property(road_shader, "shader_parameter/segment_curve", amount, time)

func pause_road_tween(is_paused:bool):
	if !curve_tween: return
	elif !curve_tween.is_valid(): return
	
	emit_signal("pause_curving", is_paused)
	if is_paused: curve_tween.pause()
	else: curve_tween.play()

func resume_game():
	pause_game(false)

func on_start_call():
	intro_wait_time = 6.0
	start_process()

func on_reset_call():
	intro_wait_time = 5.0
	end_process()
	start_process()

func on_stop_call():
	end_process()
