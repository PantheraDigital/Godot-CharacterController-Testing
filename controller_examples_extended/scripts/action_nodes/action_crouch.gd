extends ActionNode

var _animation_player: AnimationPlayer
var _move_action: ActionNode


func _init() -> void:
	self.ACTION_ID = "CROUCH"
	self.interrupt_whitelist = ["MOVE", "JUMP"]


func refresh() -> void:
	var character = container.get_parent()
	_animation_player = character.find_child("AnimationPlayer", false)
	_move_action = container.get_action("MOVE")

# logic for if ActionContainer can play this action
func can_play() -> bool:
	if !super.can_play():
		return false
	return true


func play(_params: Dictionary = {}) -> void:
	_animation_player.play("crouch")
	_move_action.set_speed(BaseActionMove.SPEED_SETTING.SLOW)
	super.play()

# logic for stopping the action
func stop() -> void:
	_animation_player.play_backwards("crouch")
	_move_action.set_speed(BaseActionMove.SPEED_SETTING.NORMAL)
	super.stop()
