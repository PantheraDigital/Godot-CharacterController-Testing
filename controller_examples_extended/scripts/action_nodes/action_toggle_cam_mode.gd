extends ActionNode


var cam_control: CamControl


func _init() -> void:
	self.ACTION_ID = "TOGGLE_CAM_MODE"
	self.IS_LAYERED = true

func refresh() -> void:
	cam_control = container.get_parent().find_child("CamPivot", false)

func can_play() -> bool:
	return true

func play(_params: Dictionary = {}) -> void:
	if cam_control.is_first_person():
		cam_control.to_third_person()
	else:
		cam_control.to_first_person()
	super.play()
