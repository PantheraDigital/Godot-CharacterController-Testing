extends Node
class_name ActionContainer

## acts as the API for controlling a character 
##
## contains the ActionNode of a character and manages the use of them by outside classes
# manages actions by their ACTION_ID
# can utilize an ActionContainerConfig to allow swapping actions at runtime

signal action_enter(action_id: StringName)
signal action_exit(action_id: StringName)

## Holds "profiles" of different configurations that can be swapped between at runtime.
## "Profiles" are the dictionary key while the array holds actions available when the profile is active.
## Only needed if different actions should be available at different times
@export var _config_container: ActionContainerConfig

## Config warnings will be pushed when there are actions added that do not currently exist as a child to ActionContainer.
## Disable if config will be holding actions that are expected to be added at runtime.
@export var _disable_config_warnings: bool = false

## stores actions by ACTION_ID
var _active_action_dict: Dictionary[StringName, ActionNode]
var _active_action: StringName = ""


func _ready() -> void:
	if _config_container:
		if !_disable_config_warnings:
			var as_names: Array[StringName]
			for action in get_all_actions():
				as_names.push_back(action.name)
			_config_container.debug_validate_names(self, as_names)
		
		var active_profile: StringName = _config_container.active_profile
		if active_profile and _config_container.is_profile_valid(active_profile):
			reconfigure(active_profile)
		else:
			reconfigure(_config_container.profiles.keys()[0])
	else:
		# add actions to dict, then refresh them 
		# this prevents problems within action nodes when refresh() is called but a node is not yet added
		for action in get_all_actions():
			add_action(action, false)
		for action: ActionNode in _active_action_dict.values():
			action.refresh()
	
	child_entered_tree.connect(_on_child_enter)


func add_action(action: ActionNode, allow_node_refresh: bool = true) -> void:
	if !_config_container.is_action_valid(action.name):
		return
	
	if _active_action_dict.has(action.ACTION_ID):
		if _active_action_dict[action.ACTION_ID].name == action.name:
			# duplicate action
			# trigger refresh so node can reset local variables
			# this covers the case of a node existing in multiple configs and thus not being added but needs a refresh
			if allow_node_refresh: 
				action.refresh()
			return
		else:
			# override action with shared ID
			remove_action(_active_action_dict[action.ACTION_ID])
	
	_active_action_dict[action.ACTION_ID] = action
	action.is_enabled = true
	action.container = self
	action.action_exit.connect(_on_action_exit)
	action.action_enter.connect(_on_action_enter)
	if allow_node_refresh:
		action.refresh()

func remove_action(action: ActionNode) -> void:
	if !has_action(action):
		return
	
	_active_action_dict.erase(action.ACTION_ID)
	if action.action_exit.is_connected(_on_action_exit):
		action.action_exit.disconnect(_on_action_exit)
	if action.action_enter.is_connected(_on_action_enter):
		action.action_enter.disconnect(_on_action_enter)
	
	if _active_action == action.ACTION_ID or action.IS_LAYERED:
		stop_action(_active_action)
		_active_action = ""
	
	action.container = null
	action.is_enabled = false

func has_action(action: ActionNode) -> bool:
	# action IDs may overlap but node names will not
	return _active_action_dict.has(action.ACTION_ID) and _active_action_dict[action.ACTION_ID].name == action.name

func clear_actions() -> void:
	for key in _active_action_dict.keys():
		remove_action(_active_action_dict[key])

func get_action(action_id: StringName) -> ActionNode:
	if !_active_action_dict.has(action_id):
		return
	return _active_action_dict[action_id]

func get_active_action() -> ActionNode:
	if !_active_action:
		return
	return _active_action_dict[_active_action]


func reconfigure(profile_name: StringName, config: Array = []) -> void:
	if !profile_name:
		return
	
	if _config_container:
		if _config_container.is_profile_valid(profile_name):
			_config_container.active_profile = profile_name
			config = _config_container.get_valid_acitons()
		elif config:
			# order is important here as active_profile can only be set to valid profiles
			_config_container.profiles[profile_name] = config.duplicate()
			_config_container.active_profile = profile_name
			config.append_array(_config_container.get_global_actions())
	
	if !config:
		return
	
	for child in get_all_actions():
		if !config.has(child.name) and has_action(child):
			remove_action(child)
		elif config.has(child.name) and !has_action(child):
			add_action(child, false)
	
	for action: ActionNode in _active_action_dict.values():
		action.refresh()
	
	# debug
	#print("_______________________________________________________________________")
	#var cur = ""
	#var keys = _active_action_dict.keys()
	#for key in keys:
		#cur += _active_action_dict[key].name + " | "
	#print("cur:  ", cur)


func play_action(action_id: StringName, params: Dictionary = {}) -> bool:
	if action_id not in _active_action_dict:
		return false
	
	var action = _active_action_dict[action_id]
	
	if !action.is_enabled or !action.can_play() or \
		( !_active_action.is_empty() and !_active_action_dict[_active_action].interrupt_whitelist.has(action_id) ):
		return false
	
	if !action.is_playing:
		action.enter()
	
	if action.IS_LAYERED:
		action.play(params)
		return true
	
	if _active_action:
		_active_action_dict[_active_action].stop()
	
	_active_action = action_id
	action.play(params)
	return true

func stop_action(action_id: StringName) -> void:
	if action_id not in _active_action_dict:
		return
	if _active_action_dict[action_id].is_playing:
		_active_action_dict[action_id].stop()


func get_all_actions(node: Node = self) -> Array[ActionNode]:
	var result: Array[ActionNode]
	for child: Node in node.get_children():
		if child is ActionNode:
			result.append(child)
		if child.get_child_count() > 0:
			result.append_array(get_all_actions(child))
	
	return result


func _on_child_enter(node: Node) -> void:
	if node is not ActionNode:
		return
	add_action(node)

func _on_action_exit(action_id: StringName) -> void:
	if action_id == _active_action:
		_active_action = ""
	action_exit.emit(action_id)

func _on_action_enter(action_id: StringName) -> void:
	action_enter.emit(action_id)
