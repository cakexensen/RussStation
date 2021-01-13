/obj/item/areaeditor/blueprints/dwarf
	name = "embarkment claim"
	desc = "A land grant from the nobles for claiming Dwarven land."
	color = "#6f4e37"

/obj/item/areaeditor/blueprints/dwarf/edit_area()
	var/area/A = get_area(src) // dwarfprints only work on lavaland
	if(is_mining_level(A.z))
		..()
	else
		to_chat(usr, "<span class='warning'>You cannot embark this far from the mountainhomes.</span>")

/obj/item/areaeditor/blueprints/dwarf/attack_self(mob/user)
	// only dwarves can use them
	if(is_species(usr, /datum/species/dwarf))
		to_chat(usr, "You can't seem to make sense of the dwarven property laws.")
	else
		return ..()