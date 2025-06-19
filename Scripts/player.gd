extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var is_attacking = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

func _ready() -> void:
	# Connect signals
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	attack_hitbox.connect("body_entered", Callable(self, "_on_attack_hitbox_body_entered"))
	attack_hitbox.set_monitoring(false)  # Turn off hitbox initially

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If attacking, lock out movement (optional: could still allow gravity)
	if is_attacking:
		move_and_slide()
		return

	# Input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump_start")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")
		attack_hitbox.set_monitoring(true)
		velocity.x = 0  # Stop horizontal movement during attack (optional)
		return

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Apply horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_hitbox.set_monitoring(false)

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage()
