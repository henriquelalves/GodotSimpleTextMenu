
extends Control

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	for menu in get_node("menus").get_children():
		menu.connect("option_selected", self, "selected")
	select_menu(0)
	pass

func selected(o):
	print("Option selected: ",o)
	if(o == "Back"):
		select_menu(0)
	elif(o == "Go to Menu 1"):
		select_menu(1)
	elif(o == "Go to Menu 2"):
		select_menu(2)
	elif(o == "Go to Menu 3"):
		select_menu(3)

func select_menu(n):
	for menu in range(0, get_node("menus").get_child_count()):
		get_node("menus").get_child(menu).set_menu(false)
		if menu == n:
			get_node("menus").get_child(menu).set_menu(true)
