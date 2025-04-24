extends Area2D

@onready var devour: Area2D = $Devour
@onready var star_image: Node = $StarImage

var star_types = [
	preload("res://a_star.tscn"),
	preload("res://b_star.tscn"),
	preload("res://c_star.tscn"),
	preload("res://d_star.tscn"),
	preload("res://e_star.tscn")
]

var current_star


func _ready() -> void:
	var star_instance = star_types[0].instantiate()
	current_star = star_instance
	star_image.add_child(current_star)

	devour.body_entered.connect(on_body_entered)


func change_star_type(type: int) -> void:
	star_image.remove_child(current_star)

	current_star = star_types[type].instantiate()
	star_image.add_child(current_star)


func on_body_entered(body: Node2D) -> void:
	if body.what == "good":
		GameManager.good_collected.emit()
	else:
		GameManager.bad_collected.emit()

	body.queue_free()
