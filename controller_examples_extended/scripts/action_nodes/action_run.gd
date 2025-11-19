extends ActionNode


var _move_action: ActionNode


func _init() -> void:
	self.ACTION_ID = "RUN"
	self.IS_LAYERED = true


func refresh() -> void:
	_move_action = container.get_action("MOVE")

# logic for if ActionContainer can play this action
func can_play() -> bool:
	if !super.can_play() and !_move_action:
		return false
	return true

# actual logic for performing this action
func play(_params: Dictionary = {}) -> void:
	_move_action.set_speed(BaseActionMove.SPEED_SETTING.FAST)
	if _move_action.has_method("set_use_aim"):
		_move_action.set_use_aim(true)
	super.play()

# logic for stopping the action
func stop() -> void:
	_move_action.set_speed(BaseActionMove.SPEED_SETTING.NORMAL)
	if _move_action.has_method("set_use_aim"):
		_move_action.set_use_aim(false)
	super.stop()
