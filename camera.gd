extends Camera2D

func _process(_delta):
	var player_position: Vector2 = GameManager.player_position
	if player_position:
		global_position = player_position
