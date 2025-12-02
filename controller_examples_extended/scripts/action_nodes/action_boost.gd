extends ActionNode


var _cam_pivot: CamControl
var _movement_manager: MovementStateManager
var power: float = 10.0

var character


func _init() -> void:
	self.ACTION_ID = "JUMP"
	self.IS_LAYERED = true

## Called by ActionContainer when action is added to active actions.
## Use to set variables that may depend on container var being set.
func refresh() -> void:
	character = container.get_parent()
	_cam_pivot = character.find_child("CamPivot", false)
	_movement_manager = character.find_child("MovementStateManager", false)

# logic for if ActionContainer can play this action
func can_play() -> bool:
	if !super.can_play():
		return false
	return true

func play(_params: Dictionary = {}) -> void:
	var dir: Vector3 = -_cam_pivot.global_basis.z
	#_movement_manager.active_state.add_velocity(dir * power)
	character.velocity = dir * power
	super.play()
	super.stop()
