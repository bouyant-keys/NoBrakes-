extends CharacterBody2D
class_name Player

var input_enabled := true
const GRAVITY := -9.8

static var x_pos : float
static var centered_x_pos : float

var force_tween : Tween
var facing_right := true
var turning := false
var jumping := false
var crashed := false
var boosting := false
var curve_force := 0.0
var sprite_index := 0
@export var health := 3
@export var speed := 50.0
@export var boost_speed := 100.0
@export var jump_force := 10.0
@export var curve_force_mult := 500.0

@onready var anim_player = $PlayerAnim as AnimationPlayer
@onready var explosion_anim = $AnimatedExplosion as AnimatedSprite2D
@onready var boost_timer = $BoostTimer as Timer
@onready var obs_trigger = $ObstacleTrigger as Area2D
@onready var sprite = $DeloreanSprite as AnimatedSprite2D
@onready var sprites = [preload("res://Sprites/_Player/Delorean.png"), preload("res://Sprites/_Player/DeloreanTurnR.png"), preload("res://Sprites/_Player/Delorean_Jump_alt.png"), preload("res://Sprites/_Player/Delorean_JumpR.png")]

@onready var MotorLoop_sfx = $MotorLoop_SFX
@onready var jump_sfx = $Jump_SFX
@onready var hit_sfx = $Hit_SFX
@onready var crash_sfx = $Crash_SFX
@onready var fallout_sfx = $FallOut_SFX
@onready var splash_sfx = $Splash_SFX
@onready var bonus_sfx1 = $Bonus_SFX
@onready var bonus_sfx2 = $Bonus_SFX2

signal show_results
signal player_crash
signal player_hit(health:int)
signal point_bonus(value:int)
signal pause_game(value:bool)
signal boost(active:bool)


func _ready():
	input_enabled = false
	obs_trigger.monitoring = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	x_pos = position.x
	centered_x_pos = position.x - 320.0
	
	if !input_enabled: return
	
	if not is_on_floor():
		velocity.y -= GRAVITY
		change_motor_pitch(0.9)
	else: 
		change_motor_pitch(1.0)
		jumping = false
	
	var input_dir := 0.0
	turning = false
	if Input.is_action_pressed("Left"): 
		input_dir = -1.0 * speed
		facing_right = false
		turning = true
	elif Input.is_action_pressed("Right"): 
		input_dir = 1.0 * speed
		facing_right = true
		turning = true
	
	if is_on_floor() and Input.is_action_just_pressed("Jump"): 
		velocity.y = -jump_force
		jumping = true
		jump_sfx.play()
	
	velocity = Vector2(input_dir + curve_force, velocity.y)
	move_and_slide()

func _process(_delta):
	update_sprite()
	
	if Input.is_action_just_pressed("Pause"):
		if !GameManager.is_playing: return
		elif GameManager.paused: pause(false)
		else: pause(true)

func pause(active:bool):
	if active:
			emit_signal("pause_game", true)
			boost_timer.paused = true
			MotorLoop_sfx.stream_paused = true
			input_enabled = false
	else:
			emit_signal("pause_game", false)
			boost_timer.paused = false
			MotorLoop_sfx.stream_paused = false
			input_enabled = true

func update_sprite():
	if !input_enabled: 
		if crashed: sprite.play("Destroyed")
		else: sprite.play("Forward")
		return
	
	var anim = "Forward"
	if turning:
		sprite.flip_h = !facing_right
		anim = "Turn" if !jumping else "Turn_Jump"
	elif jumping:
		anim = "Jump"
	
	sprite.play(anim)

func start_boost():
	boosting = true
	anim_player.play("boost_loop")
	
	if bonus_sfx1.playing: bonus_sfx2.play()
	else: bonus_sfx1.play()
	boost_timer.start()
	
	#change_motor_pitch(1.1)
	emit_signal("point_bonus", 1000)
	emit_signal("boost", true)

func end_boost():
	boosting = false
	anim_player.play("boost_end")
	#change_motor_pitch(1.0)
	emit_signal("boost", false)

func change_motor_pitch(value:float):
	var pitch_tween = get_tree().create_tween()
	pitch_tween.tween_property(MotorLoop_sfx, "pitch_scale", value, 0.5)

func on_trigger(area : Area2D):
	#print("hit object: " + area.name + " on layer: " + str(area.collision_layer))
	if area.collision_layer == 2: hit()
	elif area.collision_layer == 4: start_boost()
	elif area.collision_layer == 8: fall_out()

func hit():
	health -= 1
	emit_signal("player_hit", health)
	
	boosting = false
	anim_player.stop()
	emit_signal("boost", false)
	
	if health <= 0:
		crash()
	else:
		hit_sfx.play()
		sprite.self_modulate = Color.RED
		
		var hit_tween = get_tree().create_tween()
		hit_tween.tween_property(sprite, "self_modulate", Color.WHITE, 1.0)

func crash():
	emit_signal("player_crash")
	print("Crashed!")
	crashed = true
	MotorLoop_sfx.stop()
	explosion_anim.play("Explosion")
	sprite.play("Destroyed")
	crash_sfx.play()
	
	input_enabled = false
	obs_trigger.set_deferred("monitoring", false)
	
	await get_tree().create_timer(2.5).timeout
	emit_signal("show_results")

func fall_out():
	print("Fell Out!")
	emit_signal("player_crash")
	MotorLoop_sfx.stop()
	fallout_sfx.play()
	anim_player.play("FallOut")
	await get_tree().create_timer(0.5).timeout
	explosion_anim.play("Splash")
	splash_sfx.play()
	
	input_enabled = false
	obs_trigger.set_deferred("monitoring", false)
	
	await get_tree().create_timer(1.0).timeout
	emit_signal("show_results")

func reset_position():
	health = 3
	boosting = false
	anim_player.stop()
	sprite.self_modulate = Color.WHITE
	emit_signal("boost", false)
	emit_signal("player_hit", health)
	emit_signal("pause_game", false)
	position = Vector2(320.0, 410.0)
	velocity = Vector2.ZERO
	MotorLoop_sfx.stop()
	obs_trigger.monitoring = true
	crashed = false
	
	if force_tween: force_tween.stop()
	curve_force = 0.0

func apply_curve_force(value : float, time:float):
	force_tween = get_tree().create_tween()
	force_tween.tween_property(self, "curve_force", value * curve_force_mult, time)

func update_sfx_volume(value:float):
	MotorLoop_sfx.volume_db = value
	jump_sfx.volume_db = value
	hit_sfx.volume_db = value
	crash_sfx.volume_db = value
	fallout_sfx.volume_db = value
	splash_sfx.volume_db = value
	bonus_sfx1.volume_db = value
	bonus_sfx2.volume_db = value

func begin_playing():
	MotorLoop_sfx.pitch_scale = 0.6
	change_motor_pitch(1.0)
	enable_input()

func enable_input():
	input_enabled = true
	MotorLoop_sfx.play()

func disable_input():
	input_enabled = false
	MotorLoop_sfx.stop()
