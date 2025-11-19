extends BaseActionMove

## Flight logic

var _use_aim: bool

func play(_params: Dictionary = {}) -> void:
	if !_params.has("input_direction"):
		return
	
	var dir: Vector3 = _params["input_direction"]
	if _params.has("aim_direction") and dir != Vector3.ZERO and _use_aim:
		dir.y = _params["aim_direction"].y
	
	if !dir.is_normalized():
		dir = dir.normalized()
	
	var speed: float = _state_data_manager.get_currnet_data().move_speed
	_movement_manager.active_state.add_velocity(dir * (speed * _speed_multiplier), _movement_manager.active_state.Velocity_Tag.MOVE)
	
	super.play()
	super.stop()


func set_use_aim(enabled: bool) -> void:
	_use_aim = enabled
