extends Node2D

@export var game_ui: CanvasLayer
@export var game_over_ui_template: PackedScene


signal monster_defeated()

func _ready():
	GameManager.game_over.connect(trigger_game_over)
	GameManager.player.monster_defeated.connect(on_monster_defeated)
	
#func _process(_delta):
	#if GameManager.is_game_over:
		#trigger_game_over()

func trigger_game_over():
	# Deletar GameUI
	if game_ui:
		game_ui.queue_free()
		game_ui = null
	# Criar GameOverUI
	var game_over_ui: GameOverUI = game_over_ui_template.instantiate()
	add_child(game_over_ui)

func on_monster_defeated():
	GameManager.monsters_defeated += 1
