extends Resource
class_name ActionContainerConfig

## used by ActionContainer to configure actions that can be called
## holds a "profile" of ActionNodes that can be performed when the profile is active
##
## actions must be nodes that are on the character
## actions in a profile must use the node name (this is to allow ACTION_IDs being shared across different configurations)

@export var active_profile: StringName = &""

# key: profile name (EX: "Grounded")
# data: names of action Nodes to enable (EX: ["jump", "move", "run"]) # use node name, not ACTION_ID
@export var profiles: Dictionary[StringName, Array] = {&"global":[]}


# profile: string name
# valid action nodes: node name
# {
#  "global"   : []
#  "grounded" : ["Move","Jump","ChangeState"],
#  "flying"   : ["Move","Ascend","Descend","ChangeState"]
# }

# action nodes cannot share names, even if nested under other nodes
# using node names allows for action nodes to be in the config even when they are not on the character yet
#  this then allows for dynamic addition of actions without the need to update the config profile

# global allows for actions to be valid across all states

func is_profile_valid(profile_name: StringName) -> bool:
	return profile_name != &"" and profiles.has(profile_name)

func is_action_valid(action_node_name: StringName) -> bool:
	if is_profile_valid(active_profile):
		if profiles[active_profile].has(action_node_name):
			return true
	
	if profiles.has(&"global"):
		if profiles[&"global"].has(action_node_name):
			return true
	
	return false

func get_valid_acitons() -> Array:
	var result: Array = get_global_actions()
	if is_profile_valid(active_profile):
		result.append_array(profiles[active_profile])
	return result

func get_global_actions() -> Array:
	return profiles[&"global"].duplicate() if profiles.has(&"global") else []

## Pushes warnings if Action Container Config holds unused names.
## Useful for catching spelling errors.
func debug_validate_names(caller: Node, names: Array[StringName]) -> void:
	if active_profile and !profiles.has(active_profile):
		push_warning("Action Container Config on ", caller.owner.name, " does not have Config name \'", active_profile, "\'")
	
	for profile_name in profiles.keys():
		for profile_action in profiles[profile_name]:
			if !names.has(profile_action):
				push_warning("Action Container Config on ", caller.owner.name, " holds nonexistant action node name \'", profile_action, "\' in profile \'", profile_name, "\'")
