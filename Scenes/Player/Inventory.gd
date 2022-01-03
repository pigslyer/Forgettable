extends PopupPanel

var items: Array = [];
var selected: ItemInventory = null;

var saved_note: String = "Write your notes here!";

var keycards: String;
var keycard_ids: Array;

onready var tooltip: TextEdit = $VSplitContainer/HSplitContainer/ItemDesc;
onready var waffle: = $VSplitContainer/HSplitContainer/ItemWaffle;
onready var selected_rect: ReferenceRect = $Selected;

func _ready():
	waffle.items = items;

func add_item(item: ItemInventory) -> void:
	waffle.add_item(item);

func add_keycard(display_name: String, key: String):
	keycards += display_name+"\n";
	keycard_ids.append(key);

func select(chosen: ItemInventory):
	override_tooltip();
	update_equipped();
	
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


func _on_ItemWaffle_gui_input(ev: InputEvent):
	if ev is InputEventMouseButton && ev.button_index == BUTTON_LEFT && ev.pressed:
		if waffle.get_at_pos(ev.position) != null:
			select(waffle.get_at_pos(ev.position));
			if ev.doubleclick || ev.shift:
				_on_Equip_pressed();
		else:
			override_selected();
			override_tooltip();
			tooltip.text = "";

func _input(ev):
	if visible && ev.is_action_pressed("inventory"):
		hide();
		get_viewport().set_input_as_handled();

# not sure if i should use a signal. wanna be handsy tho
func _on_Equip_pressed():
	Groups.get_player().equip(selected);
	update_equipped();

func _on_Drop_pressed():
	items.remove(items.find(selected));
	if Groups.get_player().equipped == selected: Groups.get_player().equip(null);
	waffle.update_data();
	var item = load(selected.path).instance();
	item.count = selected.count;
	Projectile.add_child(item);
	item.add_to_group(Groups.DROPPED_ITEM);
	item.global_position = Groups.get_player().global_position;
	override_selected();
	tooltip.text = "";
	update_equipped();


func _on_Keycards_pressed():
	override_tooltip();
	override_selected();
	tooltip.text = keycards;

func _on_Notes_pressed():
	override_selected();
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

func update_equipped():
	
	var equipped := Groups.get_player().equipped;
	$Equipped.visible = equipped != null;
	
	if equipped != null:
		$Equipped.rect_position = waffle.get_global_rect().position-get_global_rect().position+Groups.get_player().equipped.pos*waffle.step;
		$Equipped.rect_size = equipped.size*waffle.step;
