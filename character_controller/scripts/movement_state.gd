extends Node
class_name MovementState


enum Velocity_Tag{
	MOVE = 1 << 0,        # int 1
	JUMP = 1 << 1,        # int 2
	
	ALL = MOVE | JUMP
}
var _used_tags: int = 0

@export var enabled: bool = false

var input_direction: Vector3 = Vector3.ZERO
var input_magnitude: float = 0.0

var impulse_direction: Vector3 = Vector3.ZERO
var impulse_magnitude: float = 0.0

var input_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	set_physics_process(enabled)


func enter() -> void:
	enabled = true
	set_physics_process(true)

func exit() -> void:
	enabled = false
	set_physics_process(false)

# sets a force to be continuously applied to the object on the X/Z plane
func move(direction: Vector3, speed: float) -> void:
	if !enabled:
		return
	
	if !direction.is_normalized():
		direction = direction.normalized()
	input_direction = direction
	input_magnitude = speed

# sets a force to be added to the object
func add_impulse(direction: Vector3, speed: float) -> void:
	if !enabled:
		return
	
	if !direction.is_normalized():
		direction = direction.normalized()
	impulse_direction = direction
	impulse_magnitude = speed



func add_velocity(velocity: Vector3, tag: int = 0) -> void:
	if tag != 0:
		if (_used_tags & tag):
			return
		else:
			_used_tags |= tag
	input_velocity += velocity

func clear_velocity() -> void:
	input_velocity = Vector3.ZERO
	_used_tags = 0
