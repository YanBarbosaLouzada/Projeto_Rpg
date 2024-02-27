extends CharacterBody2D

var _state_machine
var _is_dead:bool = false
var _is_attacking: bool = false

@export_category("Variables")
@export var _move_speed: float = 64.0
@export var _accelaration: float = 0.8
@export var _friction: float = 0.4
@export_category("Objects")
@export var _animation_tree: AnimationTree = null
@export var _attack_timer: Timer = null

func _ready() -> void:
	_state_machine = _animation_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_move()
	_attack()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	if _direction != Vector2.ZERO:
		_animation_tree["parameters/Idle/blend_position"] = _direction
		_animation_tree["parameters/Walk/blend_position"] = _direction
		_animation_tree["parameters/Attack/blend_position"] = _direction
		

		self.velocity.x = lerp(self.velocity.x, _direction.x * _move_speed, _accelaration)
		self.velocity.y = lerp(self.velocity.y, _direction.y * _move_speed, _accelaration)
	else:
		self.velocity.x = lerp(self.velocity.x, 0.0, _friction)
		self.velocity.y = lerp(self.velocity.y, 0.0, _friction)
	
func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		set_physics_process(false)
		_attack_timer.start()
		_is_attacking = true
		pass
		

func _animate() -> void:
	if _is_dead:
		_state_machine.travel("death")
		return
	if _is_attacking:	
		_state_machine.travel("Attack")
		return
	if self.velocity.length() > 1:
		_state_machine.travel("Walk")
	else:
		_state_machine.travel("Idle")


func _on_timer_timeout():
	set_physics_process(true)
	_is_attacking = false
	pass # Replace with function body.


func _on_attack_area_body_entered(_body) -> void :
	if _body.is_in_group("enemy"):
		_body.update_health()
		

func die()->void:
	_is_dead = true
	_state_machine.travel("Death")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
