# CCN - Correct Conventional Naming Plugin for Godot

> [!NOTE]
> Documentation and code refactoring will be coming soon. Stay tuned!

## Overview
This Godot Engine plugin enhances the script creation process by allowing users to select a naming convention when attaching a script to a node. It specifically addresses the issue where the node's name is used by default when a script is attached to a node that is not saved as a standalone scene. The plugin provides options to quickly switch between `snake_case` and `PascalCase` naming conventions for script names.

## Features
- **Flexible Naming Conventions**: Choose between `snake_case` and `PascalCase` for your script filenames.
- **Automatic Conversion**: Automatically converts script names to the selected naming convention when creating new scripts.
- **Seamless Integration**: Provides a simple and seamless integration in the default "Attach Script to Node" dialog to switch naming conventions, preview the result and lastly apply the change.

## Installation
1. Clone or download this repository.
2. Copy the `addons/correct_conventional_naming` folder into the `addons` directory of your Godot project.
3. In Godot, go to `Project` -> `Project Settings` -> `Plugins`.
4. Find "Correct Conventional Naming" in the list and click "Activate".

## Usage
Once the plugin is activated, every time you attach a script to a node:
1. In the default dialog there will appear a new setting for you to choose the naming convention for the script.

![Alt Text](/screenshots/attach_node_script.png?raw=true "The new setting")

2. Select your preferred naming style.

![Alt Text](/screenshots/attach_node_script_select.png?raw=true "Select the naming convention")

3. The script name will be automatically adjusted in the preview field according to your selection. Just hit apply if you're happy with it and click create afterwards.

![Alt Text](/screenshots/attach_node_script_snake_case.png?raw=true "Preview and apply the new name")

## Compatibility
As of now, this plugin has been tested and confirmed to work on Godot 4.2.1, as this is the version I am currently using.

## Contributing
Contributions to the plugin are welcome! If you have suggestions for improvements or have found a bug, please open an issue or a pull request. Also testing on other versions has not yet been conducted. If you are using a different version of Godot and would like to contribute, please feel free to test the plugin and provide feedback on compatibility with other versions.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgements
- Thanks to the Godot community for their continuous support and feedback.
