extends Control

static var active_menu = ""

@export_node_path() var trans_path

@onready var menus = [$StartMenu, $HUD, $PauseMenu, $Results]
@onready var start_screen_anim = $StartMenu/StartMenuTextFlash
@onready var button_sfx = $ButtonPressed_SFX
@onready var start_sfx = $StartButtonPressed_SFX
@onready var new_trans = get_node(trans_path)

signal un_pause(value:bool)
signal start_game
signal stop_game
signal reset_game
signal update_music_vol(value:float)
signal update_sfx_vol(value:float)
signal update_brightness(value:float)
signal music_change(index:int)


func _ready():
	set_active_menu(0)
	show()

func swap_menus_with_transition(menu_index:int):
	new_trans.generate_offsets()
	set_active_menu(menu_index)
	
	await get_tree().create_timer(0.1).timeout
	new_trans.transition()

func set_active_menu(menu_index:int):
	for index in menus.size():
		if index == menu_index:
			menus[index].show()
		else: menus[index].hide()
	
	active_menu = menus[menu_index]
	menu_specific_actions(menu_index)

# Used to hard-code specific actions based on menu change
func menu_specific_actions(menu_index:int):
	if menu_index == 0:
		start_screen_anim.play("text_flash_loop")
		emit_signal("music_change", 0)
	elif menu_index == 3:
		menus[3].display_initials()
		emit_signal("music_change", 2)

func pause(activate:bool):
	if !GameManager.is_playing: return
	menus[1].timer_pause(activate)
	if activate:
		set_active_menu(2)
	else:
		set_active_menu(1)

func display_results():
	swap_menus_with_transition(3)

#
# Sent Signals
#

func on_start_pressed():
	start_sfx.play()
	start_screen_anim.play("Start_Pressed_Hold")
	emit_signal("music_change", -1)
	emit_signal("start_game")
	
	await get_tree().create_timer(1.0).timeout
	swap_menus_with_transition(1)
	await get_tree().create_timer(0.2).timeout
	menus[1].reset_hud_text()
	menus[1].play_light_intro()
	emit_signal("music_change", 1)

func on_resume_pressed():
	print("Resuming Game")
	button_sfx.play()
	pause(false)
	emit_signal("un_pause",false)

func on_restart_pressed():
	print("Restarting Game")
	button_sfx.play()
	emit_signal("reset_game")
	swap_menus_with_transition(1)
	
	await get_tree().create_timer(0.2).timeout
	menus[1].reset_hud_text()
	menus[1].play_light_intro()
	emit_signal("music_change", 1)

func on_menu_pressed():
	print("Returning to Menu")
	button_sfx.play()
	emit_signal("stop_game")
	swap_menus_with_transition(0)

func on_music_slider_changed(value:float):
	# Decibel audio range: -60 to 0 dB
	# Each increment of 6dB alters the current audio by half, so -6dB is half, -12dB is a quarter
	emit_signal("update_music_vol", value)

func on_sfx_slider_changed(value:float):
	# Decibel audio range: -60 to 0 dB
	button_sfx.volume_db = value
	start_sfx.volume_db = value
	button_sfx.play()
	menus[1].update_volume(value)
	emit_signal("update_sfx_vol", value)
func on_sfx_drag_ended(_value:bool):
	button_sfx.play()

func on_brightness_slider_changed(value:float):
	# Range from 0 - 1
	button_sfx.play()
	emit_signal("update_brightness", value)


#
# Recieved signals
#

func update_health(value:int):
	menus[1].update_health(value)

func add_to_score(value:int):
	menus[1].increase_score(value)

func add_boost(active:bool):
	menus[1].change_point_mult(active)

func start_stopwatch():
	menus[1].timer_start()

func stop_stopwatch():
	menus[1].timer_end()

func on_player_crash():
	stop_stopwatch()
