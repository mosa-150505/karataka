extends Control
# res://Scripts/inventory_ui.gd

# --- Variables de l'inventaire ---
var player_inventory: Inventory
var hover_label: Label
var money_label: Label
var status_label: Label

# Références du panneau inventaire (pour affichage/masquage)
var _inventory_panel: PanelContainer
var _inventory_caption: Label
var _inventory_button: Button
var _inventory_open: bool = false
var _money_panel: PanelContainer
var _grid_container: GridContainer

const INVENTORY_SLOTS := 32
const INVENTORY_COLUMNS := 8

# --- Références des ressources d'items de la ferme ---
var item_mais: ItemData
var item_riz: ItemData
var item_viande: ItemData
var item_manioc: ItemData

func _ready() -> void:
	# Connecter les données aux Autoloads globaux valides du projet
	player_inventory = FarmManager.player_inventory
	
	_create_farm_items()
	_build_ui()
	
	# Écoute des changements d'argent du GameState global
	GameState.money_changed.connect(_on_money_changed)
	
	# Items de départ injectés dans le sac global du joueur
	player_inventory.add_item(item_mais, 5)
	player_inventory.add_item(item_riz, 3)
	player_inventory.add_item(item_viande, 2)
	
	_update_money_display()
	_update_slots_display()
	_set_inventory_open(false)

# ------------------------------------------------------------------
#  Construction des items de test de la ferme
# ------------------------------------------------------------------
func _make_item(p_name: String, p_category: String, p_sell: int, p_color: Color) -> ItemData:
	var item := ItemData.new()
	item.item_name = p_name
	item.category = p_category
	item.sell_price = p_sell
	item.max_stack_size = 99
		# --- BLOC NETTOYÉ ET DÉFINITIF ---
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(color_with_alpha(p_color, 1.0))
	
	# Utilisation de la méthode standard
	var tex = ImageTexture.create_from_image(img)
	
	item.icon = tex


	return item

func color_with_alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)

func _create_farm_items() -> void:
	item_mais = _make_item("Mais", "recolte", 12, Color(0.92, 0.75, 0.15))
	item_riz = _make_item("Riz", "recolte", 15, Color(0.9, 0.88, 0.8))
	item_viande = _make_item("Viande", "nourriture", 45, Color(0.78, 0.3, 0.25))
	item_manioc = _make_item("Manioc", "recolte", 18, Color(0.58, 0.46, 0.34))

# ------------------------------------------------------------------
#  Interface Graphique (UI Procédurale Standard)
# ------------------------------------------------------------------
func _build_ui() -> void:
	# Fond noir transparent recouvrant l'écran
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# --- Cadre principal de l'inventaire ---
	_inventory_panel = _make_frame_panel(Color(0.6, 0.42, 0.2), Color(0.3, 0.2, 0.11))
	_inventory_panel.position = Vector2(_center_x(INVENTORY_COLUMNS), 114)
	add_child(_inventory_panel)

	var inventory_margin := _make_margin(_inventory_panel)
	
	# CORRECTION IMPORTANTE : Remplacement du nœud manquant par un GridContainer natif
	_grid_container = GridContainer.new()
	_grid_container.columns = INVENTORY_COLUMNS
	_grid_container.add_theme_constant_override("h_separation", 6)
	_grid_container.add_theme_constant_override("v_separation", 6)
	inventory_margin.add_child(_grid_container)

	# Génération des 32 cases visuelles vides de départ
	for i in range(INVENTORY_SLOTS):
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(52, 52)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.2, 0.13, 0.08)
		sb.set_border_width_all(1)
		sb.border_color = Color(0.4, 0.28, 0.16)
		sb.set_corner_radius_all(4)
		slot_panel.add_theme_stylebox_override("panel", sb)
		
		# Nœud d'image de l'objet à l'intérieur
		var texture_rect = TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot_panel.add_child(texture_rect)
		
		# Libellé du nombre d'objets cumulés
		var qty_lbl = Label.new()
		qty_lbl.add_theme_font_size_override("font_size", 11)
		qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		slot_panel.add_child(qty_lbl)
		qty_lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		
		_grid_container.add_child(slot_panel)

	# Titre de la boîte
	var title_w := 326.0
	_inventory_caption = _make_caption("INVENTAIRE")
	_inventory_caption.size = Vector2(title_w, 44)
	_inventory_caption.position = Vector2(_center_x(INVENTORY_COLUMNS) + (_grid_size(INVENTORY_COLUMNS, 4).x - title_w) / 2.0, 50)

	# --- Bouton d'ouverture (Flottant à droite) ---
	_inventory_button = _make_pixel_button("Sac", func(): _toggle_inventory())
	_inventory_button.custom_minimum_size = Vector2(52, 52)
	add_child(_inventory_button)
	_inventory_button.position = Vector2(_right_align_x(52.0), (720.0 - 52.0) / 2.0)

	# --- Cadre de l'affichage de l'argent (Haut Droite) ---
	_money_panel = _make_frame_panel(Color(0.6, 0.42, 0.2), Color(0.22, 0.14, 0.08))
	_money_panel.position = Vector2(_right_align_x(180.0), 30)
	_money_panel.custom_minimum_size = Vector2(180, 46)
	add_child(_money_panel)

	money_label = Label.new()
	money_label.add_theme_font_size_override("font_size", 14)
	money_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.3))
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_money_panel.add_child(money_label)
	money_label.set_anchors_preset(Control.PRESET_FULL_RECT)

	# --- Libellés de statut en bas ---
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)
	status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_label.offset_top = -40

	hover_label = Label.new()
	hover_label.add_theme_font_size_override("font_size", 14)
	hover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hover_label)
	hover_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hover_label.offset_top = -70

# --- 🔄 ACTUALISATION VISUELLE DES LOGEMENTS DU SAC ---
func _update_slots_display() -> void:
	if _grid_container == null:
		return
		
	for i in range(INVENTORY_SLOTS):
		var slot_panel = _grid_container.get_child(i)
		var texture_rect = slot_panel.get_child(0) as TextureRect
		var qty_lbl = slot_panel.get_child(1) as Label
		
		var data_slot = player_inventory.slots[i]
		if data_slot.item != null and data_slot.quantity > 0:
			texture_rect.texture = data_slot.item.icon
			qty_lbl.text = str(data_slot.quantity)
		else:
			texture_rect.texture = null
			qty_lbl.text = ""

# --- Fonctions utilitaires de positionnement ---
func _center_x(cols: int) -> float:
	return (1280.0 - _grid_size(cols, 4).x) / 2.0

func _right_align_x(width: float) -> float:
	return 1280.0 - width - 20.0

func _grid_size(cols: int, rows: int) -> Vector2:
	var gap := 6.0
	return Vector2(cols * 52 + (cols - 1) * gap + 28, rows * 52 + (rows - 1) * gap + 28)

func _make_frame_panel(border: Color, bg: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(2)
	sb.border_color = border
	sb.set_corner_radius_all(8)
	p.add_theme_stylebox_override("panel", sb)
	return p

func _make_caption(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color(0.99, 0.93, 0.75))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.5, 0.34, 0.17)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.68, 0.47, 0.25)
	sb.set_corner_radius_all(8)
	l.add_theme_stylebox_override("normal", sb)
	add_child(l)
	return l

func _make_margin(parent: Control) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 14)
	m.add_theme_constant_override("margin_right", 14)
	m.add_theme_constant_override("margin_top", 14)
	m.add_theme_constant_override("margin_bottom", 14)
	parent.add_child(m)
	return m

func _make_pixel_button(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.3, 0.2, 0.12)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.55, 0.4, 0.22)
	sb.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", sb)
	btn.pressed.connect(cb)
	return btn

# ------------------------------------------------------------------
#  Gestion d'ouverture, de fermeture et d'inputs
# ------------------------------------------------------------------
func _toggle_inventory() -> void:
	_set_inventory_open(not _inventory_open)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			_toggle_inventory()

func _set_inventory_open(open: bool) -> void:
	_inventory_open = open
	_inventory_panel.visible = open
	_inventory_caption.visible = open
	_money_panel.visible = open
	
	if open:
		_update_slots_display()
		status_label.text = ""
		status_label.add_theme_color_override("font_color", Color(0.086, 0.902, 0.059, 1.0))
	else:
		status_label.text = ""
		status_label.add_theme_color_override("font_color", Color(0.651, 0.086, 0.098, 1.0))

func _on_money_changed(_new_amount: int) -> void:
	_update_money_display()

func _update_money_display() -> void:
	if money_label != null:
		money_label.text = "Argents : %d Ar" % GameState.money
