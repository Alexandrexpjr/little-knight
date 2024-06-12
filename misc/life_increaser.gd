extends Node2D

@export var health_amout:int = 10
@onready var text_marker = $TextDigitMarker

var text_prefab: PackedScene

func _ready():
	$Area2D.body_entered.connect(on_body_entered)
	text_prefab = preload("res://misc/maxhealth_digit.tscn")
	
func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.increase_max_health(health_amout)
		var text = text_prefab.instantiate()
		
		if text_marker:
			text.global_position = text_marker.global_position

		
		get_parent().add_child(text)
		#player.meat_collected.emit()
		queue_free()
