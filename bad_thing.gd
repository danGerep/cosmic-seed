extends RigidBody2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var label: Label = $Label

var current_key
var letters: Dictionary = {
	KEY_Q: "Q", KEY_W: "W",
	KEY_E: "E",KEY_R: "R",
	KEY_A:"A",KEY_S:"S",
	KEY_D:"D",KEY_F:"F",
	KEY_Z:"Z",KEY_X:"X",
	KEY_C:"C",KEY_V:"V"
}

var what = "bad"

func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	var key = letters.keys().pick_random()
	label.text = letters[key]
	current_key = key


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.key_label == current_key:
			queue_free()
