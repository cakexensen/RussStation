//this pleases armoks beard
/datum/species/dwarf
	name = "Dwarf"
	id = "dwarf"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_NOBREATH)
	mutant_bodyparts = list("tail_human","ears","wings","mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	limbs_id = "human"
	use_skintones = 1
	speedmod = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	brutemod = 0.9
	coldmod = 0.85
	punchdamagehigh = 11 //fist fighting with dorfs is very dangerous
	mutanteyes = /obj/item/organ/eyes/night_vision
	species_language_holder = /datum/language_holder/dwarf
	// dwarves start with knowledge of their special recipes
	var/list/dwarf_recipes = list(/datum/crafting_recipe/broadsword,
		/datum/crafting_recipe/pickaxe,
		/datum/crafting_recipe/shovel,
		/datum/crafting_recipe/knife,
		/datum/crafting_recipe/war_hammer,
		/datum/crafting_recipe/smithed_armour,
		/datum/crafting_recipe/smithed_helmet,
		/datum/crafting_recipe/dwarf_rune)

/datum/species/dwarf/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	C.dna.add_mutation(DWARFISM)
	C.bubble_file = 'russstation/icons/mob/talk.dmi'
	C.bubble_icon = "dwarf"
	var/dwarf_hair = pick("Beard (Dwarf)", "Beard (Very Long)", "Beard (Full)")
	C.facial_hairstyle = dwarf_hair
	C.update_hair()
	for(var/datum/crafting_recipe/recipe in dwarf_recipes)
		C.mind.teach_crafting_recipe(recipe)
	// dwarves can see ghosts! and no putting them to rest with slabs, that would be too much
	C.AddComponent(/datum/component/spookable)

/datum/species/dwarf/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.dna.remove_mutation(DWARFISM)
	C.bubble_file = 'icons/mob/talk.dmi'
	C.bubble_icon = initial(C.bubble_icon)
	C.GetComponent(/datum/component/spookable).RemoveComponent()
	. = ..()

/datum/species/dwarf/random_name(gender, unique, lastname)
	return dwarf_name()
