
// GENERIC PROJECTILE

/obj/projectile/beam/ctf
	damage = 0
	icon_state = "omnilaser"

/obj/projectile/beam/ctf/prehit_pierce(atom/target)
	if(!is_ctf_target(target))
		damage = 0
		return PROJECTILE_PIERCE_NONE /// hey uhhh don't hit anyone behind them
	. = ..()

/obj/projectile/beam/ctf/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(is_ctf_target(target) && blocked == FALSE)
		if(iscarbon(target))
			var/mob/living/carbon/target_mob = target
			target_mob.adjustBruteLoss(150, 0)
		return BULLET_ACT_HIT

/obj/item/ammo_box/magazine/recharge/ctf
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf

/obj/item/ammo_box/magazine/recharge/ctf/Initialize()
	. = ..()
	AddElement(/datum/element/delete_on_drop)


/obj/item/ammo_casing/caseless/laser/ctf
	projectile_type = /obj/projectile/beam/ctf/

/obj/item/ammo_casing/caseless/laser/ctf/Initialize()
	. = ..()
	AddElement(/datum/element/delete_on_drop)

// LASER RIFLE

/obj/item/gun/ballistic/automatic/laser/ctf
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle
	desc = "This looks like it could really hurt in melee."
	force = 50
	weapon_weight = WEAPON_HEAVY
	slot_flags = null

/obj/item/gun/ballistic/automatic/laser/ctf/Initialize()
	. = ..()
	AddElement(/datum/element/delete_on_drop)


/obj/item/ammo_box/magazine/recharge/ctf/rifle
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/rifle


/obj/item/ammo_casing/caseless/laser/ctf/rifle
	projectile_type = /obj/projectile/beam/ctf/rifle


/obj/projectile/beam/ctf/rifle
	damage = 45
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// LASER SHOTGUN

/obj/item/gun/ballistic/shotgun/ctf
	name = "laser shotgun"
	desc = "This looks like it could really hurt in melee."
	icon_state = "ctfshotgun"
	inhand_icon_state = "shotgun_combat"
	worn_icon_state = "gun"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun
	empty_indicator = TRUE
	fire_sound = 'sound/weapons/gun/shotgun/shot_alt.ogg'
	semi_auto = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE

/obj/item/gun/ballistic/shotgun/ctf/Initialize()
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_box/magazine/recharge/ctf/shotgun
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/shotgun
	max_ammo = 6


/obj/item/ammo_casing/caseless/laser/ctf/shotgun
	projectile_type = /obj/projectile/beam/ctf/shotgun
	pellets = 6
	variance = 25


/obj/projectile/beam/ctf/shotgun
	damage = 15
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// MARKSMAN RIFLE

/obj/item/gun/ballistic/automatic/laser/ctf/marksman
	name = "designated marksman rifle"
	icon_state = "ctfmarksman"
	inhand_icon_state = "ctfmarksman"
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman
	fire_delay = 1 SECONDS

/obj/item/ammo_box/magazine/recharge/ctf/marksman
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/marksman
	max_ammo = 10

/obj/item/ammo_casing/caseless/laser/ctf/marksman
	projectile_type = /obj/projectile/beam/ctf/marksman

/obj/projectile/beam/ctf/marksman
	damage = 30
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

// DESERT EAGLE

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf
	desc = "This looks like it could really hurt in melee."
	force = 75
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/deagle

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/Initialize()
	. = ..()
	AddElement(/datum/element/delete_on_drop)


/obj/item/ammo_box/magazine/recharge/ctf/deagle
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/deagle
	max_ammo = 7


/obj/item/ammo_casing/caseless/laser/ctf/deagle
	projectile_type = /obj/projectile/beam/ctf/deagle


/obj/projectile/beam/ctf/deagle
	icon_state = "bullet"
	damage = 60
	light_color = COLOR_WHITE
	impact_effect_type = /obj/effect/temp_visual/impact_effect

// INSTAKILL RIFLE

/obj/item/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	inhand_icon_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	slot_flags = null
	charge_sections = 5
	ammo_x_offset = 2
	shaded_charge = FALSE

/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/laser/instakill/ctf/Initialize()
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/projectile/beam/instakill
	e_cost = 0
	select_name = "DESTROY"

/obj/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/target_mob = target
		target_mob.visible_message(span_danger("[target_mob] explodes into a shower of gibs!"))
		target_mob.gib()

// SHIELDED HARDSUIT

/obj/item/clothing/suit/space/hardsuit/shielded/ctf
	name = "white shielded hardsuit"
	desc = "Standard issue hardsuit for playing capture the flag."
	icon_state = "ert_medical"
	inhand_icon_state = "ert_medical"
	hardsuit_type = "ert_medical"
	// Adding TRAIT_NODROP is done when the CTF spawner equips people
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0) // CTF gear gives no protection outside of the shield
	allowed = null
	slowdown = 0
	max_charges = 150
	recharge_amount = 30
	lose_multiple_charges = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	name = "shielded hardsuit helmet"
	desc = "Standard issue hardsuit helmet for playing capture the flag."
	icon_state = "hardsuit0-ert_medical"
	inhand_icon_state = "hardsuit0-ert_medical"
	hardsuit_type = "ert_medical"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

// LIGHT SHIELDED HARDSUIT

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/light
	name = "light white shielded hardsuit"
	desc = "Lightweight hardsuit for playing capture the flag."
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light
	max_charges = 30
	slowdown = -0.25

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light
	name = "light shielded hardsuit helmet"
	desc = "Lightweight hardsuit helmet for playing capture the flag."

// RED TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/red
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/red

/obj/item/ammo_box/magazine/recharge/ctf/rifle/red
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/rifle/red

/obj/item/ammo_casing/caseless/laser/ctf/rifle/red
	projectile_type = /obj/projectile/beam/ctf/rifle/red

/obj/projectile/beam/ctf/rifle/red
	icon_state = "laser"
	light_color = COLOR_SOFT_RED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser


// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/red
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/red

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/red
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/shotgun/red

/obj/item/ammo_casing/caseless/laser/ctf/shotgun/red
	projectile_type = /obj/projectile/beam/ctf/shotgun/red

/obj/projectile/beam/ctf/shotgun/red
	icon_state = "laser"
	light_color = COLOR_SOFT_RED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser


// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/red
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/red

/obj/item/ammo_box/magazine/recharge/ctf/marksman/red
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/marksman/red

/obj/item/ammo_casing/caseless/laser/ctf/marksman/red
	projectile_type = /obj/projectile/beam/ctf/marksman/red

/obj/projectile/beam/ctf/marksman/red
	icon_state = "laser"
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser


// Instakill
/obj/item/gun/energy/laser/instakill/ctf/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	inhand_icon_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/projectile/beam/instakill/red

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED

// BLUE TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/blue
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/blue

/obj/item/ammo_box/magazine/recharge/ctf/rifle/blue
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/rifle/blue

/obj/item/ammo_casing/caseless/laser/ctf/rifle/blue
	projectile_type = /obj/projectile/beam/ctf/rifle/blue

/obj/projectile/beam/ctf/rifle/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/blue
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/blue

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/blue
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/shotgun/blue

/obj/item/ammo_casing/caseless/laser/ctf/shotgun/blue
	projectile_type = /obj/projectile/beam/ctf/shotgun/blue

/obj/projectile/beam/ctf/shotgun/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser


// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/blue
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/blue

/obj/item/ammo_box/magazine/recharge/ctf/marksman/blue
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/marksman/blue

/obj/item/ammo_casing/caseless/laser/ctf/marksman/blue
	projectile_type = /obj/projectile/beam/ctf/marksman/blue

/obj/projectile/beam/ctf/marksman/blue


// Instakill
/obj/item/gun/energy/laser/instakill/ctf/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	inhand_icon_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/projectile/beam/instakill/blue

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

// GREEN TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/green
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/green

/obj/item/ammo_box/magazine/recharge/ctf/rifle/green
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/rifle/green

/obj/item/ammo_casing/caseless/laser/ctf/rifle/green
	projectile_type = /obj/projectile/beam/ctf/rifle/green

/obj/projectile/beam/ctf/rifle/green
	icon_state = "xray"
	light_color = COLOR_VERY_PALE_LIME_GREEN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser


// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/green
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/green

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/green
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/shotgun/green

/obj/item/ammo_casing/caseless/laser/ctf/shotgun/green
	projectile_type = /obj/projectile/beam/ctf/shotgun/green

/obj/projectile/beam/ctf/shotgun/green
	icon_state = "xray"
	light_color = COLOR_VERY_PALE_LIME_GREEN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser


// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/green
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/green

/obj/item/ammo_box/magazine/recharge/ctf/marksman/green
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/marksman/green

/obj/item/ammo_casing/caseless/laser/ctf/marksman/green
	projectile_type = /obj/projectile/beam/ctf/marksman/green

/obj/projectile/beam/ctf/marksman/green
	icon_state = "xray"
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray


// Instakill
/obj/item/gun/energy/laser/instakill/ctf/green
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a green design."
	icon_state = "instagibgreen"
	inhand_icon_state = "instagibgreen"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/green)

/obj/item/ammo_casing/energy/instakill/green
	projectile_type = /obj/projectile/beam/instakill/green

/obj/projectile/beam/instakill/green
	icon_state = "green_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = COLOR_VERY_PALE_LIME_GREEN

// YELLOW TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/yellow
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/yellow

/obj/item/ammo_box/magazine/recharge/ctf/rifle/yellow
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/rifle/yellow

/obj/item/ammo_casing/caseless/laser/ctf/rifle/yellow
	projectile_type = /obj/projectile/beam/ctf/rifle/yellow

/obj/projectile/beam/ctf/rifle/yellow
	icon_state = "gaussstrong"
	light_color = COLOR_VERY_SOFT_YELLOW
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser


// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/yellow
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/yellow

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/yellow
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/shotgun/yellow

/obj/item/ammo_casing/caseless/laser/ctf/shotgun/yellow
	projectile_type = /obj/projectile/beam/ctf/shotgun/yellow

/obj/projectile/beam/ctf/shotgun/yellow
	icon_state = "gaussstrong"
	light_color = COLOR_VERY_SOFT_YELLOW
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser


// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/yellow
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/yellow

/obj/item/ammo_box/magazine/recharge/ctf/marksman/yellow
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/marksman/yellow

/obj/item/ammo_casing/caseless/laser/ctf/marksman/yellow
	projectile_type = /obj/projectile/beam/ctf/marksman/yellow

/obj/projectile/beam/ctf/marksman/yellow
	icon_state = "gaussstrong"
	tracer_type = /obj/effect/projectile/tracer/solar
	muzzle_type = /obj/effect/projectile/muzzle/solar
	impact_type = /obj/effect/projectile/impact/solar


// Instakill
/obj/item/gun/energy/laser/instakill/ctf/yellow
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a yellow design."
	icon_state = "instagibyellow"
	inhand_icon_state = "instagibyellow"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/yellow)

/obj/item/ammo_casing/energy/instakill/yellow
	projectile_type = /obj/projectile/beam/instakill/yellow

/obj/projectile/beam/instakill/yellow
	icon_state = "yellow_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	light_color = COLOR_VERY_SOFT_YELLOW

// RED TEAM SUITS

// Regular
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	name = "red shielded hardsuit"
	icon_state = "ert_security"
	inhand_icon_state = "ert_security"
	hardsuit_type = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	shield_icon = "shield-red"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	icon_state = "hardsuit0-ert_security"
	inhand_icon_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"

// Light
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/red
	name = "light red shielded hardsuit"
	icon_state = "ert_security"
	inhand_icon_state = "ert_security"
	hardsuit_type = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/red
	shield_icon = "shield-red"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/red
	icon_state = "hardsuit0-ert_security"
	inhand_icon_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"

// BLUE TEAM SUITS

// Regular
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	name = "blue shielded hardsuit"
	icon_state = "ert_command"
	inhand_icon_state = "ert_command"
	hardsuit_type = "ert_commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	shield_icon = "shield-old"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	icon_state = "hardsuit0-ert_commander"
	inhand_icon_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"

// Light
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/blue
	name = "light blue shielded hardsuit"
	icon_state = "ert_command"
	inhand_icon_state = "ert_command"
	hardsuit_type = "ert_commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/blue
	shield_icon = "shield-old"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/blue
	icon_state = "hardsuit0-ert_commander"
	inhand_icon_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"

// GREEN TEAM SUITS

// Regular
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/green
	name = "green shielded hardsuit"
	icon_state = "ert_green"
	inhand_icon_state = "ert_green"
	hardsuit_type = "ert_green"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/green
	shield_icon = "shield-green"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/green
	icon_state = "hardsuit0-ert_green"
	inhand_icon_state = "hardsuit0-ert_green"
	hardsuit_type = "ert_green"

// Light
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/green
	name = "light green shielded hardsuit"
	icon_state = "ert_green"
	inhand_icon_state = "ert_green"
	hardsuit_type = "ert_green"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/green
	shield_icon = "shield-green"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/green
	icon_state = "hardsuit0-ert_green"
	inhand_icon_state = "hardsuit0-ert_green"
	hardsuit_type = "ert_green"

// YELLOW TEAM SUITS

// Regular
/obj/item/clothing/suit/space/hardsuit/shielded/ctf/yellow
	name = "yellow shielded hardsuit"
	icon_state = "ert_engineer"
	inhand_icon_state = "ert_engineer"
	hardsuit_type = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/yellow
	shield_icon = "shield-yellow"

// Light
/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/yellow
	icon_state = "hardsuit0-ert_engineer"
	inhand_icon_state = "hardsuit0-ert_engineer"
	hardsuit_type = "ert_engineer"

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/yellow
	name = "light yellow shielded hardsuit"
	icon_state = "ert_engineer"
	inhand_icon_state = "ert_engineer"
	hardsuit_type = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/yellow
	shield_icon = "shield-yellow"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/light/yellow
	icon_state = "hardsuit0-ert_engineer"
	inhand_icon_state = "hardsuit0-ert_engineer"
	hardsuit_type = "ert_engineer"
