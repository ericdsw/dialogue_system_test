class_name Pause
extends Reference

const FLOAT_PATTERN := "\\d+\\.\\d+"

var pause_pos : int
var duration : float

func _init(_position: int, _tag_string: String) -> void:
	
	var _duration_regex := RegEx.new()
	_duration_regex.compile(FLOAT_PATTERN)
	
	duration = float(_duration_regex.search(_tag_string).get_string())
	pause_pos = int(clamp(_position - 1, 0, abs(_position)))
