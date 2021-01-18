/obj/item/reagent_containers/glass/bucket/iron_crucible_bucket
	name = "cast iron crucible"
	desc = "A crucible used to smelt ore down inside a smelter."
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "iron_crucible"
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)
	volume = 100
	slot_flags = NONE

/obj/item/crucible_tongs
	name = "crucible tongs"
	desc = "Used to take hot crucibles out of smelters"
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "tong"

/obj/machinery/smelter
	name = "smelter"
	desc = "An old Sendarian tool. Fuel: (0/20)"
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "forge"
	density = TRUE
	anchored = FALSE
	var/obj/item/reagent_containers/glass/bucket/iron_crucible_bucket/crucible = null
	var/mutable_appearance/my_bucket = null
	var/bucket_loaded = FALSE
	var/fuel = 0
	var/fuel_max = 20

/obj/machinery/smelter/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/grown/log) && !(fuel >= fuel_max)) //add fuel
		to_chat(user, "You add the [W.name] to the fuel supply of the smelter.")
		fuel += 5
		desc = "An old Sendarian tool. Fuel: ([fuel]/20)" //update
		if(fuel > fuel_max) //adjust fuel if it goes over the max
			fuel = fuel_max
		user.dropItemToGround(W)
		qdel(W)

	if(istype(W, /obj/item/reagent_containers/glass/bucket/iron_crucible_bucket) && bucket_loaded == FALSE) //load in bucket
		to_chat(user, "You load the smelter with a crucible. It is now ready to smelt ore.")
		crucible = W
		bucket_loaded = TRUE
		user.dropItemToGround(W)
		W.loc = src
		my_bucket = mutable_appearance('russstation/icons/obj/blacksmithing.dmi', W.icon_state)
		add_overlay(my_bucket)
		return

	if(istype(W, /obj/item/crucible_tongs) && bucket_loaded == TRUE) //take out bucket
		to_chat(user, "You take the crucible out of the smelter.")
		var/obj/item/reagent_containers/glass/bucket/iron_crucible_bucket/C = new(get_turf(src))
		C.reagents = crucible.reagents
		C.volume = 100
		cut_overlay(my_bucket)
		bucket_loaded = FALSE
		my_bucket = null
		crucible = null
		return

	if(istype(W, /obj/item/stack/ore) && bucket_loaded == TRUE && fuel != 0) //ore and bucket loaded
		var/obj/item/stack/ore/current_ore = W
		var/smelting_result = W.on_smelt() //reagent id
		if(!smelting_result)
			return ..()

		while(crucible.reagents.total_volume != 100 && current_ore.amount != 0 && fuel != 0) //keep adding ore until you run out or fill the crucible
			to_chat(user, "The [W] melts.")
			crucible.reagents.add_reagent(smelting_result, (5)) //crucible.reagents.get_master_reagent() == smelting_result
			crucible.reagents.chem_temp = 1000
			crucible.reagents.handle_reactions()
			current_ore.amount--
			fuel--

		desc = "An old Sendarian tool. Fuel: ([fuel]/20)" //update

		if(current_ore.amount == 0)
			qdel(W)

/obj/machinery/anvil
	name = "anvil"
	desc = "Goodman Durnik, is that you?"
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "anvil"
	density = TRUE
	anchored = FALSE
	var/obj/item/reagent_containers/glass/mold/current_mold = null
	var/mutable_appearance/my_mold = null

/obj/machinery/anvil/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W, /obj/item/melee/smith_hammer))
		..()
	if(user.a_intent == INTENT_HARM)
		to_chat(user, "Be careful! You'll spill hot metal on the anvil with that intent!")
		return //spill that shit if it has reagents in it
	if(!current_mold && istype(W, /obj/item/reagent_containers/glass/mold))
		var/obj/item/reagent_containers/glass/mold/M = W
		var/datum/reagent/R = M.reagents.get_master_reagent()
		if(R && R.volume >= 25)
			if(R.name != "Iron" && R.name != "Adamantine" && R.name != "Silver" && R.name != "Gold" && R.name != "Uranium" && R.name != "Diamond" && R.name != "Plasma" && R.name != "Bananium" && R.name != "Titanium" )
				return //get out of here if its not ore tdogTrigger (stops things like water pickaxe heads and such)
			to_chat(user, "you place [M] on [src].")
			user.dropItemToGround(M)
			M.loc = src
			current_mold = M
			my_mold = mutable_appearance('russstation/icons/obj/blacksmithing.dmi', M.icon_state)
			add_overlay(my_mold)
			return
		if(R && R.volume)
			to_chat(user, "There's not enough in the mold to make a full cast!")
		else
			to_chat(name, "There's nothing in the mold!")
			return
	if(istype(W, /obj/item/melee/smith_hammer))
		if(current_mold)
			to_chat(user, "You break the result out of [current_mold] and start to hammer it into shape.")
			if(do_after(user, 80, target = src))
				new current_mold.type(get_turf(src))
				var/datum/reagent/R = current_mold.reagents.get_master_reagent()
				var/obj/item/I
				if(!istype(current_mold, /obj/item/reagent_containers/glass/mold/bar))
					I = new current_mold.produce_type(get_turf(src))
					I.smelted_material = new R.type()
					I.post_smithing()
				else
					for(var/i, i <= 4, i++) // makes five of whatever sheet of its type
						I = new R.produce_type(get_turf(src))
				qdel(current_mold)
				cut_overlay(my_mold)
				my_mold = null
				current_mold = null
				return
		else
			to_chat(user, "There's nothing in [current_mold]!")
			return

// Mold results, ie. shaped metal that still needs a handle attached
/obj/item/mold_result
	name = "molten blob"
	desc = "A hardened blob of ore. You shouldn't be seeing this..."
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "blob_base"
	w_class = WEIGHT_CLASS_NORMAL
	var/material_type = "unobtanium"
	var/mold_type = "blob"
	var/pickaxe_speed = 0
	var/metel_force = 0
	var/attack_amt = 0
	var/blunt_bonus = FALSE //determinse if the reagent used for the part has a bonus for blunt materials

/obj/item/mold_result/blade
	name = "blade"
	desc = "A blade made of "
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "sword_blade"
	mold_type = "offensive"

/obj/item/mold_result/pickaxe_head
	name = "pickaxe head"
	desc = "A pickaxe head made of "
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "pickaxe_head"
	mold_type = "digging"

/obj/item/mold_result/shovel_head
	name = "shovel head"
	desc = "A shovel head made of "
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "shovel_head"
	mold_type = "digging"

/obj/item/mold_result/knife_head
	name = "knife head"
	desc = "A butchering knife head made of "
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "knife_head"
	mold_type = "offensive"

/obj/item/mold_result/war_hammer_head
	name = "warhammer head"
	desc = "A warhammer head made of "
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "war_hammer_head"
	mold_type = "offensive"

/obj/item/mold_result/armour_plating
	name = "armour plating"
	desc = "Armour plating made of"
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "armour"
	mold_type = "offensive"

/obj/item/mold_result/helmet_plating
	name = "helmet plating"
	desc = "Helmet plating made of"
	icon = 'russstation/icons/obj/blacksmithing.dmi'
	icon_state = "helmet"
	mold_type = "offensive"

/obj/item/mold_result/post_smithing()
	name = "[smelted_material.name] [name]"
	material_type = "[smelted_material.name]"
	color = smelted_material.color
	armour_penetration = smelted_material.penetration_value
	attack_amt = smelted_material.attack_force
	force = smelted_material.attack_force * 0.6 //stabbing people with the resulting piece, build the full tool for full force
	desc += "[smelted_material.name]."
	if(smelted_material.sharp_result)
		sharpness = SHARP_EDGED
	if(mold_type == "digging")
		pickaxe_speed = smelted_material.pick_speed
		sharpness = SHARP_POINTY
	if(smelted_material.blunt_damage)
		blunt_bonus = TRUE
