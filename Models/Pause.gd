class_name Pause
extends Reference

var pause_pos : int
var duration : float

func _init(_position: int, _duration: float) -> void:
	pause_pos = int(clamp(_position - 1, 0, abs(_position)))
	duration = _duration
