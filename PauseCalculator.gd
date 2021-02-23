class_name PauseCalculator
extends Node

# Regular expression to find {p=%d} tags
const PAUSE_PATTERN := "({p=\\d([.]\\d+)?[}])"

# Additional cleanup patterns
const FLOAT_PATTERN := "\\d+\\.\\d+"
const BBCODE_I_PATTERN := "\\[(?!\\/)(.*?)\\]"
const BBCODE_E_PATTERN := "\\[\\/(.*?)\\]"

# Not that we are defining here that all of our custom tags will be defined as {%s}, so
# we use this global pattern to match all of them.
const CUSTOM_TAG_PATTERN := "({(.*?)})"

var _pauses := []

# Pause Regex
var _pause_regex := RegEx.new()

# Auxiliary Regexes
var _float_regex := RegEx.new()
var _bbcode_i_regex := RegEx.new()
var _bbcode_e_regex := RegEx.new()
var _custom_tag_regex := RegEx.new()

signal pause_requested(duration)

# ================================ Lifecycle ================================ #

func _ready() -> void:

	# Tags
	_pause_regex.compile(PAUSE_PATTERN)

	# Auxiliary
	_float_regex.compile(FLOAT_PATTERN)
	_bbcode_i_regex.compile(BBCODE_I_PATTERN)
	_bbcode_e_regex.compile(BBCODE_E_PATTERN)
	_custom_tag_regex.compile(CUSTOM_TAG_PATTERN)

# ================================= Public ================================== #

# Will attempt to extract all tags that follow the {p=%d} pattern, and will return a
# version of the provided string without them. This basically resets the _pauses array
# and performs the first call to _extract_next_pause
func extract_pauses_from_string(source_string: String) -> String:
	_pauses = []
	_find_pauses(source_string)
	return _extract_tags(source_string)

# Checks if a pause must be executed for the current offset
func check_at_position(pos: int) -> void:
	for _pause in _pauses:
		if _pause.pause_pos == pos:
			emit_signal("pause_requested", _pause.duration)
	
# ================================ Private ================================== #

# Detects all pauses currently present on the string, and registers them to the _pauses array
func _find_pauses(from_string: String) -> void:

	var _found_pauses := _pause_regex.search_all(from_string)

	for _pause_regex_result in _found_pauses:
		var _tag_string := _pause_regex_result.get_string() as String
		var _tag_position := _adjust_position(
			_pause_regex_result.get_start(),
			from_string
		)

		var _pause_duration := float(_float_regex.search(_tag_string).get_string())

		var _pause = Pause.new(_tag_position, _pause_duration)
		_pauses.append(_pause)

# Adjusts the provided position based on the bbcodes and custom tags that are found to the left of
# the provided string.
func _adjust_position(pos: int, source_string: String) -> int:

	var _new_pos := pos
	var _left_of_pos := source_string.left(pos)

	var _all_prev_tags := _custom_tag_regex.search_all(_left_of_pos)
	for _tag_result in _all_prev_tags:
		_new_pos -= _tag_result.get_string().length()

	var _all_prev_start_bbcodes := _bbcode_i_regex.search_all(_left_of_pos)
	for _tag_result in _all_prev_start_bbcodes:
		_new_pos -= _tag_result.get_string().length()

	var _all_prev_end_bbcodes := _bbcode_e_regex.search_all(_left_of_pos)
	for _tag_result in _all_prev_end_bbcodes:
		_new_pos -= _tag_result.get_string().length()

	return _new_pos

# Removes all custom tags from the string
func _extract_tags(from_string: String) -> String:
	return _custom_tag_regex.sub(from_string, "", true)
