@tool
extends EditorPlugin

## This is the ScriptCreateDialog we want to add our functionality to.
## We create this variable so that we don't need to call it out over and
## over again.
var _dialog: ScriptCreateDialog

var config: ConfigFile

#region 1st new (spacer) row in the attach script dialog

# These two separators are necessary so that the separator line spans across
# the whole row. This is due to the configuration of the grid we add them to.
# The separators separate the plugin from the vanilla functionality.

## The left separator in the row
var ccn_hseparator1: HSeparator

## The right separator in the row
var ccn_hseparator2: HSeparator

#endregion

#region 2nd new row in the attach script dialog

## The Label next to the dropdown button.
var ccn_label: Label

## The HBoxContainer containing the dropdown button and the apply button.
var ccn_hbox: HBoxContainer

## The dropdown button that provides the selection of the naming conventions.
var ccn_option_button: OptionButton

## The apply button that applies the preview to the path.
var ccn_apply_button: Button

## The info button that explains about the conversion.
var ccn_info_button: Button

#endregion

#region 3rd new row in the attach script dialog

## The Label next to the preview field.
var ccn_preview_label: Label

## This LineEdit represents the preview field that shows script name using the
## selected naming conventions
var ccn_preview_line_edit: LineEdit

#endregion

func _enter_tree() -> void:

	config = ConfigFile.new()

	# Initialization of the ScriptCreateDialog
	_dialog = get_script_create_dialog()

	# Initialization of the new components.
	# The first child of the get_script_create_dialog is a VBoxContainer
	# containing the important GridContainer we want to add our controls to.

	## The GridContainer that we want to add our controls to.
	var grid: GridContainer = _dialog.get_child(0).get_child(0) as GridContainer

	#region Initialize the separator row

	ccn_hseparator1 = HSeparator.new()
	ccn_hseparator1.name = 'ccn_hseparator1'
	ccn_hseparator1.add_to_group('ccn')
	grid.add_child(ccn_hseparator1)

	ccn_hseparator2 = HSeparator.new()
	ccn_hseparator2.name = 'ccn_hseparator2'
	ccn_hseparator2.add_to_group('ccn')
	grid.add_child(ccn_hseparator2)

	#endregion

	#region Initialize the selection row
	ccn_label = Label.new()
	ccn_label.name = 'ccn_label'
	ccn_label.add_to_group('ccn')
	ccn_label.text = 'Choose naming convention:'
	grid.add_child(ccn_label)

	# The ccn_hbox contains the dropdown and the apply button next to each
	# other.
	ccn_hbox = HBoxContainer.new()
	ccn_hbox.name = 'ccn_hbox'
	ccn_hbox.add_to_group('ccn')
	grid.add_child(ccn_hbox)

	ccn_option_button = OptionButton.new()
	ccn_option_button.name = 'ccn_option_button'

	# Adding the dropdown items.
	ccn_option_button.add_item('Select...')  # The default item
	ccn_option_button.add_item('snake_case')
	ccn_option_button.add_item('PascalCase')

	# Connect the signal that is emitted when an item is selected to the
	# _on_option_selected function.
	ccn_option_button.item_selected.connect(_on_option_selected)
	ccn_hbox.add_child(ccn_option_button)

	ccn_apply_button = Button.new()
	ccn_apply_button.name = 'ccn_apply_button'
	ccn_apply_button.text = 'Apply'

	# Connect the signal that is emitted when the button is pressed to the
	# _apply_naming_convention function.
	ccn_apply_button.pressed.connect(_apply_naming_convention)

	# The apply button is disabled on the default OptionButton item.
	ccn_apply_button.disabled = true
	ccn_hbox.add_child(ccn_apply_button)

	ccn_info_button = Button.new()
	ccn_info_button.name = 'ccn_info_button'
	ccn_info_button.text = 'Info'

	# Connect the signal that is emitted when the button is pressed to the
	# _show_info_dialog function.
	ccn_info_button.pressed.connect(_show_info_dialog)

	# Add a spacer to the HBoxContainer
	ccn_hbox.add_spacer(false)
	ccn_hbox.add_child(ccn_info_button)



	#endregion

	#region Initialize the preview row

	ccn_preview_label = Label.new()
	ccn_preview_label.name = 'ccn_preview_label'
	ccn_preview_label.add_to_group('ccn')
	ccn_preview_label.text = 'File name preview:'
	grid.add_child(ccn_preview_label)

	ccn_preview_line_edit = LineEdit.new()
	ccn_preview_line_edit.name = 'ccn_preview_line_edit'
	ccn_preview_line_edit.add_to_group('ccn')
	# Make the ccn_preview_line_edit not editable
	ccn_preview_line_edit.editable = false
	grid.add_child(ccn_preview_line_edit)

	#endregion

	# If a script gets created reset the selection to the default item.
	_dialog.confirmed.connect(_reset_selection)

	# If the dialog is closed reset the selection to the default item.
	_dialog.canceled.connect(_reset_selection)


func _exit_tree() -> void:
	# Disconnect all the signals from their callbacks
	ccn_option_button.item_selected.disconnect(_on_option_selected)
	ccn_apply_button.pressed.disconnect(_apply_naming_convention)
	ccn_info_button.pressed.disconnect(_show_info_dialog)
	_dialog.confirmed.disconnect(_reset_selection)
	_dialog.canceled.disconnect(_reset_selection)

	for node in get_tree().get_nodes_in_group('ccn'):
		node.queue_free()


## This function acts as a callback for when the user makes a selection in
## the OptionButton.
func _on_option_selected(index: int):
	# Get the name of the selected item from the OptionButton for better
	# readability in code.
	var selected_item: String = ccn_option_button.get_item_text(index)

	# If the default item is selected the preview is cleared and the apply
	# button is disabled. Also we return early from the function.
	if selected_item == 'Select...':
		ccn_preview_line_edit.text = ''
		ccn_apply_button.disabled = true
		return

	# Here we are sure that the selected item is NOT the default item.

	# Here we get the name from the vanilla suggestion but we pass false as an
	# argument to get the name without the file type suffix.
	## The suggested file name without suffix.
	var name: String = get_name_from_line_edit(false)

	## This variable will hold the converted name.
	var new_name: String = ''

	# Enable the apply button.
	ccn_apply_button.disabled = false

	# Check for the selected naming convention
	if selected_item == 'snake_case':

		# This variable indicates whether we have to add an _ to split new
		# words in a PascalCase name.
		var previous_char_not_upper: bool = false

		# We go through the name char by char
		for i in name.length():

			## The character in the name at position i
			var char: String = name[i]
			if char == '_':
				new_name += char
				previous_char_not_upper = true
				continue

			# Check if char is upper or not. If not add it to the new_name
			# and mark previous_char_not_upper as true.
			if char.to_upper() != char:
				new_name += char
				previous_char_not_upper = true
			else:
				# If char was upper and the previous not, add an _.
				if previous_char_not_upper:
					new_name += '_'
					previous_char_not_upper = false
				new_name += char.to_lower()

		# The full snake_case name should be constructed.
		name = new_name

	elif selected_item == 'PascalCase':
		# This variable indicates whether we have to capitalize a char.
		# The _ will be discarded and only the char will be added to new_name.
		var previous_char_was_underscore: bool = true

		# This variable indicates whether the previous char was the beginning
		# of a new word in the name.
		var previous_char_was_start_of_word: bool = false

		# We go through the name char by char
		for i in name.length():

			## The character in the name at position i
			var char: String = name[i]

			# If the char is an _ we mark our helper variables respectively
			# and continue the loop.
			if char == '_':
				previous_char_was_underscore = true
				previous_char_was_start_of_word = false
				continue

			if previous_char_was_underscore:
				# Add the char as upper case to new_name
				new_name += char.to_upper()

				# Mark the helper variables accordingly and continue the loop.
				previous_char_was_start_of_word = true
				previous_char_was_underscore = false
				continue

			# If char is not a start of a new word make it lower case.
			if previous_char_was_start_of_word:
				new_name += char.to_lower()

		# The full snake_case name should be constructed.
		name = new_name

	# Show the new_name on the preview with the correct suffix attached
	# and trim spaces
	ccn_preview_line_edit.text = (new_name + get_suffix()).replace(' ', '')

## This function yields the LineEdit that contains the path the new script will
## be saved in, including the vanilla suggested name for the script.
func get_line_edit() -> LineEdit:
	return _dialog.get_child(0).get_child(0).get_child(9).get_child(0)


## This function yields only the vanilla suggested name for the script from the
## LineEdit. You can provide a bool value as a parameter to receive the name
## with its file type suffix. Provide true for the suffix and false for without.
func get_name_from_line_edit(with_suffix: bool = true) -> String:
	var line_edit: LineEdit = get_line_edit()

	# The last slash '/' marks the beginning of the name of the script.
	var last_slash: int = line_edit.text.rfind('/')

	# Substring magic
	var suffix: String = line_edit.text.substr(line_edit.text.rfind('.'))
	var name: String = line_edit.text.substr(last_slash + 1, line_edit.text.substr(last_slash + 1).length() - suffix.length())

	return name + (suffix if with_suffix else '')


## This function yields only the suffix of the script name.
func get_suffix() -> String:
	var line_edit: LineEdit = get_line_edit()
	return line_edit.text.substr(line_edit.text.rfind('.'))


## This function yields the path where the script should be saved without
## the script's name itself.
func get_path_from_line_edit() -> String:
	var line_edit: LineEdit = get_line_edit()
	var last_slash: int = line_edit.text.rfind('/')
	return line_edit.text.substr(0, last_slash + 1)


## This function connects the path with the new name for the script with the
## naming convention applied.
func _apply_naming_convention() -> void:
	get_line_edit().text = get_path_from_line_edit() + ccn_preview_line_edit.text
	get_line_edit().select(get_path_from_line_edit().length(), get_line_edit().text.length() - get_suffix().length())
	get_line_edit().text_changed.emit(get_line_edit().text)


## This function resets the selection from the OptionButton and therefore
## disables the apply Button.
func _reset_selection() -> void:
	ccn_option_button.select(0)
	ccn_preview_line_edit.text = ''
	ccn_apply_button.disabled = true


func _show_info_dialog() -> void:

	var addtional_message: String = ''
	if config.load('res://addons/correct_conventional_naming/plugin.cfg') != OK:
		addtional_message = '''Attention! The config file could not be loaded.
			Please consider re-installing the plugin from your source.\n\n'''
	else:
		var version: String = config.get_value('plugin', 'version')
		var author: String = config.get_value('plugin', 'author')
		var description: String = config.get_value('plugin', 'description')
		addtional_message = '''Correct Conventional Naming v%s
			created by %s
			Description:
			%s\n\n''' % [version, author, description]


	var info_dialog: AcceptDialog = AcceptDialog.new()
	info_dialog.title = 'Info'
	info_dialog.dialog_text = '''
		%sAdditional Tips:
		1.	The selection you make will help you to switch
		the naming scheme for your script name.\n
		2.	Please note that if your suggested name is already in PascalCase
		and you select PascalCase the result will not be correct anymore.
		The same goes for selecting snake_case if your the name already is in
		snake_case.''' % addtional_message
	_dialog.add_child(info_dialog)
	info_dialog.popup_centered()
