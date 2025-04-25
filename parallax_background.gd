extends ParallaxBackground


@export var scroll_speed: float = -200.0  # Adjust speed as needed

func _process(delta):
	scroll_offset.x += scroll_speed * delta
	print(scroll_offset.x)
