/*
 * Clay
 */

GLOBAL_LIST_INIT(clay_recipes, list(
	new /datum/stack_recipe("bar mold", /obj/item/molten_container/smelt_mold/bar, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("pickaxe mold", /obj/item/molten_container/smelt_mold/pickaxe, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("sword mold", /obj/item/molten_container/smelt_mold/sword, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("shovel mold", /obj/item/molten_container/smelt_mold/shovel, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("knife mold", /obj/item/molten_container/smelt_mold/knife, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("hammer mold", /obj/item/molten_container/smelt_mold/war_hammer, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("armour mold", /obj/item/molten_container/smelt_mold/armour, req_amount=1, res_amount=1), \
	new /datum/stack_recipe("helmet mold", /obj/item/molten_container/smelt_mold/helmet, req_amount=1, res_amount=1), \
	))

/obj/item/stack/sheet/mineral/clay 
	name = "clay"
	icon = 'russstation/icons/obj/stack_objects.dmi'
	icon_state = "sheet-clay"
	singular_name = "clay lump"
	layer = LOW_ITEM_LAYER
	merge_type = /obj/item/stack/sheet/mineral/clay 
	sheettype = "clay"

/obj/item/stack/sheet/mineral/clay/get_main_recipes()
	. = ..()
	. += GLOB.clay_recipes
