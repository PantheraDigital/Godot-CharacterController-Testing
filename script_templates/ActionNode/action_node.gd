# meta-name: Action Node
# meta-description: Defines actions characters can perform durring gameplay
# meta-default: true
extends ActionNode


func _init() -> void:
	self.ACTION_ID = ""

## Called by ActionContainer when action is added to active actions.
## Use to set variables that may depend on container var being set.
func refresh() -> void:
	pass

# logic for if ActionContainer can play this action
func can_play() -> bool:
	if !super.can_play():
		return false
	# keep the above code
	# place custom logic here
	return true

# actual logic for performing this action
# called once till is_playing == false (set in super.stop())
func play(_params: Dictionary = {}) -> void:
	# keep super.play() at end
	super.play()

# logic for stopping the action
func stop() -> void:
	# keep super.stop() at end
	super.stop()
