/obj/item/paper/evilfax
	name = "Centcomm Reply"
	var/mytarget = null
	var/myeffect = null
	var/used = FALSE
	var/countdown = 60
	var/activate_on_timeout = FALSE
	var/faxmachineid = null

/obj/item/paper/evilfax/ui_interact(mob/user, datum/tgui/ui)
	if(user == mytarget)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			evilpaper_specialaction(C)
			..()
		else
			// This should never happen, but just in case someone is adminbussing
			evilpaper_selfdestruct()
	else
		if(mytarget)
			to_chat(user,"<span class='notice'>This page appears to be covered in some sort of bizzare code. The only bit you recognize is the name of [mytarget]. Perhaps [mytarget] can make sense of it?</span>")
		else
			evilpaper_selfdestruct()


/obj/item/paper/evilfax/New()
	..()
	START_PROCESSING(SSobj, src)


/obj/item/paper/evilfax/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(mytarget && !used)
		var/mob/living/carbon/target = mytarget
		target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
	return ..()


/obj/item/paper/evilfax/process()
	if(!countdown)
		if(mytarget)
			if(activate_on_timeout)
				evilpaper_specialaction(mytarget)
			else
				message_admins("[mytarget] ignored an evil fax until it timed out.")
		else
			message_admins("Evil paper '[src]' timed out, after not being assigned a target.")
		used = TRUE
		evilpaper_selfdestruct()
	else
		countdown--

/obj/item/paper/evilfax/proc/evilpaper_specialaction(mob/living/carbon/target)
	spawn(30)
		if(iscarbon(target))
			var/obj/machinery/photocopier/faxmachine/fax = locate(faxmachineid)
			if(myeffect == "Borgification")
				to_chat(target,span_danger("You seem to comprehend the AI a little better. Why are your muscles so stiff?"))
				target.ForceContractDisease(new /datum/disease/transformation/robot(0))
			else if(myeffect == "Corgification")
				to_chat(target,"<span class='userdanger'>You hear distant howling as the world seems to grow bigger around you. Boy, that itch sure is getting worse!</span>")
				target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
			else if(myeffect == "Death By Fire")
				to_chat(target,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
				var/turf/T = get_turf(target)
				new /obj/effect/hotspot(T)
				target.adjustFireLoss(150) // hard crit, the burning takes care of the rest.
			else if(myeffect == "Total Brain Death")
				to_chat(target,"<span class='userdanger'>You see a message appear in front of you in bright red letters: <b>YHWH-3 ACTIVATED. TERMINATION IN 3 SECONDS</b></span>")
				ADD_TRAIT(target, TRAIT_BADDNA, "evil_fax")
				target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 125)
			else if(myeffect == "Cluwne")
				to_chat(target, "<span class='userdanger'>You feel surrounded by sadness. Sadness... and HONKS!</span>")
				target.change_mob_type(/mob/living/simple_animal/hostile/retaliate/clown/russ/goblin/lessergoblin, delete_old_mob = TRUE)
			else if(myeffect == "Demote")
				priority_announce("[target.real_name] is hereby demoted to the rank of Assistant. Process this demotion immediately. Failure to comply with these orders is grounds for termination.","CC Demotion Order")
				var/datum/data/record/record = find_record("name", target.real_name, GLOB.data_core.security)
				record.fields["criminal"] = "Incarcerated"
				record.fields["comments"] += "Central Command Demotion Order, given on [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
			else if(myeffect == "Demote with Bot")
				priority_announce("[target.real_name] is hereby demoted to the rank of Assistant. Process this demotion immediately. Failure to comply with these orders is grounds for termination.","CC Demotion Order")
				var/datum/data/record/record = find_record("name", target.real_name, GLOB.data_core.security)
				record.fields["criminal"] = "*Arrest*"
				record.fields["comments"] += "Central Command Demotion Order, given on [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				if(fax)
					var/turf/T = get_turf(fax)
					new /obj/effect/portal(T)
					new /mob/living/simple_animal/bot/secbot(T)
			else if(myeffect == "Revoke Fax Access")
				GLOB.fax_blacklist += target.real_name
				if(fax)
					fax.authenticated = 0
			else if(myeffect == "Angry Fax Machine")
				if(fax)
					fax.become_mimic()
			else
				message_admins("Evil paper [src] was activated without a proper effect set! This is a bug.")
		used = TRUE
		evilpaper_selfdestruct()

/obj/item/paper/evilfax/proc/evilpaper_selfdestruct()
	visible_message("<span class='danger'>[src] spontaneously catches fire, and burns up!</span>")
	qdel(src)
