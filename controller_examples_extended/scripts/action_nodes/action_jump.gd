extends ActionNode


var _movement_manager: MovementStateManager
var _state_data_manager: StateDataManager


func _init() -> void:
	self.ACTION_ID = "JUMP"

## Called by ActionContainer when action is added to active actions.
## Use to set variables that may depend on container var being set.
func refresh() -> void:
	var character = container.get_parent()
	_movement_manager = character.find_child("MovementStateManager", false)
	_state_data_manager = character.find_child("StateDataManager", false)

# logic for if ActionContainer can play this action
func can_play() -> bool:
	if !super.can_play() or !_movement_manager or !_state_data_manager:
		return false
	return true

# actual logic for performing this action
# called once till is_playing == false (set in super.stop())
func play(_params: Dictionary = {}) -> void:
	_movement_manager.active_state.add_velocity(Vector3.UP * _state_data_manager.get_currnet_data().move_speed, _movement_manager.active_state.Velocity_Tag.JUMP)
	super.play()
	super.stop()
