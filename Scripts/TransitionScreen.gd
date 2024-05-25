extends ColorRect

var melting := false
var timer := 0.0

@export var x_resolution := 100.0
@export var max_offset := 2.0
@export var melt_speed := 0.2


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("Dev_Add"): print(self.material.get_shader_parameter("screen_tex"))
	
	if melting:
		timer += melt_speed * delta
		self.material.set_shader_parameter("timer", timer)

func generate_offsets():
	timer = 0.0
	var offsets = []
	for i in x_resolution:
		offsets.append(randf_range(1.0, max_offset))
	self.material.set_shader_parameter("y_offsets", offsets)
	
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	self.material.set_shader_parameter("melt_tex", tex)
	
	show()

func transition():
	self.material.set_shader_parameter("melting", true)
	melting = true
