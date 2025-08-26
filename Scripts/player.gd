extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0
const ROLL_DURATION = 1.0

#This states the player states
enum PlayerState {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	ROLLING,
	ATTACK_1,
	ATTACK_2,
}

var state: PlayerState = PlayerState.IDLE
var roll_timer: float = 0.0
var roll_direction: float = 0.0
var queued_attack: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	handle_input()
	apply_physics(delta)
	update_state(delta)
	update_animation()
	move_and_slide()

func handle_input():
	var direction := Input.get_axis("move_left", "move_right")

	if state != PlayerState.ROLLING and state != PlayerState.ATTACK_1 and state != PlayerState.ATTACK_2:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			state = PlayerState.JUMPING
		elif Input.is_action_just_pressed("attack") and is_on_floor():
			state = PlayerState.ATTACK_1
			queued_attack = false
		elif Input.is_action_just_pressed("roll") and is_on_floor():
			if direction != 0:
				roll_direction = direction
			else:
				roll_direction = -1 if animated_sprite.flip_h else 1
			animated_sprite.flip_h = roll_direction < 0
			roll_timer = ROLL_DURATION
			state = PlayerState.ROLLING
		else:
			if direction != 0:
				state = PlayerState.RUNNING
			else:
				state = PlayerState.IDLE

func apply_physics(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

func update_state(delta: float):
	var direction := Input.get_axis("move_left", "move_right")

	match state:
		PlayerState.ROLLING:
			velocity.x = roll_direction * ROLL_SPEED
			roll_timer -= delta
			if roll_timer <= 0.0:
				if is_on_floor():
					if direction != 0:
						state = PlayerState.RUNNING
					else:
						state = PlayerState.IDLE
				else:
					state = PlayerState.FALLING
		PlayerState.ATTACK_1:
			velocity.x = 0
		PlayerState.ATTACK_2:
			velocity.x = 0
		PlayerState.JUMPING:
			if velocity.y > 0:
				state = PlayerState.FALLING
		PlayerState.FALLING:
			if is_on_floor():
				if direction != 0:
					state = PlayerState.RUNNING
				else:
					state = PlayerState.IDLE
		PlayerState.RUNNING:
			if direction == 0:
				state = PlayerState.IDLE
		PlayerState.IDLE:
			if not is_on_floor():
				state = PlayerState.FALLING

	if state != PlayerState.ROLLING and state != PlayerState.ATTACK_1 and state != PlayerState.ATTACK_2:
		velocity.x = direction * SPEED

func update_animation():
	match state:
		PlayerState.IDLE:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		PlayerState.RUNNING:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
			animated_sprite.flip_h = velocity.x < 0
		PlayerState.JUMPING:
			if animated_sprite.animation != "jump":
				animated_sprite.play("jump")
			animated_sprite.flip_h = velocity.x < 0
		PlayerState.FALLING:
			if animated_sprite.animation != "falling":
				animated_sprite.play("falling")
			animated_sprite.flip_h = velocity.x < 0
		PlayerState.ROLLING:
			if animated_sprite.animation != "roll":
				animated_sprite.play("roll")
		PlayerState.ATTACK_1:
			if animated_sprite.animation != "attack":
				animated_sprite.play("attack")
		PlayerState.ATTACK_2:
			if animated_sprite.animation != "attack_2":
				animated_sprite.play("attack_2")

func _on_animation_finished():
	if state == PlayerState.ATTACK_1:
		if Input.is_action_pressed("attack"):
			state = PlayerState.ATTACK_2
		else:
			state = PlayerState.IDLE if is_on_floor() else PlayerState.FALLING
	elif state == PlayerState.ATTACK_2:
		state = PlayerState.IDLE if is_on_floor() else PlayerState.FALLING
