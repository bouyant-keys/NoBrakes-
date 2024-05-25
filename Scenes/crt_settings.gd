extends ColorRect


# Called when the node enters the scene tree for the first time.
func update_shader_brightness(value:float):
	self.material.set_shader_parameter("maskDark", value)
