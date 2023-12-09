extends Resource

@export var name : String
@export var time : int
@export var score : int

# Init functions must have optional parameters
func _init(new_name:String = "", new_time:int = 0, new_score:int = 0):
	name = new_name
	time = new_time
	score = new_score

func format_data() ->String:
	return name + "    " + format_time(time) + "    " + format_score(score)

func format_score(value:int) ->String:
	var text = "00000000"
	var str_value = str(value)
	if str_value.length() > text.length(): return "99999999"
	
	var temp = text.substr(0, (text.length() - str_value.length()) - 1)
	return temp + str_value

func format_time(value:int) ->String:
	var format = "{m}:{s}.{ms}"
	var text = "000000"
	var str_value = str(floorf(value/10.0))
	
	var length_offset = abs(text.length() - str_value.length())
	for letter in str_value.length():
		text[length_offset + letter] = str_value[letter]
	
	var formatted_value = format.format({"m": text.substr(0,2), "s": text.substr(2,2), "ms": text.substr(4)})
	return formatted_value + " "

func clear_data():
	name = "N/A"
	time = 00000000
	score = 00000000
