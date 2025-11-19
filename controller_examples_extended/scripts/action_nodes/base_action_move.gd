extends ActionNode
class_name BaseActionMove


enum SPEED_SETTING {FAST, NORMAL, SLOW}

var _speed_multiplier: float = 1.0
var _movement_manager: MovementStateManager
var _state_data_manager: StateDataManager


func _init() -> void:
	self.ACTION_ID = "MOVE"
	self.IS_LAYERED = true

func refresh() -> void:
	var character = container.get_parent()
	_movement_manager = character.find_child("MovementStateManager", false)
	_state_data_manager = character.find_child("StateDataManager", false)


func can_play() -> bool:
	if !super.can_play() or !_movement_manager or !_state_data_manager:
		return false
	return true


func set_speed(setting: SPEED_SETTING) -> void:
	var state_data: CharacterStateData = _state_data_manager.get_currnet_data()
	match setting:
		SPEED_SETTING.FAST:
			_speed_multiplier = state_data.move_speed_multiplier_fast
		SPEED_SETTING.NORMAL:
			_speed_multiplier = 1.0
		SPEED_SETTING.SLOW:
			_speed_multiplier = state_data.move_speed_multiplier_slow
