extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

@onready var fuel: ProgressBar = %Fuel
@onready var gravity: ProgressBar = %Gravity

@onready var gravity_timer: Timer = $GravityTimer
@onready var fuel_timer: Timer = $FuelTimer
@onready var warning_timer: Timer = $WarningTimer

@onready var star_type: ProgressBar = %StarType

@onready var burn_fuel_label: Label = $CanvasLayer/Control/BurnFuelLabel
@onready var warning: Label = $CanvasLayer/Control/Warning

@onready var divider_left: Sprite2D = %DividerLeft
@onready var divider_right: Sprite2D = %DividerRight

@onready var star_type_label: Label = %StarTypeLabel

@onready var star: Area2D = $Star
@onready var points_label: Label = $CanvasLayer/Control/PointsLabel

var things: Array = [
	preload("res://good_thing.tscn"),
	preload("res://bad_thing.tscn"),
]
var burning_fuel: bool

var burning_fuel_text = " BURNING FUEL"

var threshold: Array[float] = [
	0.1,
	0.2,
	0.3,
	0.4,
	0.45,
]

var start_types: Array[String] = [
	"A",
	"B",
	"C",
	"D",
	"E"
]

var current_start_type = 0
var lower_value: float
var higher_value: float

var total_points = 0
var points_multiplier = 1


func _ready() -> void:
	fuel.value = 100.0
	gravity.value = 50.0
	star_type.value = 0.0

	spawn_timer.timeout.connect(spawn_timer_timeout)
	gravity_timer.timeout.connect(on_gravity_timer_timeout)
	fuel_timer.timeout.connect(on_fuel_timer_timeout)
	gravity.value_changed.connect(on_gravity_value_changed)
	fuel.value_changed.connect(on_fuel_value_changed)
	star_type.value_changed.connect(on_star_type_value_changed)
	warning_timer.timeout.connect(on_warning_timer_timeout)

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
		if current_start_type == len(start_types):
			print("game over")
			return

		star_type_label.text = start_types[current_start_type]
		star.change_star_type(current_start_type)
		set_threshold_bars()
		calculate_threhold_lower_higher_values()
		star_type.value = 0.0
		points_multiplier += 1


func on_gravity_value_changed(value: float) -> void:
	if value == 0.0 or value == 100.0:
		print("game over")
		return

	if value <= lower_value:
		warning.text = "GRAVITY IS TOO LOW"
		warning.visible = true
		warning_timer.start()
	elif value >= higher_value:
		warning.text = "GRAVITY IS TOO HIGH"
		warning.visible = true
		warning_timer.start()


func on_fuel_value_changed(value: float) -> void:
	if value <= 10:
		warning.text = "FUEL IS TOO LOW"
		warning.visible = true
		warning_timer.start()


func on_fuel_timer_timeout() -> void:
	if fuel.value > 0.0 and gravity.value < 100.0:
		fuel.value -= 2
		gravity.value -= 5


# More gravity is bad.
func on_gravity_timer_timeout() -> void:
	if !burning_fuel:
		gravity.value += 5


func on_warning_timer_timeout() -> void:
	warning.visible = false


func on_good_collected():
	fuel.value += 10
	star_type.value += 50
	total_points += 1 * points_multiplier
	update_points()

func on_bad_collected():
	fuel.value -= 10
	star_type.value -= 5
	total_points -= 1 * points_multiplier
	update_points()


func update_points() -> void:
	points_label.text = "%d" % total_points


func spawn_timer_timeout() -> void:
	var scene = things.pick_random()
	
	var thing_instance = scene.instantiate()

	path_follow_2d.progress_ratio = randf()

	add_child(thing_instance)
	thing_instance.position = path_follow_2d.position
