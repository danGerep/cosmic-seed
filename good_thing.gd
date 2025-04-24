extends RigidBody2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var area_2d: Area2D = $MouseArea

var draggable: bool
var what = "good"


func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)

	area_2d.mouse_entered.connect(mouse_entered)
	area_2d.mouse_exited.connect(mouse_exited)


func mouse_entered() -> void:
	draggable = true


func mouse_exited() -> void:
	draggable = false


func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_mouse") and draggable:
		position = get_global_mouse_position()
		sleeping = true
	else:
		sleeping = false
