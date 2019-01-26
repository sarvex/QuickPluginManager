

#Written:
#Date: 01/26/2019
#Author: Markus Septer
#Contributors:


#How to use:
#1)If you already have "addons" folder in "res://", jump to step (3)
#2)If you don't have "addons" folder in "res://" create it
#3)Drag and drop the folder this script is (should be named "QuickPluginMaker") in into "res://addons"

#Folder structure should look like this: "res://addons/QuickPluginManager"
#NB:if you wish to change name of this plugin through godot editor you also have to change var "PLUGIN_SELF_NAME" to same name

tool
extends EditorPlugin


const PLUGIN_PATH = "res://addons"
const POPUP_BUTTON_TEXT = "Manage Plugins"
const MENU_BUTTON_TOOLTIP = "Quickly enable/disable plugins"
#if you change name of plugin from godot editor this variable also must changed to same
const PLUGIN_SELF_NAME = "QuickPluginManager"


var _plugin_menu_btn = MenuButton.new()
var _plugins_menu =  _plugin_menu_btn.get_popup()

var plugins_data = {}
var menu_items_idx = 0



func _enter_tree():
	_plugin_menu_btn.text = POPUP_BUTTON_TEXT
	_plugin_menu_btn.hint_tooltip = MENU_BUTTON_TOOLTIP
	
	
	var addons_dir = Directory.new()
	
	var SKIP_NAVIGATIONAL = true
	var SKIP_HIDDEN_FILES = false
	var PLUGIN_CFG_FILE_NAME = "plugin.cfg"
	
	
	if addons_dir.open(PLUGIN_PATH) == OK:
		addons_dir.list_dir_begin(SKIP_NAVIGATIONAL, SKIP_HIDDEN_FILES)
		var file_name = addons_dir.get_next()
		while (file_name != ""):
			if addons_dir.current_is_dir():
				var plugin_full_path = PLUGIN_PATH + "/" + file_name
				var conf_file_path = plugin_full_path + "/" + PLUGIN_CFG_FILE_NAME
				
				#check if plugin directory has "cfg" file
				if addons_dir.file_exists(conf_file_path):
					var conf = ConfigFile.new()
					conf.load(conf_file_path)
					var plugin_name = str(conf.get_value("plugin", "name"))
					#the name of plugin folder inside "res://addons"
					var plugin_info = {
						"plugin_folder":file_name,
						"menu_item_index":menu_items_idx
						}
					
					_plugins_menu.add_check_item(plugin_name)
						
					if plugin_name == PLUGIN_SELF_NAME:
						_plugins_menu.set_item_disabled(menu_items_idx, true)

					var isPluginEnabledByDefault = get_editor_interface().is_plugin_enabled(file_name)
					_plugins_menu.set_item_checked(menu_items_idx, isPluginEnabledByDefault)
					
					plugins_data[plugin_name] = plugin_info
					menu_items_idx += 1
			else:
				pass
				#print("is file: " + file_name)
			file_name =  addons_dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	
	_plugins_menu.connect("index_pressed", self, "item_toggled", [_plugins_menu])

	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_menu_btn)


func item_toggled(item_index, menuObj):
	var is_item_checked = menuObj.is_item_checked(item_index)
	_plugins_menu.set_item_checked(item_index, not is_item_checked)

	for plugin_name in plugins_data:
		var plugin_info = plugins_data[plugin_name]
		
		if item_index == plugin_info.menu_item_index:
			var plugin_folder_name = plugin_info.plugin_folder
			get_editor_interface().set_plugin_enabled(plugin_folder_name, not is_item_checked)


#clean up
func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_menu_btn)

	if _plugin_menu_btn:
		_plugin_menu_btn.queue_free()