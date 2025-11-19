extends Node
class_name ActionNode

## this is an abstract class not meant to be used directly. Inherit to implement.
## 
## Defines an action that the object can perform during gameplay
## EX: jump, run, attack, activate ability, swap weapon

signal action_enter(action_id: StringName)
signal action_play(action_id: StringName)
signal action_exit(action_id: StringName)

# ACTION_ID and IS_LAYERED are ment to act as const but must be var so that they can be set by children
var ACTION_ID: StringName = "" # does not need to match ActionNode name
# non-layered actions can only have one active at a time
# set to true if action can be played at any time
var IS_LAYERED: bool = false

# allows other actions to stop this one while it is active
@export var interrupt_whitelist: Array[StringName]

## container is set in the ActionContainer _ready method. Avoid using this var in ActionNode _ready or _init.
var container: ActionContainer
var is_playing: bool = false
var is_enabled: bool = false


## Called by ActionContainer when action is added to active actions.
## Use to set variables that may depend on container var being set.
func refresh() -> void:
	pass

func can_play() -> bool:
	# layered actions can play if enabled
	# non-layered actions can play if enabled and not currently playing
	if is_enabled:
		return true if IS_LAYERED else !is_playing
	return false

func enter() -> void:
	action_enter.emit(ACTION_ID)

# _params are arbitrary data passed from the controller to the action
func play(_params: Dictionary = {}) -> void:
	is_playing = true
	action_play.emit(ACTION_ID)

func stop() -> void:
	_exit()


func _exit() -> void:
	is_playing = false
	action_exit.emit(ACTION_ID)


# Action
# - Refresh - set refrence variables 
# - CanPlay
#
# - Enter - prepare variables
# - Play  - perform logic
# - Stop  - intterupt logic (public way to stop action)
# - _Exit - clean up variables (internally used when action naturally ends)
