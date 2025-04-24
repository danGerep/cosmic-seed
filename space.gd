extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

@onready var fuel: ProgressBar = %Fuel
@onready var gravity: ProgressBar = %Gravity

@onready var gravity_timer: Timer = $GravityTimer
@onready var fuel_timer: Timer = $FuelTimer
@onready var star_type: ProgressBar = %StarType

@onready var burn_fuel_label: Label = $CanvasLayer/Control/BurnFuelLabel

@onready var divider_left: Sprite2D = %DividerLeft
@onready var divider_right: Sprite2D = %DividerRight

@onready var star_type_label: Label = %StarTypeLabel

@onready var star: Area2D = $Star

var things: Array = [
	preload("res://good_thing.tscn"),
	preload("res://bad_thing.tscn"),
]
var burning_fuel: bool

var burning_fuel_text = " BURNING FUEL"

var threshold: Array[float] = [
	0.1,
	0.2,
	0.3
]

var start_types: Array[String] = [
	"A",
	"B",
	"C"
]

var current_start_type = 0
var lower_value: float
var higher_value: float


func _ready() -> void:
	fuel.value = 100.0
	gravity.value = 50.0
	star_type.value = 0.0

	spawn_timer.timeout.connect(spawn_timer_timeout)
	gravity_timer.timeout.connect(on_gravity_timer_timeout)
	fuel_timer.timeout.connect(on_fuel_timer_timeout)
	gravity.value_changed.connect(on_gravity_value_changed)
	star_type.value_changed.connect(on_star_type_value_changed)

	GameManager.good_collected.connect(on_good_collected)
	GameManager.bad_collected.connect(on_bad_collected)

	set_threshold_bars()
	calculate_threhold_lower_higher_values()

	star_type_label.text = start_types[current_start_type]

func _process(delta: float) -> void:
	if fuel.value == 0.0:
		burning_fuel = false


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		burning_fuel = !burning_fuel
		if burning_fuel:
			fuel_timer.start()
			burn_fuel_label.text = "STOP %s" % burning_fuel_text
		else:
			fuel_timer.stop()
			burn_fuel_label.text = "START %s" % burning_fuel_text


func set_threshold_bars() -> void:
	var threshold_value = threshold[current_start_type]
	var distance = 250 * threshold_value

	divider_left.position.x = distance
	divider_right.position.x = 250 - distance

	divider_left.visible = true
	divider_right.visible = true


func calculate_threhold_lower_higher_values() -> void:
	var v = threshold[current_start_type] * 100
	lower_value = v
	higher_value = 100 - v


func on_star_type_value_changed(value: float) -> void:
	if value == 100.0:
		current_start_type += 1
		if current_start_type > len(start_types):
			print("game over")
			return

		star_type_label.text = start_types[current_start_type]
		star.change_star_type(current_start_type)
		set_threshold_bars()
		calculate_threhold_lower_higher_values()
		star_type.value = 0.0


func on_gravity_value_changed(value: float) -> void:
	if value <= lower_value:
		print("lower value reached")
	elif value >= higher_value:
		print("higher value reached")


func on_fuel_timer_timeout() -> void:
	if fuel.value > 0.0 and gravity.value < 100.0:
		fuel.value -= 2
		gravity.value -= 5


# More gravity is bad.
func on_gravity_timer_timeout() -> void:
	if !burning_fuel:
		gravity.value += 5


func on_good_collected():
	fuel.value += 10
	star_type.value += 10


func on_bad_collected():
	fuel.value -= 10
	star_type.value -= 5


func spawn_timer_timeout() -> void:
	var scene = things.pick_random()
	
	var thing_instance = scene.instantiate()

	path_follow_2d.progress_ratio = randf()

	add_child(thing_instance)
	thing_instance.position = path_follow_2d.position
