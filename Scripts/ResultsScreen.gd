extends Control

const Score = preload("res://Scripts/Score.gd")
const _Score = preload("res://Resources/Score.tres")
const score_list_res = preload("res://Resources/ScoreList.tres")

var player_score : Resource
var new_score_list : Array

var initials : String
var final_time : int
var final_score : int

var typing := false
var current_letter := 0

@onready var initials_control = $Initials as Control
@onready var letters = [$Initials/HBoxContainer/Letter1, $Initials/HBoxContainer/Letter2, $Initials/HBoxContainer/Letter3]
@onready var scores_control = $Scores as Control
@onready var score_display = $Scores/VBoxContainer/ScoreList as ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	initials_control.hide()
	scores_control.hide()
	
	#player_score = score_res
	#new_score_list = score_list_res.score_array
	
	generate_score_list()
	update_display(0)

func generate_score_list():
	new_score_list.append(Score.new("CPU", 0, 50000))
	new_score_list.append(Score.new("CPU", 0, 30000))
	new_score_list.append(Score.new("CPU", 0, 25000))
	new_score_list.append(Score.new("CPU", 0, 15000))
	new_score_list.append(Score.new("CPU", 0, 10000))
	new_score_list.append(Score.new("CPU", 0, 5000))
	new_score_list.append(Score.new("CPU", 0, 2000))
	new_score_list.append(Score.new("CPU", 0, 1000))

func _input(event):
	if !typing: return
	
	if event is InputEventKey:
		if event.is_released(): return
		var character = OS.get_keycode_string(event.keycode)
		print(character)
		
		if character == "Enter": display_results()
		elif character == "Delete" || character == "Backspace":
			if current_letter > 0: 
				letters[current_letter].self_modulate = Color.WHITE
				current_letter -= 1
			else: current_letter = 0
			
			letters[current_letter].self_modulate = Color.ORANGE
			return
		elif character.length() > 1: return
		
		if current_letter > 2: current_letter = 2
		else:
			letters[current_letter].text = character
			letters[current_letter].self_modulate = Color.WHITE
			current_letter = 2 if current_letter + 1 > 2 else current_letter + 1
			if current_letter < 3: letters[current_letter].self_modulate = Color.ORANGE

func display_initials():
	initials_control.show()
	scores_control.hide()
	typing = true
	current_letter = 0
	for letter in letters.size():
		if letter == 0: 
			letters[letter].text = "A"
			letters[letter].self_modulate = Color.ORANGE
		else:
			letters[letter].text = "A"
			letters[letter].self_modulate = Color.WHITE

func display_results(): #To be fixed
	scores_control.show()
	initials_control.hide()
	typing = false
	
	initials = letters[0].text + letters[1].text + letters[2].text
	print(initials + " " + str(final_time) + " " + str(final_score))
	player_score = Score.new(initials, final_time, final_score)
	
	var ranking := new_score_list.size() - 1 # automatically at bottom of ranking
	for index in range(new_score_list.size()-1, -1, -1):
		if player_score.score > new_score_list[index].score: ranking = index
		else: continue
	new_score_list.insert(ranking, player_score)
	
	update_display(ranking)
	scores_control.show()

func update_display(rank:int):
	score_display.clear()
	
	if new_score_list.size() > 9: new_score_list = new_score_list.slice(0, 9)
	
	for entry in new_score_list:
		score_display.add_item(entry.format_data(), null, true)
	score_display.select(rank)

func initials_entered(text:String):
	initials = text
	display_results()

func set_final_values(time:int, score:int):
	print("Time: " + str(time) + " Score: " + str(score))
	final_time = time
	final_score = score
