extends Node
class_name StateDataManager


enum DATA_TYPE {GROUNDED, FLYING}

@export var _grounded_data: CharacterStateData
@export var _flying_data: CharacterStateData

var _currnet_data: CharacterStateData


func _ready() -> void:
	if _grounded_data.state_id == _flying_data.state_id:
		push_error("IDs for CharacterStateData cannot be shared.")
	if !_grounded_data.state_id or !_flying_data.state_id:
		push_error("IDs for CharacterStateData must be set.")
	
	set_currnet_data(DATA_TYPE.GROUNDED)


func set_currnet_data(type: DATA_TYPE) -> void:
	match type:
		DATA_TYPE.GROUNDED:
			_currnet_data = _grounded_data
		DATA_TYPE.FLYING:
			_currnet_data = _flying_data

func get_currnet_data() -> CharacterStateData:
	return _currnet_data
