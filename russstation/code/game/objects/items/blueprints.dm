/obj/item/areaeditor/blueprints/dwarf
	name = "embarkment claim"
	desc = "A land grant from the nobles for claiming Dwarven land."
	color = "#6f4e37"

/obj/item/areaeditor/blueprints/dwarf/edit_area()
	var/area/A = get_area(src)
	if(is_mining_level(A.z)) // dwarfprints only work on lavaland
		..()
	else
		to_chat(usr, "<span class='warning'>You cannot embark this far from the mountainhomes.</span>")

/obj/item/areaeditor/blueprints/dwarf/attack_self(mob/user)
	// only dwarves can use them
	if(!is_species(usr, /datum/species/dwarf))
		to_chat(usr, "You can't seem to make sense of the dwarven property laws.")
		return

	// don't call ..() as it forcibly inserts station name, which dwarves won't know.
	add_fingerprint(user)
	. = "<BODY><HTML><head><title>[src]</title></head> \
				<h2>[src.name]</h2><hr>"
	var/area/A = get_area(src)
	if(!is_mining_level(A.z)) // dwarfprints only work on lavaland
		. += "<p>This place is too far from the mountainhomes.</p>"
	else if(A.outdoors)
		. += "<p>According to the [src.name], you are now in an unclaimed territory.</p>"
	. += "<p><a href='?src=[REF(src)];create_area=1'>Create or modify an existing area</a></p>"
	. += "<p>According to \the [src], you are now in <b>\"[html_encode(A.name)]\"</b>.</p>"
	. += "<p><a href='?src=[REF(src)];edit_area=1'>Change area name</a></p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")
