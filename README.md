<h1 align="center">
	GDScript Utilities for Classes and Scenes
</h1>

<p align="center">
  <a href="https://godotengine.org/download/" target="_blank" style="text-decoration:none"><img alt="Godot v4.2 +" src="https://img.shields.io/badge/Godot-v4.2+-%23478cbf?logo=godot-engine&logoColor=cyian&labelColor=CFC9C8" /></a>
  <a href="https://github.com/WagnerGFX/gdscript_utilities/blob/main/LICENSE" target="_blank" style="text-decoration:none"><img alt="MIT License" src="https://img.shields.io/badge/License-MIT-brightgreen.svg"></a>
</p>

<p align="center">
  Easily compare class types directly, convert them to string names and vice-versa.  
</p>

<p align="center">
  Get more readable data from `PackedScene` and validate them.
</p>

<h2 align="center">
	Table of Contents
</h1>

<h3 align="center"><a href="#description">Description</a></h3>
<h3 align="center"><a href="#features-overview">Features Overview</a></h3>
<h3 align="center"><a href="#installation">Installation</a></h3>
<h3 align="center"><a href="#configuration">Configuration</a></h3>
<h3 align="center"><a href="#limitations-and-known-issues">Limitations and Known Issues</a></h3>
<h3 align="center"><a href="#user-contributions">User Contributions</a></h3>

## Description
This plugin creates workarounds for two limitations of the Godot Engine related to for the following proposals:
- [Expose class name in GDScriptNativeClass](https://github.com/godotengine/godot-proposals/issues/9160)
- [Add a way to get GDScriptNativeClass by name](https://github.com/godotengine/godot-proposals/issues/7281)
- [Expose ClassDB::is_class_exposed](https://github.com/godotengine/godot-proposals/issues/10216)
- [Allow type specification of root node for exported PackedScenes](https://github.com/godotengine/godot-proposals/issues/5255)

### Conversion between class type and string name
There is no easy conversion between a class type, and it's string name or get the type reference by using its name.
</br>Getting Script names, Node script names, Node class names all require different functions in different areas of the engine codebase.
</br>Native classes don't have a function or property to get their names.

This plugin contains simple functions to find the class name using a class reference or object instance and getting the class reference from its string name.

It also has easy ways to compare classes, compare inheritance and differentiate between native classes and user created scripts.

But why this is useful, you ask? With these functions it's easier to create:
- More descriptive debug functions.
- Plugins that can dynamically instantiate and validate nodes.
- Games with procedural features.

### PackedScene data readability and validation
PackedScene files represent one of the most flexible points of Godot, but when adding a scene reference to a node property in the inspector there is no way to pre-validate their data and post-validating requires a good amount of code.
</br>With no validation, designers can easily put a UI scene to spawn on the place of an expected 3D enemy, resulting in a nightmare for everyone, specially as the project gets bigger.

Although it's not too hard to get data from simple scene files, that data is not as easy to read and inherited scenes makes the process much more complicated.

This plugin makes PackedScene data simpler to read and ease post-validation of scene fields with specialized functions for types, properties, methods, signals, etc.

## Features Overview
For more details, check the internal documentation of each class.

### GDScriptUtilities
Plugin Autoload. Contains internal plugin functions and properties.

### ClassUtils
Provides utility functions to handle types directly, instead of instances or variables.
- Can convert a class type to string name and vice versa.
- Can get the full inheritance list of a class.
- Can identify if an object is a class type and if it's a native class or user script.

### VariantUtils
This class provides utility functions for types of variables.
- Can validate if the variable is any type of array, considering the 10+ native array types.
- Can detect if the variable is a collection, be it array or dictionary.

### PackedSceneUtils
This class provides utility functions to simplify the process of reading information from nodes inside a PackedScene file without the need to instantiate it.
- Can get node type, name, script, sub-scene, groups, signals, methods, properties.
- Can validate the items above.
- Can also get and validate property values, with some limitations.

### DefaultValue
Represents unmodified default values from scene properties. It's used internally to differentiate between PackedScene properties with explicit null values and default values that are not identifiable.

If you need it, use the value provided by GDScriptUtilities, to prevent any reference comparison errors.

### plugin_cache.tres
A resource that will automatically be created on startup to hold a cache of native classes that are inaccessible to GDScript, avoiding errors being spammed on the editor or during runtime.

It does not need to be saved, but it should be included in your project build.

## Installation
The plugin can be downloaded from:
- The Godot Asset Library. It can be installed directly from inside the engine using the AssetLib tab.
- The Releases section of this repository.
- The source code directly. Just import it into your project.

## Configuration
The plugin should run automatically as soon as you enable it in `Project > Project Setting > Plugins`

### `Project > Tools > Reload GDScript Utilities cache`
Use this menu option if `ClassUtils` is not behaving correctly or, optionally, before building your project.

### `Project > Project Settings > General > Plugins > GDScript Utilities > Print Internal Messages`
Toggle this option to allow/block internal plugin messages being printed to the output console.

## Limitations and Known Issues
Please be aware that this plugin is trying to work around some limitations of the Godot Engine and GDScript.
</br>Stuff could break. Test rigorously before using in production or updating the engine.

### Parse errors spamming in the console
The plugin will spam parse errors:
- On the first run
- Anytime a different engine version is detected
- When the cache file is not found
- When reloading the cache manually

This is expected as many classes in `ClassDB` are not accessible to GDScript. The plugin tests every class on startup and caches the name of those that can't be accessed, preventing those errors during runtime.

I have not found any way to suppress those errors.

### Unexpected parse errors in Godot v4.2
***Reason:*** [Plugin: script parse errors after removing folder .godot](https://github.com/godotengine/godot/issues/83457) fixed in v4.3+

***Solution:*** Restart the project and reload the plugin cache.

### User Scripts
To handle types, all user-created scripts need to correctly exist in `ProjectSetting.get_global_class_list()`. For that, they must:
- Have a class_name.
- Be extended only by using a native type or a script with class_name.
- NOT be an inner class.
- NOT be created during runtime.
- NOT be extended using a path string.
- NOT be extended by any inner class.
- NOT be extended by any script created during runtime.

### `GDScriptNativeClass`
Native classes like Object, Node and Resources are represented by the type `GDScriptNativeClass`, but that class is not officially expected to be used inside GDScript.

Although I have not found any issues using them until now, any engine update may break this plugin without prior notice.

### Packed Scene property values
Default property values of scripts are not accessible through the editor, as they are only resolved when the scene is instantiated.

If you need those values, I recommend using resource files to save scene properties.

## User Contributions
> ⚠ This is not a project created with the intention of being maintained with frequent updates and new features.

I still plan on keeping it compatible with future engine verisons as long as its features don't become obsolete.

You are free to open new issues/PRs for bug fixes or features, but be aware that I might take a long time to reply and may deny them if they diverge too wildly from the intended scope.

If you want to fork the project for your own use, I just politely ask to attribute me in your credits section.
