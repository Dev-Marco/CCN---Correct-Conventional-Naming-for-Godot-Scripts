@tool
extends EditorPlugin


var ccn_label: Label
var ccn_hseparator1: HSeparator
var ccn_hseparator2: HSeparator
var ccn_option_button: OptionButton
var ccn_apply_button: Button
var ccn_hbox: HBoxContainer
var ccn_preview_label: Label
var ccn_preview_line_edit: LineEdit

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var grid: GridContainer = get_script_create_dialog().get_child(0).get_child(0) as GridContainer

	if not grid.get_child(-1).name == 'ccn_preview_line_edit':
		ccn_hseparator1 = HSeparator.new()
		grid.add_child(ccn_hseparator1)
		ccn_hseparator1.name = 'ccn_hseparator1'

		ccn_hseparator2 = HSeparator.new()
		grid.add_child(ccn_hseparator2)
		ccn_hseparator2.name = 'ccn_hseparator2'

		ccn_label = Label.new()
		grid.add_child(ccn_label)
		ccn_label.name = 'ccn_label'
		ccn_label.text = 'Choose naming convention:'

		ccn_hbox = HBoxContainer.new()
		grid.add_child(ccn_hbox)
		ccn_hbox.name = 'ccn_hbox'

		ccn_option_button = OptionButton.new()
		ccn_hbox.add_child(ccn_option_button)
		ccn_option_button.add_item('snake_case')
		ccn_option_button.add_item('PascalCase')
		ccn_option_button.item_selected.connect(_on_conventional_naming_option_selected)
		ccn_option_button.name = 'ccn_option_button'

		ccn_apply_button = Button.new()
		ccn_hbox.add_child(ccn_apply_button)
		ccn_apply_button.text = 'Apply'
		ccn_apply_button.pressed.connect(apply_naming_convention)
		ccn_apply_button.name = 'ccn_apply_button'

		ccn_preview_label = Label.new()
		ccn_preview_label.text = 'File name preview:'
		grid.add_child(ccn_preview_label)
		ccn_preview_label.name = 'ccn_preview_label'

		ccn_preview_line_edit = LineEdit.new()
		grid.add_child(ccn_preview_line_edit)
		ccn_preview_line_edit.editable = false
		ccn_preview_line_edit.text = get_name_from_line_edit()
		ccn_preview_line_edit.name = 'ccn_preview_line_edit'


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	ccn_option_button.item_selected.disconnect(_on_conventional_naming_option_selected)
	ccn_apply_button.pressed.disconnect(apply_naming_convention)


func _on_conventional_naming_option_selected(index: int):
	var selected_item: String = ccn_option_button.get_item_text(index)
	var name: String = get_name_from_line_edit(false)
	var new_name: String = ''
	if selected_item == 'snake_case':
		var previous_char_not_upper: bool = false
		for i in name.length():
			var char: String = name[i]
			if char == '_':
				new_name += char
				previous_char_not_upper = true
				continue
			if char.to_upper() != char:
				new_name += char
				previous_char_not_upper = true
			else:
				if previous_char_not_upper:
					new_name += '_'
					previous_char_not_upper = false
				new_name += char.to_lower()
		name = new_name
	elif selected_item == 'PascalCase':
		var previous_char_was_underscore: bool = true
		var previous_char_was_start_of_word: bool = false
		for i in name.length():
			var char: String = name[i]
			if char == '_':
				previous_char_was_underscore = true
				previous_char_was_start_of_word = false
				continue
			if previous_char_was_underscore:
				new_name += char.to_upper()
				previous_char_was_start_of_word = true
				previous_char_was_underscore = false
				continue
			if previous_char_was_start_of_word:
				new_name += char.to_lower()

		name = new_name
	ccn_preview_line_edit.text = new_name + get_suffix()

func get_line_edit() -> LineEdit:
	return get_script_create_dialog().get_child(0).get_child(0).get_child(9).get_child(0)


func get_name_from_line_edit(with_suffix: bool = true) -> String:
	var line_edit: LineEdit = get_line_edit()
	var last_slash: int = line_edit.text.rfind('/')
	var suffix: String = line_edit.text.substr(line_edit.text.rfind('.'))
	var name: String = line_edit.text.substr(last_slash + 1, line_edit.text.substr(last_slash + 1).length() - suffix.length())
	return name + (suffix if with_suffix else '')


func get_suffix() -> String:
	var line_edit: LineEdit = get_line_edit()
	return line_edit.text.substr(line_edit.text.rfind('.'))


func get_path_from_line_edit() -> String:
	var line_edit: LineEdit = get_line_edit()
	var last_slash: int = line_edit.text.rfind('/')
	return line_edit.text.substr(0, last_slash + 1)


func apply_naming_convention() -> void:
	get_line_edit().text = get_path_from_line_edit() + ccn_preview_line_edit.text
	get_line_edit().select(get_path_from_line_edit().length(), get_line_edit().text.length() - get_suffix().length())
