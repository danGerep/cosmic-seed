extends Area2D

@onready var devour: Area2D = $Devour
@onready var star_image: Node = $StarImage
@onready var outter_sprite: Sprite2D = %OutterSprite
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

var star_types = [
	preload("res://a_star.tscn"),
	preload("res://b_star.tscn"),
	preload("res://c_star.tscn"),
	preload("res://d_star.tscn"),
	preload("res://e_star.tscn")
]

var star_gravity_radius = [
	25,
	50,
	100,
	150,
	200
]

var star_rim_radius = [
	0.5,
	1.0,
	2.0,
	3.0,
	4.0
]

var current_star
var animation_time: float
var current_scale: float


func _ready() -> void:
	var star_instance = star_types[0].instantiate()
	current_star = star_instance
	star_image.add_child(current_star)

	devour.body_entered.connect(on_body_entered)
	current_scale = star_rim_radius[0]


func _process(delta: float) -> void:
	animation_time += delta
	var x = (cos(animation_time) + 1) / 2
	var y = remap(x, 0.0, 1.0, 0.9, 1.0)

	outter_sprite.scale = Vector2(current_scale, current_scale) * y


func change_star_type(type: int) -> void:
	collision_shape_2d.shape.radius = star_gravity_radius[type]
	outter_sprite.scale = Vector2(star_rim_radius[type],star_rim_radius[type])
	current_scale = star_rim_radius[type]
	star_image.remove_child(current_star)
	current_star = star_types[type].instantiate()
	star_image.add_child(current_star)


func on_body_entered(body: Node2D) -> void:
	if body.what == "good":
		GameManager.good_collected.emit()
	else:
		GameManager.bad_collected.emit()

	body.queue_free()
