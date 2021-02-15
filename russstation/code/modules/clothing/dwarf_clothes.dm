/datum/outfit/dorf
	name = "Dwarf Standard"
	uniform = /obj/item/clothing/under/dwarf
	shoes = /obj/item/clothing/shoes/dwarf
	back = /obj/item/storage/backpack/satchel/leather
	gloves = /obj/item/clothing/gloves/dwarf

//Dwarf-unique clothes
/obj/item/clothing/under/dwarf
	name = "dwarven tunic"
	desc = "Very hip dwarven uniform."
	icon = 'russstation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'russstation/icons/mob/uniform.dmi'
	icon_state = "dwarf"
	inhand_icon_state = "dwarf"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	species_exception = list(/datum/species/dwarf)

/obj/item/clothing/gloves/dwarf
	name = "dwarven gloves"
	desc = "Great for pulping people in bar fights."
	worn_icon = 'russstation/icons/mob/hands.dmi'
	icon = 'russstation/icons/obj/clothing/gloves.dmi'
	icon_state = "dwarf"
	inhand_icon_state = "dwarf"
	body_parts_covered = ARMS
	species_exception = list(/datum/species/dwarf)

/obj/item/clothing/shoes/dwarf
	name = "dwarven shoes"
	desc = "Standered issue dwarven mining shoes."
	worn_icon = 'russstation/icons/mob/feet.dmi'
	icon = 'russstation/icons/obj/clothing/shoes.dmi'
	icon_state = "dwarf"
	inhand_icon_state = "dwarf"
	body_parts_covered = FEET
	species_exception = list(/datum/species/dwarf)

//Forged Armour
/obj/item/clothing/suit/armor/vest/dwarf
	name = "dwarven armour"
	desc = "Great for stopping sponges."
	worn_icon = 'russstation/icons/mob/suit.dmi'
	icon = 'russstation/icons/obj/clothing/suits.dmi'
	icon_state = "dwarf"
	inhand_icon_state = "dwarf"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	armor = list(melee = 50, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 80)
	strip_delay = 80
	equip_delay_self = 60
	species_exception = list(/datum/species/dwarf)

/obj/item/clothing/suit/armor/vest/dwarf/CheckParts(list/parts_list)
	..()
	var/obj/item/mold_result/armour_plating/S = locate() in contents
	if(S)
		var/image/Q = image(icon, icon_state)
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] armour"
		desc = "Armour forged from [S.material_type]."
		var/list/defenses = armor
		for(var/A in defenses)
			A = S.attack_amt/100

//Forged Helmet
/obj/item/clothing/head/helmet/dwarf
	name = "dwarven helm"
	desc = "Protects the head from tantrums."
	worn_icon= 'russstation/icons/mob/head.dmi'
	icon = 'russstation/icons/obj/clothing/hats.dmi'
	icon_state = "dwarf"
	inhand_icon_state = "dwarf"
	body_parts_covered = HEAD
	species_exception = list(/datum/species/dwarf)

/obj/item/clothing/head/helmet/dwarf/CheckParts(list/parts_list)
	..()
	var/obj/item/mold_result/helmet_plating/S = locate() in contents
	if(S)
		var/image/Q = image(icon, icon_state)
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] helmet."
		desc = "Helmet forged from [S.material_type]"
		var/list/defenses = armor
		for(var/A in defenses)
			A = S.attack_amt/100
