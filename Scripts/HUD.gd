extends Control

var playing := false
var start_time := 0.0
var current_time = 0.0
var carryover_time = 0.0
var current_points := 0
var point_mult := 1

var final_time := 0.0
var final_points := 0

var score_color = Color.WHITE

@export var boost_mult := 2

@onready var tutorial_text = $TutorialLabel1
@onready var timer = $TimePanel/TimeLabel as Label
@onready var score = $ScorePanel/PointsLabel as Label
@onready var start_lights = $StartLights as TextureRect
@onready var light_covers = [$StartLights/LightCover1, $StartLights/LightCover2, $StartLights/LightCover3, $StartLights/LightCover4]
@onready var countdown_sfx = $Countdown_SFX
@onready var countdownfinal_sfx = $CountdownFinal_SFX
@onready var health_units = [$HealthUnits/HealthUnit1, $HealthUnits/HealthUnit2, $HealthUnits/HealthUnit3]

signal parse_final_values(time:float, score:int)


func _ready():
	tutorial_text.hide()
	update_health(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !playing: return
	
	current_points += (1 * point_mult)
	score.text = format_score(current_points)
	
	current_time = (Time.get_ticks_msec() - start_time) + carryover_time
	timer.text = format_time(current_time)

func format_score(value:int) ->String:
	var text = "00000000"
	var str_value = str(value)
	if str_value.length() > text.length(): return "99999999"
	
	var temp = text.substr(0, (text.length() - str_value.length()) - 1)
	return temp + str_value + " "

func format_time(value:float) ->String:
	var format = "{m}:{s}.{ms}"
	var text = "000000"
	var str_value = str(floorf(value / 10.0))
	
	var length_offset = abs(text.length() - str_value.length())
	for letter in str_value.length():
		text[length_offset + letter] = str_value[letter]
	
	var formatted_value = format.format({"m": text.substr(0,2), "s": text.substr(2,2), "ms": text.substr(4)})
	#print("text: " + text + " formatted: " + formatted_value)
	return formatted_value + " "

func play_light_intro():
	start_lights.show()
	for light in light_covers:
		light.show()
	
	await get_tree().create_timer(1.5).timeout
	light_covers[0].hide()
	countdown_sfx.play()
	await get_tree().create_timer(1.0).timeout
	light_covers[1].hide()
	countdown_sfx.play()
	await get_tree().create_timer(1.0).timeout
	light_covers[2].hide()
	countdown_sfx.play()
	await get_tree().create_timer(1.0).timeout
	light_covers[3].hide()
	countdownfinal_sfx.play()
	await get_tree().create_timer(0.5).timeout
	start_lights.hide()
	
	display_tutorial()

func display_tutorial():
	tutorial_text.show()
	
	await get_tree().create_timer(4.0).timeout
	tutorial_text.hide()

func reset_hud_text():
	score.text = "00000000 "
	timer.text = "00:00.00 "

func timer_start():
	playing = true
	carryover_time = 0.0
	start_time = Time.get_ticks_msec()

func timer_pause(paused:bool):
	if paused:
		playing = false
		carryover_time = current_time
	else:
		playing = true
		start_time = Time.get_ticks_msec()
	
func timer_end():
	playing = false
	start_time = Time.get_ticks_msec()
	final_time = current_time
	final_points = current_points
	emit_signal("parse_final_values", final_time, final_points)

func update_volume(value:float):
	countdownfinal_sfx.volume_db = value
	countdown_sfx.volume_db = value

func update_health(value:int):
	var health_color = Color.GREEN
	if value < 1: health_color = Color.WEB_GRAY
	elif value < 2: health_color = Color.RED
	elif value < 3: health_color = Color.YELLOW
	
	for unit in health_units.size():
		if unit + 1 <= value: health_units[unit].self_modulate = health_color
		else: health_units[unit].self_modulate = Color.WHITE

func increase_score(value:int):
	current_points += value
	
	score.self_modulate = Color.GOLD
	var score_color_tween = create_tween()
	score_color_tween.tween_property(score, "self_modulate", score_color, 1.0)

func change_point_mult(active:bool):
	point_mult = boost_mult if active else 1
	
	score_color = Color.HOT_PINK if active else Color.WHITE
	score.self_modulate = score_color
