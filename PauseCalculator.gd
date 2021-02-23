class_name PauseCalculator
extends Node

# Regular expression to find {p=%d} tags
const PAUSE_PATTERN := "({p=\\d([.]\\d+)?[}])"

# Regular expression to find float inside strings
const FLOAT_PATTERN := "\\d+\\.\\d+"

# Additional cleanup patterns
const BBCODE_I_PATTERN := "\\[(?!\\/)(.*?)\\]"
const BBCODE_E_PATTERN := "\\[\\/(.*?)\\]"


var _float_regex := RegEx.new()
var _pauses := []

signal pause_requested(duration)

func _ready() -> void:
	_float_regex.compile(FLOAT_PATTERN)

# Will attempt to extract all tags that follow the {p=%d} pattern, and will return a
# version of the provided string without them. This basically resets the _pauses array
# and performs the first call to _extract_next_pause
func extract_pauses_from_string(source_string: String) -> String:
	_pauses = []
	return _extract_next_pause(source_string)

# Checks if a pause must be executed for the current offset
func check_at_position(pos: int) -> void:
	for _pause in _pauses:
		if _pause.pause_pos == pos:
			emit_signal("pause_requested", _pause.duration)

# Finds the first occurrence of the tag identified by the provided expression, and
# returns an object that encapsulates the result. Note that if nothing is found for
# the pattern, it will return null
func _find_next_tag(expression: String, source: String) -> RegExMatch:
	var regex := RegEx.new()
	regex.compile(expression)
	return regex.search(source)

# Will remove the tag identified by the provided match result from the string, and
# return it.
func _remove_found_regex_match(source: String, match_result: RegExMatch) -> String:
	var _left_of_match := source.left(match_result.get_start())
	var _right_of_match := source.right(match_result.get_end())
	return _left_of_match + _right_of_match

# Finds and removesthe next occurrence of a pause in the provided string. This method 
# will be called recursively until no more pause tags are found on the string.
# 
# Found pause tags will be used to create instances of the Pause class, which will be
# stored on the _pauses array for future references
func _extract_next_pause(from_string: String) -> String:
	
	var _first_found_pause := _find_next_tag(PAUSE_PATTERN, from_string)
	if _first_found_pause == null:
		return from_string
	
	var _tag_string := _first_found_pause.get_string()
	var _pause_duration := float(_float_regex.search(_tag_string).get_string())
	
	var _pause := Pause.new(
		_first_found_pause.get_start(),
		_pause_duration
	)
	_pauses.append(_pause)
	
	return _extract_next_pause(
		_remove_found_regex_match(from_string, _first_found_pause)
	)

