extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 125
const FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT

#Path to a node (the reference)
onready var animationPlayer = $AnimationPlayer 
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

# Main loop (n every single physic step)
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state()
	

func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	#Debug movement
	#print(input_vector)
	
	#When the player is  moving...
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		#Acceleration and max speed of the player
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	
	#When the player is not moving...	
	else:
		animationState.travel("Idle")
		#Slow the player when keys no pressed
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	#Debug velocity
	#print(velocity)
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity  * 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE
