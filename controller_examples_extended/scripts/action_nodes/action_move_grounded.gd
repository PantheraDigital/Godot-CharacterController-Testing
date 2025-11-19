extends BaseActionMove

## Grounded movement logic

func play(_params: Dictionary = {}) -> void:
	if !_params.has("input_direction"):
		return
	
	var dir: Vector3 = _params["input_direction"]
	if !dir.is_normalized():
		dir = dir.normalized()
	dir.y = 0.0
	
	var speed: float = _state_data_manager.get_currnet_data().move_speed
	_movement_manager.active_state.add_velocity(dir * (speed * _speed_multiplier), _movement_manager.active_state.Velocity_Tag.MOVE)
	
	super.play()
	super.stop()
