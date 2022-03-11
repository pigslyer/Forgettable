extends PopupPanel

var items: Array = [];
var selected: ItemInventory = null;

var saved_note: String = "Write your notes here!";

var keycards: String;
var keycard_ids: Array;

onready var tooltip: TextEdit = $VSplitContainer/HSplitContainer/ItemDesc;
onready var waffle: = $VSplitContainer/HSplitContainer/VSplitContainer/ItemWaffle;
onready var selected_rect: ReferenceRect = $Selected;
onready var hotbar := $VSplitContainer/HSplitContainer/VSplitContainer/Hotbar;

func _ready():
	waffle.items = items;

func add_item(item: ItemInventory) -> void:
	waffle.add_item(item);

func get_item(path: String, count: int) -> int:
	return waffle.get_item(path,count);

func add_keycard(display_name: String, key: String):
	keycards += display_name+"\n";
	keycard_ids.append(key);

func select(chosen: ItemInventory):
	override_tooltip();
	
	if chosen != null:
		selected = chosen;
		tooltip.text = str(chosen.name,"\n",chosen.tooltip);
		$VSplitContainer/Buttons/Equip.disabled = false;
		$VSplitContainer/Buttons/Drop.disabled = false;
		
		selected_rect.show();
		selected_rect.rect_position = waffle.get_global_rect().position-get_global_rect().position+chosen.pos*waffle.step;
		selected_rect.rect_size = chosen.size*waffle.step;
	else:
		override_selected();
	
	update_button();
	update_equipped();

func _on_ItemWaffle_gui_input(ev: InputEvent):
	if ev is InputEventMouseButton && ev.button_index == BUTTON_LEFT && ev.pressed:
		if waffle.get_at_pos(ev.position) != null:
			select(waffle.get_at_pos(ev.position));
			if ev.doubleclick || ev.shift:
				_on_Equip_pressed();
		else:
			override_selected();
			override_tooltip();
			update_button();
			tooltip.text = "";
	elif ev.is_action_pressed("rmb") && waffle.get_at_pos(ev.position) != null && (!get_viewport().gui_get_drag_data() is DragData.ItemDrag):
		selected = waffle.get_at_pos(ev.position);
		_on_Drop_pressed();
		update_button();

func _input(ev):
	if visible:
		if ev.is_action_pressed("inventory"):
			hide();
			get_viewport().set_input_as_handled();
		
		# bind to hotbar shortcut
		if ev is InputEventKey && ev.pressed && !ev.echo && ev.physical_scancode >= KEY_1 && ev.physical_scancode < KEY_1+hotbar.SLOTS:
			var item = selected if selected != null else waffle.get_at_pos(get_local_mouse_position()-waffle.rect_position);
			
			if item != null:
				if waffle.get_at_pos(get_local_mouse_position()-waffle.rect_position) in hotbar.items:
					hotbar.drop_data(
							Vector2((ev.physical_scancode-KEY_1)*(hotbar.rect_width+hotbar.SPACING),hotbar.SPACING*2),
							DragData.ItemHotbar.new(item,hotbar)
					);
				else:
					hotbar.items[ev.physical_scancode-KEY_1] = waffle.get_at_pos(get_local_mouse_position()-waffle.rect_position);
					hotbar.update_hotbars();
			
			get_viewport().set_input_as_handled();

# not sure if i should use a signal. wanna be handsy tho
func _on_Equip_pressed():
	if selected.equippable:
		Groups.get_player().equip(selected);
	else:
		Groups.get_player().equip_special(selected.path);
	

# no, i don't know what this function does
func _on_Drop_pressed():
	if !selected.equippable:
		Groups.get_player().equip_special(selected.path,true);
	
	items.remove(items.find(selected));
	if Groups.get_player().equipped == selected: Groups.get_player().equip(null);
	waffle.update_data();
	Projectile.drop_item(selected,Groups.get_player().global_position);
	override_selected();
	update_button();
	tooltip.text = "";
	
	selected = null;


func _on_Keycards_pressed():
	override_tooltip();
	override_selected();
	tooltip.text = keycards;

func _on_Notes_pressed():
	override_selected();
	update_equipped();
	tooltip.readonly = false;
	tooltip.text = saved_note;

func override_tooltip():
	if !tooltip.readonly:
		saved_note = tooltip.text;
		tooltip.readonly = true;

func override_selected():
	selected = null;
	selected_rect.hide();
	$VSplitContainer/Buttons/Equip.disabled = true;
	$VSplitContainer/Buttons/Drop.disabled = true;
	update_button();

func update_equipped():
	update_button();
	var equipped = Groups.get_player().equipped;
	
	$Equipped.visible = equipped != null;
	
	if equipped != null:
		$Equipped.rect_position = waffle.get_global_rect().position-get_global_rect().position+Groups.get_player().equipped.pos*waffle.step;
		$Equipped.rect_size = equipped.size*waffle.step;

func update_button():
	var equipped = Groups.get_player().equipped;
	var button: Button = $VSplitContainer/Buttons/Equip;
	
	if (equipped != null && equipped == selected) || (selected != null && Groups.get_player().special_equipped(selected.path)):
		button.text = "Unequip";
	else:
		button.text = "Equip";


func update_objective():
	$VSplitContainer/Objective.text = str("Objective: ",Save.cur_objective,"!");

func save_data():
	return [keycards,keycard_ids];

func load_data(data):
	keycard_ids = data[1]; keycards = data[0];
