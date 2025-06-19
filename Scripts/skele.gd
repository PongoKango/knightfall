extends CharacterBody2D

const SPEED = 60
# Get the default gravity from project settings.
# It's good practice to make this a class variable so it's only fetched once.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = 1
@onready var raycast_right: RayCast2D = $"Raycast Right"
@onready var raycast_left: RayCast2D = $"Raycast Left"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Use _physics_process for all physics-related movement and checks.
# This includes gravity and move_and_slide().
func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	# Only apply gravity if the character is not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# If on the floor, ensure vertical velocity is zero to prevent jitter
		# This is often handled by move_and_slide(), but explicit can be clearer.
		velocity.y = 0


	# 2. Horizontal Movement (based on your existing logic)
	# Check for wall collisions with raycasts
	if direction == 1 and raycast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif direction == -1 and raycast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	# Set horizontal velocity based on direction and speed
	velocity.x = direction * SPEED

	# 3. Move and Slide
	# This method takes the velocity, moves the CharacterBody2D, and handles collisions.
	# It automatically stops movement along axes where a collision occurs (e.g., stops falling on floor).
	move_and_slide()

	# Optional: Animation Update (often done in _process, but can be here too)
	# This ensures your animation state updates with movement.
	if is_on_floor():
		if abs(velocity.x) > 0: # If moving horizontally
			animated_sprite.play("walk") # Or your walking animation
		else:
			animated_sprite.play("idle") # Or your idle animation


# _process is generally for non-physics related updates like UI, input polling for non-physics actions, etc.
# Your current movement logic should be moved to _physics_process.
func _process(delta: float) -> void:
	# Any non-physics related updates can go here if needed.
	pass # No need for movement logic here anymore
