class_name Player
extends CharacterBody2D

@export var coyote_time : float = 0.2
@export var jump_buffer_time : float = 0.2
@export var jump_limit : int = 2 #if more that 1, allow jump while on air
const SPEED = 200.0
const JUMP_VELOCITY = -320.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var airborne : float = 0.0 
var jump_buffer : float = -1.0
var jump_count : int = 0

@onready var animation_player = $AnimationPlayer
@onready var knight = $Knight

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		airborne += delta
		if jump_count == 0 and airborne > coyote_time:
			jump_count = 1
	else:
		airborne = 0.0
		jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") :
		jump_buffer = jump_buffer_time
		
	#if jump_buffer >= 0.0 and airborne < coyote_time and jump_count < jump_limit:
	if jump_buffer >= 0.0 and jump_count < jump_limit:
		velocity.y = JUMP_VELOCITY
		jump_buffer = -1.0
		jump_count += 1
	
	jump_buffer = clamp(jump_buffer - delta, -1.0, jump_buffer_time)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	#ANIMATION AND SPRITE FACING
	if abs(velocity.x) < 0.1:
		play_idle()
	else:
		play_walk()
		if velocity.x > 0:
			knight.flip_h = false
		else:
			knight.flip_h = true
			
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
func play_idle():
	if animation_player.current_animation != "IDLE":
		animation_player.play("IDLE")
		
func play_walk():
	if animation_player.current_animation != "WALK":
		animation_player.play("WALK")
	
