extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label:Label = %MeatLabel
@onready var gold_label:Label = %GoldLabel
@onready var health_label:Label = %HealthLabel
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var initial_health_width = 260

func _process(delta: float):
	# Update timer
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	gold_label.text = str(GameManager.gold_counter)
	
	# Update na barra de vida
	var player: Player = GameManager.player
	if player:
		var health = player.health
		var max_health = player.max_health
		var health_text = "%d/%d" % [player.health, player.max_health]
		health_label.text = health_text
		health_progress_bar.max_value = max_health
		health_progress_bar.value = health
		health_progress_bar.size.x = initial_health_width + max_health
