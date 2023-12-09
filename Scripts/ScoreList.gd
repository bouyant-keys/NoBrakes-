extends Resource

@export var null_score : Resource
@export var score_array : Array

func get_score_at(index:int) ->Resource:
	if index > score_array.size() or index < 0: return null_score
	return score_array[index]
