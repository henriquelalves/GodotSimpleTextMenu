# MADE BY HENRIQUE ALVES
# (MIT) LICENSE STUFF BLABLABLA

tool
extends Control

# ========= Variables ==========
export(String, MULTILINE) var options = "" setget set_options # The options on the menu, separated by line
export(int, "Horizontal", "Vertical") var orientation = 0 setget set_orientation # Horizontal or Vertical menu
export(int) var offset = 0 setget set_offset # Offset between options
export(Font) var options_font = null setget set_font # Menu font
export(int, "Number", "String") var signal_argument = 0 # Whether you receive the number of the option choosen or the string
export(int) var initial_option = 0 setget set_cursor_option # Cursor starting position
export(int, "Left", "Top", "Right", "Bottom") var cursor_side = 0 setget set_cursor_side # Which side the cursor will appear on the options
export(int) var cursor_offset = 0 setget set_cursor_offset

export(float) var blinking_cursor_rate = 0.0 setget set_blinking_cursor_rate# How many seconds for the cursor to blink (0 means he doesn't blink)
export(Color) var options_color = Color(1.0,1.0,1.0,1.0) setget set_options_color
export(Color) var cursor_color = Color(1.0,1.0,1.0,1.0) setget set_cursor_color
export(bool) var menu_enabled = true setget set_enabled_menu

var _current_option = 0
var _cursor_timer = 0.0

var __cursor = add_child(Label.new())
var _cursor = get_child(0)
var __options = add_child(Label.new())
var _options = get_child(1)

var ronaldo = 0

# ========= 'Public' methods ==========
func set_options(new_options):
	options = new_options
	
	_create_options()
	_update_style()
	_reposition_options()

func set_orientation(new_orientation):
	orientation = new_orientation
	
	_reposition_options()
	_reposition_cursor()

func set_offset(new_offset):
	offset = new_offset
	
	_reposition_options()
	_reposition_cursor()

func set_font(new_font):
	options_font = new_font
	
	_update_font()
	_reposition_options()
	_reposition_cursor()

func set_cursor_option(new_initial_option):
	_current_option = (abs(new_initial_option) % _options.get_child_count())
	initial_option = _current_option
	_reposition_cursor()

func set_blinking_cursor_rate(n):
	blinking_cursor_rate = n

func set_cursor_offset(n):
	cursor_offset = n
	_reposition_cursor()

func set_options_color(new_options_color):
	options_color = new_options_color
	_update_color()

func set_cursor_color(new_cursor_color):
	cursor_color = new_cursor_color
	_update_color()

func set_cursor_side(s):
	cursor_side = s
	_reposition_cursor()

func set_enabled_menu(b):
	menu_enabled = b
	if (!menu_enabled):
		_cursor.set_lines_skipped(1)
		_cursor_timer = 0.0
	else:
		_cursor.set_lines_skipped(0)
		_cursor_timer = 0.0

# ========= Internal functions ==========

func _clear_options():
	for i in _options.get_children():
		i.free()

func _create_options():
	_clear_options()
	for s in options.split("\n"):
		var label = Label.new()
		label.set_text(s)
		_options.add_child(label)

func _update_style():
	_update_font()
	_update_color()
	pass

func _update_color():
	for i in _options.get_children():
		i.add_color_override("font_color", options_color)
	_cursor.add_color_override("font_color", cursor_color)

func _update_font():
	if (options_font == null):
		return
	for i in _options.get_children():
		i.add_font_override("font", options_font)
	_cursor.add_font_override("font", options_font)

func _reposition_options():
	var count = 0
	var width = 0.0
	var height = 0.0
	for i in _options.get_children():
		if orientation == 0:
			i.set_pos(Vector2(width, 0))
			width += offset + i.get_size().x
			height = max(height, i.get_size().y)
		elif orientation == 1:
			i.set_pos(Vector2(0, height))
			height += offset + i.get_size().y
			width = max(width, i.get_size().x)
		count += 1
	set_size(Vector2(width, height))

func _reposition_cursor():
	var option_pos = _options.get_child(_current_option).get_pos()
	var option_size = _options.get_child(_current_option).get_size()
	if (cursor_side == 0):
		_cursor.set_text(">")
		_cursor.set_pos(Vector2(option_pos.x - (cursor_offset + _cursor.get_size().x), option_pos.y))
	elif (cursor_side == 1):
		_cursor.set_text("v")
		_cursor.set_pos(Vector2(option_pos.x + (option_size.x/2.0) - (_cursor.get_size().x/2.0), option_pos.y - (_cursor.get_size().y + cursor_offset)))
	elif (cursor_side == 2):
		_cursor.set_text("<")
		_cursor.set_pos(Vector2(option_pos.x + option_size.x + cursor_offset, option_pos.y))
	elif (cursor_side == 3):
		_cursor.set_text("^")
		_cursor.set_pos(Vector2(option_pos.x + (option_size.x/2.0) - (_cursor.get_size().x/2.0), option_pos.y + _cursor.get_size().y + cursor_offset))
	
	pass

func _ready():
	_reposition_options()
	_reposition_cursor()
	if !(get_tree().is_editor_hint()):
		set_fixed_process(true)
		set_process_input(true)
		# Option and cursor
		add_user_signal("option_selected")
		add_user_signal("option_changed")

func _fixed_process(delta):
	# Blinking
	if(menu_enabled):
		if(blinking_cursor_rate > 0):
			_cursor_timer += delta
			if _cursor_timer > blinking_cursor_rate:
				_cursor_timer = 0.0
				_cursor.set_lines_skipped((_cursor.get_lines_skipped()+1)%2)
	pass

func _input(event):
	if(menu_enabled):
		if (event.type == InputEvent.KEY and event.pressed):
			if event.scancode == KEY_UP:
				if(orientation == 1):
					set_cursor_option(_current_option + get_child_count() - 1)
					emit_signal("option_changed")
			if event.scancode == KEY_DOWN:
				if(orientation == 1):
					set_cursor_option(_current_option + 1)
					emit_signal("option_changed")
			if event.scancode == KEY_RIGHT:
				if(orientation == 0):
					set_cursor_option(_current_option + 1)
					emit_signal("option_changed")
			if event.scancode == KEY_LEFT:
				if(orientation == 0):
					set_cursor_option(_current_option + get_child_count() - 1)
					emit_signal("option_changed")
			if event.scancode == KEY_RETURN:
				if(signal_argument == 0):
					emit_signal("option_selected", _current_option)
				elif(signal_argument == 1):
					emit_signal("option_selected", get_child(_current_option).get_text())
			_cursor_timer = 0.0
			_cursor.set_lines_skipped(0)
