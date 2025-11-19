extends Controller

## provides input to ActionContainer
## example of player controller

const DOUBLE_TAP_DELAY: float = 0.25

var _cam_control: CamControl
var _action_container: ActionContainer

var _last_input_window: float = 0.0
var _last_input: StringName

var _double_tap_running: bool


func _on_controlled_obj_change():
	_action_container = controlled_obj.get_node("ActionContainer")
	_cam_control = controlled_obj.get_node("CamPivot")
	if _cam_control.camera:
		_cam_control.camera.make_current()


func _process(delta: float) -> void:
	if _last_input_window > 0.0:
		_last_input_window -= delta
		if _last_input_window <= 0.0:
			_last_input = ""
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_forwards") \
	or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards").rotated(-_cam_control.rotation.y)
		_action_container.play_action("MOVE", {"input_direction":Vector3(input.x, 0.0, input.y), "aim_direction":-_cam_control.camera.global_basis.z})
	
	if Input.is_action_just_pressed("move_forwards") and double_tap_check("move_forwards"):
		_action_container.play_action("RUN")
		_double_tap_running = true
	if _double_tap_running and Input.is_action_just_released("move_forwards"):
		_action_container.stop_action("RUN")
		_double_tap_running = false
	
	if Input.is_action_pressed("fly_up"):
		_action_container.play_action("MOVE", {"input_direction":Vector3.UP})
	
	if Input.is_action_pressed("fly_down"):
		_action_container.play_action("MOVE", {"input_direction":Vector3.DOWN})
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		_action_container.play_action("LOOK", {"aim_direction":event.relative})
		return
	
	if event.is_action_pressed("cam_mode_change"):
		_action_container.play_action("TOGGLE_CAM_MODE")
		return
	
	# check input action names of actions that are expected to be event based
	for check in ["run", "jump", "dash", "crouch"]:
		if event.is_action(check):
			var is_double: bool = false
			if event.is_action_pressed(check):
				is_double = double_tap_check(check)
			evaluate_event_based_input(check, event, is_double)


func evaluate_event_based_input(key: String, event: InputEvent = null, double_tap: bool = false, _input_params: Dictionary[StringName, Variant] = {}) -> void:
	match key:
		"run":
			if event.is_action_pressed("run"):
				_action_container.play_action("RUN")
			else:
				_action_container.stop_action("RUN")
		"jump":
			if event.is_action_pressed("jump"):
				var should_jump: bool = true
				if double_tap:
					should_jump = not _action_container.play_action("TO_GLIDE")
				if should_jump:
					_action_container.play_action("JUMP")
		"dash":
			if event.is_action_pressed("dash"):
				_action_container.play_action("DASH")
		"crouch":
			if event.is_action_pressed("crouch"):
				_action_container.play_action("CROUCH")
			else:
				_action_container.stop_action("CROUCH")


func double_tap_check(input: StringName) -> bool:
	var result := false
	if _last_input == "":
		_last_input = input
		_last_input_window = DOUBLE_TAP_DELAY
	elif _last_input == input:
		result = true
		_last_input = ""
		_last_input_window = 0.0
	return result
