class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 5
@export var sword_crit_chance: float = 0.15
@export_category("Ritual")
@export var ritual_damage: int = 3
@export var ritual_interval: float = 10.0
@export var ritual_prefab: PackedScene
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene


@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var is_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 10.0
var attack_direction:Vector2

signal meat_collected()
signal gold_collected(amount:int)
signal monster_defeated()

func _ready():
	GameManager.player = self
	meat_collected.connect(func(): GameManager.meat_counter += 1)
	gold_collected.connect(func(amount): GameManager.gold_counter += amount)
	

func _process(delta: float) -> void:
	GameManager.player_position = position
	
	# Atualizar o temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
	
	
	
	# Processar dano
	update_hitbox_detection(delta)
	update_ritual(delta)
	
	# Atualizar barra de vida
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	

func _physics_process(delta: float) -> void:
	# Obter o input vector
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar deadzone do input vector - Para controles
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0
	
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0
	
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	
	if is_attacking:
		target_velocity *= 0.25
		
	velocity = lerp(velocity, target_velocity, 0.1)	
	move_and_slide()
	
	# Atualizar o is_running
		
	var was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
	if not is_attacking:
		# Tocar animação
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
				
	
		# Girar sprite
		if input_vector.x > 0:
			sprite.flip_h = false
		elif input_vector.x < 0:
			sprite.flip_h = true
		
	# Ataque
	if Input.is_action_just_pressed("attack"):
		if sprite.flip_h == false:
			attack_direction = Vector2(1.0, input_vector.y)
		else:
			attack_direction = Vector2(-1.0, input_vector.y)
		attack(input_vector)
	

func attack(vector: Vector2) -> void:
	if is_attacking:
		return
	
	# Tocar animação
	var sprite_attack_type = str(randi_range(1,2))

	if vector.y < 0:
		animation_player.play("attack_up_" + sprite_attack_type)
	elif vector.y > 0:
		animation_player.play("attack_down_" + sprite_attack_type)
	else:
		animation_player.play("attack_side_" + sprite_attack_type)
	
	# Configurar temporizador
	attack_cooldown = 0.6
	# Marcar ataque
	is_attacking = true
	
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy:Vector2 = (enemy.position - position).normalized()
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.5:
				var is_crit: bool = randf() <= sword_crit_chance
				var final_damage: float = sword_damage * 2 if is_crit else sword_damage
				enemy.damage(final_damage, is_crit)			

func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	# Frequência (2x por segundo)
	hitbox_cooldown = 0.5
	
	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = enemy.damage_amount
			damage(damage_amount)
			

func damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	print("Player recebeu dano de ", amount, ", A vida total é de ", health)
	
	# Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self,"modulate", Color.WHITE, 0.3)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	# Processar morte
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	queue_free()
	
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player curou ", amount, ", A vida total é de ", health)
	
	return health

func summon_ritual():
	if ritual_prefab:
		var ritual_object: Ritual = ritual_prefab.instantiate()
		ritual_object.damage_amount = ritual_damage
		add_child(ritual_object)
		
func update_ritual(delta: float) -> void:
	# Temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	
	# Frequência (1x / 10 sec)
	ritual_cooldown = ritual_interval
	summon_ritual()
	
func increase_max_health(amount: int) -> int:
	max_health += amount
	print("Player aumentou a vida em ", amount, ", A vida máxima é de ", max_health)
	return max_health
