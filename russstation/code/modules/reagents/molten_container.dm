// reagent_container but for smelting, don't want to handle milk in a smelting mold
/obj/item/molten_container
	name = "Molten container"
	desc = "Container for holding molten metal."
	var/volume = 100
	var/reagent_flags = OPENCONTAINER
	var/spillable = TRUE

/obj/item/molten_container/Initialize()
	. = ..()
	create_reagents(volume, reagent_flags)

/obj/item/molten_container/on_reagent_change(changetype)
	update_icon()

/obj/item/molten_container/update_icon_state()
	if(reagents.total_volume > 0)
		icon_state = base_icon_state + "_filled"
	else
		icon_state = base_icon_state

/obj/item/molten_container/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	SplashReagents(hit_atom, TRUE)

// shamelessly copied from reagent_containers
/obj/item/molten_container/proc/SplashReagents(atom/target, thrown = FALSE)
	if(!reagents || !reagents.total_volume || !spillable)
		return

	if(ismob(target) && target.reagents)
		if(thrown)
			reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[M] is splashed with something!</span>", \
						"<span class='userdanger'>[M] is splashed with something!</span>", \
						"<span class='hear'>You hear something splashing!</span>")
		for(var/datum/reagent/A in reagents.reagent_list)
			R += "[A.type]  ([num2text(A.volume)]),"

		if(thrownby)
			log_combat(thrownby, M, "splashed", R)
		reagents.expose(target, TOUCH)

	else
		if(isturf(target) && reagents.reagent_list.len && thrownby)
			log_combat(thrownby, target, "splashed (thrown) [english_list(reagents.reagent_list)]", "in [AREACOORD(target)]")
			log_game("[key_name(thrownby)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [AREACOORD(target)].")
			message_admins("[ADMIN_LOOKUPFLW(thrownby)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>", blind_message = "<span class='hear'>You hear something spilling!</span>")
		reagents.expose(target, TOUCH)
		if(QDELETED(src))
			return

	reagents.clear_reagents()

/obj/item/molten_container/crucible
	name = "Iron crucible"
	desc = "A crucible used to hold smelted ore."
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "iron_crucible"
	base_icon_state = "iron_crucible"
	inhand_icon_state = "crucible"

// Smelting molds - make from clay, pour in molten ore, whack into shape
/obj/item/molten_container/smelt_mold
	name = "Smelting mold"
	desc = "A clay mold for casting metal."
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "mold1"
	base_icon_state = "mold1"
	inhand_icon_state = "mold"
	volume = 25
	var/obj/produce_type = null

/obj/item/molten_container/smelt_mold/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/molten_container/crucible))
		// pour if there's enough in the crucible - easier to handle this as all-or-nothing
		var/obj/item/molten_container/crucible/crucible = W
		if(reagents.total_volume >= volume)
			to_chat(user, "<span class='notice'>[src] is already filled.</span>")
		else if(crucible.reagents.total_volume < volume)
			to_chat(user, "<span class='notice'>[crucible] needs [volume] units of molten metal all at once to fill [src].</span>")
		else if(do_after(user, 10, src))
			crucible.reagents.trans_to(src, volume)
			user.visible_message("[user] pours the contents of [crucible] into [src].", "You pour the contents of [crucible] into [src].", "<span class='hear'>You hear a sizzling sound.</span>")
	else if(istype(W, /obj/item/melee/smith_hammer))
		// mold placed on an anvil becomes "part of" the anvil, so this code only occurs if the mold is elsewhere
		to_chat(user, "<span class='notice'>[src] needs to be placed on an anvil to smith it.</span>")
	else
		..()

/obj/item/molten_container/smelt_mold/sword
	name = "sword mold"
	desc = "A clay mold of a sword blade."
	icon_state = "mold_blade"
	base_icon_state = "mold_blade"
	produce_type = /obj/item/mold_result/blade

/obj/item/molten_container/smelt_mold/pickaxe
	name = "pickaxe mold"
	desc = "A clay mold of a pickaxe head."
	icon_state = "mold_pickaxe"
	base_icon_state = "mold_pickaxe"
	produce_type = /obj/item/mold_result/pickaxe_head

/obj/item/molten_container/smelt_mold/shovel
	name = "shovel mold"
	desc = "A clay mold of a shovel head."
	icon_state = "mold_shovel"
	base_icon_state = "mold_shovel"
	produce_type = /obj/item/mold_result/shovel_head

/obj/item/molten_container/smelt_mold/knife
	name = "knife mold"
	desc = "A clay mold of a knife head."
	icon_state = "mold_knife"
	base_icon_state = "mold_knife"
	produce_type = /obj/item/mold_result/knife_head

/obj/item/molten_container/smelt_mold/war_hammer
	name = "war hammer mold"
	desc = "A clay mold of a war hammer head."
	icon_state = "mold_war_hammer"
	base_icon_state = "mold_war_hammer"
	produce_type = /obj/item/mold_result/war_hammer_head

//Bar / Sheet metal mold
/obj/item/molten_container/smelt_mold/bar
	name = "bar mold"
	desc = "A clay mold of a bar."

/obj/item/molten_container/smelt_mold/helmet
	name = "helmet mold"
	desc = "A clay mold of a helmet."
	icon_state = "mold_shovel"
	base_icon_state = "mold_shovel"
	produce_type = /obj/item/mold_result/helmet_plating

/obj/item/molten_container/smelt_mold/armour
	name = "armour mold"
	desc = "A clay mold of armour plating."
	icon_state = "mold_shovel"
	base_icon_state = "mold_shovel"
	produce_type = /obj/item/mold_result/armour_plating
