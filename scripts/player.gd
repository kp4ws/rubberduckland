extends CharacterBody3D
class_name Player

# ───────────────────────
# Movement & Jump settings
# ───────────────────────
@export var speed: float = 5.0
@export var acceleration: float = 6.0
@export var rotation_speed: float = 10.0
@export var jump_velocity: float = 8.0

# ───────────────────────
# Camera settings
# ───────────────────────
@export var mouse_sensitivity: float = 0.0015

# ───────────────────────
# Internal Settings
# ───────────────────────
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_captured = true

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var model: Node3D = $Rig

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	get_move_input(delta)
	move_and_slide()
	rotate_model_toward_movement(delta)

# ───────────────────────
# Movement
# ───────────────────────
func get_move_input(delta: float) -> void:
	var input := Input.get_vector("left", "right", "forward", "back")

	# Camera-relative direction
	var direction := Vector3(input.x, 0, input.y)
	direction = direction.rotated(Vector3.UP, spring_arm.rotation.y)
	direction = direction.normalized()

	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var target_velocity := direction * speed

	horizontal_velocity = horizontal_velocity.lerp(
		target_velocity,
		acceleration * delta
	)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

# ───────────────────────
# Rotation
# ───────────────────────
func rotate_model_toward_movement(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)

	if horizontal_velocity.length() < 0.1:
		return

	var target_yaw := atan2(horizontal_velocity.x, horizontal_velocity.z)
	model.rotation.y = lerp_angle(
		model.rotation.y,
		target_yaw,
		rotation_speed * delta
	)

# ───────────────────────
# Mouse look
# ───────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity

		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x,
			deg_to_rad(-60.0),
			deg_to_rad(30.0)
		)
	elif event is InputEventKey and event.is_pressed():
		# Toggle mouse capture with ui_cancel
		if Input.is_action_just_pressed("ui_cancel"):
			mouse_captured = not mouse_captured
			if mouse_captured:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
