extends ActionNode


var _movement_manager: MovementStateManager
var _state_data_manager: StateDataManager
var _cam: Camera3DExtended


func _init() -> void:
	self.ACTION_ID = "TOGGLE_MOVE_STATE"
	self.IS_LAYERED = true

# Called by ActionContainer when action is added to it.
# Use to set variables that may change if the the ActionContainer changes.
func refresh() -> void:
	var character = container.get_parent()
	_movement_manager = character.find_child("MovementStateManager", false)
	_state_data_manager = character.find_child("StateDataManager", false)
	_cam = character.find_child("Camera3D")

# logic for if ActionContainer can play this action
func can_play() -> bool:
	if !super.can_play() or !_movement_manager:
		return false
	return true

# actual logic for performing this action
func play(_params: Dictionary = {}) -> void:
	# handle transition to new movement state
	match _movement_manager.active_state.name:
		"GroundedMovement":
			_movement_manager.set_active_state("FlyingMovement")
			_cam.change_fov(Camera3DExtended.FOV_SETTINGS.FLY)
			container.reconfigure("flying")
			_state_data_manager.set_currnet_data(StateDataManager.DATA_TYPE.FLYING)
	
		"FlyingMovement":
			_movement_manager.set_active_state("GroundedMovement")
			_cam.change_fov(Camera3DExtended.FOV_SETTINGS.NORMAL)
			container.reconfigure("grounded")
			_state_data_manager.set_currnet_data(StateDataManager.DATA_TYPE.GROUNDED)
	
	# transition state does not trigger enter or exit
	# it only changes the character to enter a different state
