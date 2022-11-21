GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command"))
GLOBAL_LIST_INIT(hidden_admin_departments, list("Syndicate"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(hidden_departments)
GLOBAL_LIST_EMPTY(fax_blacklist)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'russstation/icons/obj/library.dmi'
	icon_state = "fax"
	var/insert_anim = "faxsend"
	var/receive_anim = "faxreceive"
	pass_flags = PASSTABLE
	var/fax_network = "Local Fax Network"
	/// If true, prevents fax machine from sending messages to NT machines
	var/syndie_restricted = FALSE

	/// Can we send messages off-station?
	var/long_range_enabled = FALSE
	req_one_access = list(ACCESS_LAWYER, ACCESS_COMMAND, ACCESS_ARMORY)

	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200

	/// ID card inserted into the machine, used to log in with
	var/obj/item/card/id/scan = null

	/// Whether the machine is "logged in" or not
	var/authenticated = FALSE
	/// Next world.time at which this fax machine can send a message to CC/syndicate
	var/sendcooldown = 0
	/// After sending a message to CC/syndicate, cannot send another to them for this many deciseconds
	var/cooldown_time = 1800

	/// Our department, determines whether this machine gets faxes sent to a department
	var/department = "Unknown"

	/// Target department to send outgoing faxes to
	var/destination

/obj/machinery/photocopier/faxmachine/Initialize(mapload)
	. = ..()
	GLOB.allfaxes += src
	update_network()

/obj/machinery/photocopier/faxmachine/Destroy()
	GLOB.allfaxes -= src
	return ..()

/obj/machinery/photocopier/faxmachine/proc/update_network()
	if(department != "Unknown")
		if(!(("[department]" in GLOB.alldepartments) || ("[department]" in GLOB.hidden_departments) || ("[department]" in GLOB.admin_departments) || ("[department]" in GLOB.hidden_admin_departments)))
			GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/longrange
	name = "long range fax machine"
	fax_network = "Central Command Quantum Entanglement Network"
	long_range_enabled = TRUE

/obj/machinery/photocopier/faxmachine/longrange/Initialize(mapload)
	. = ..()
	add_overlay("longfax")

/obj/machinery/photocopier/faxmachine/longrange/syndie
	name = "syndicate long range fax machine"
	syndie_restricted = TRUE
	req_one_access = list(ACCESS_SYNDICATE)
	//No point setting fax network, being emagged overrides that anyway.

/obj/machinery/photocopier/faxmachine/longrange/syndie/Initialize(mapload)
	. = ..()
	obj_flags |= EMAGGED
	add_overlay("syndiefax")

/obj/machinery/photocopier/faxmachine/longrange/syndie/update_network()
	if(department != "Unknown")
		GLOB.hidden_departments |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attackby(obj/item/item, mob/user, params)
	if(istype(item,/obj/item/card/id) && !scan)
		scan(item)
	else if(istype(item, /obj/item/paper) || istype(item, /obj/item/photo))
		..()
		SStgui.update_uis(src)
	else if(istype(item, /obj/item/folder))
		to_chat(user, "<span class='warning'>The [src] can't accept folders!</span>")
		return //early return so the parent proc doesn't suck up and items that a photocopier would take
	else if(istype(item, /obj/item/documents))
		to_chat(user, span_warning("The [src] can't accept documents!"))
		return // ditto
	else
		return ..()

/obj/machinery/photocopier/faxmachine/MouseDrop_T()
	return //you should not be able to fax your ass without first copying it at an actual photocopier

/obj/machinery/photocopier/faxmachine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>You swipe the card through [src], but nothing happens.</span>")
	else
		obj_flags |= EMAGGED
		req_one_access = list()
		to_chat(user, "<span class='notice'>The transmitters realign to an unknown source!</span>")

/obj/machinery/photocopier/faxmachine/proc/is_authenticated(mob/user)
	if(authenticated || isAdminGhostAI(user))
		return TRUE
	return FALSE

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxMachine")
		ui.open()

/obj/machinery/photocopier/faxmachine/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = is_authenticated(user)
	data["realauth"] = authenticated
	data["scan_name"] = scan ? scan.name : FALSE
	data["nologin"] = !data["scan_name"] && !data["realauth"]
	if(!data["authenticated"])
		data["network"] = "Disconnected"
	else if(obj_flags & EMAGGED)
		data["network"] = "ERR*?*%!*"
	else
		data["network"] = fax_network
	var/obj/item/copyitem
	if(paper_copy)
		copyitem = paper_copy
	else if(photo_copy)
		copyitem = photo_copy
	data["paper"] = copyitem ? copyitem.name : FALSE
	data["paperinserted"] = copyitem ? TRUE : FALSE
	data["destination"] = destination ? destination : FALSE
	data["sendError"] = FALSE
	if(machine_stat & (BROKEN|NOPOWER))
		data["sendError"] = "No Power"
	else if(!data["authenticated"])
		data["sendError"] = "Not Logged In"
	else if(!data["paper"])
		data["sendError"] = "Nothing Inserted"
	else if(!data["destination"])
		data["sendError"] = "Destination Not Set"
	else if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments))
		var/cooldown_seconds = cooldown_seconds()
		if(cooldown_seconds)
			data["sendError"] = "Re-aligning in [cooldown_seconds] seconds..."
	return data


/obj/machinery/photocopier/faxmachine/ui_act(action, params)
	if(isnull(..())) // isnull(..()) here because the parent photocopier proc returns null as opposed to TRUE if the ui should not be interacted with.
		return
	var/is_authenticated = is_authenticated(usr)
	. = TRUE
	switch(action)
		if("scan") // insert/remove your ID card
			scan()
		if("auth") // log in/out
			if(!is_authenticated && scan)
				if(scan.registered_name in GLOB.fax_blacklist)
					to_chat(usr, "<span class='warning'>Login rejected: individual is blacklisted from fax network.</span>")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					. = FALSE
				else if(check_access(scan))
					authenticated = TRUE
				else // ID doesn't have access to this machine
					to_chat(usr, "<span class='warning'>Login rejected: ID card does not have required access.</span>")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					. = FALSE
			else if(is_authenticated)
				authenticated = FALSE
		if("paper") // insert/eject paper/photo
			var/obj/item/copyitem
			if(paper_copy)
				copyitem = paper_copy
			else if(photo_copy)
				copyitem = photo_copy
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				if(ishuman(usr))
					if(!usr.get_active_hand() && Adjacent(usr))
						usr.put_in_hands(copyitem)
				to_chat(usr, "<span class='notice'>You eject [copyitem] from [src].</span>")
				paper_copy = null
				photo_copy = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo))
					usr.transferItemToLoc(I, src)
					if(istype(I, /obj/item/paper))
						paper_copy = I
					else if(istype(I, /obj/item/photo))
						photo_copy = I
					to_chat(usr, "<span class='notice'>You insert [I] into [src].</span>")
					flick(insert_anim, src)
				else
					to_chat(usr, "<span class='warning'>[src] only accepts paper and photos.</span>")
					. = FALSE
		if("rename") // rename the item that is currently in the fax machine
			if(paper_copy)
				var/n_name = sanitize(copytext(input(usr, "What would you like to label the fax?", "Fax Labelling", paper_copy.name) as text, 1, MAX_MESSAGE_LEN))
				paper_copy.name = "[(n_name ? text("[n_name]") : initial(paper_copy.name))]"
				paper_copy.desc = "This is a paper titled '" + paper_copy.name + "'."
			else if(photo_copy)
				var/n_name = sanitize(copytext(input(usr, "What would you like to label the fax?", "Fax Labelling", photo_copy.name) as text, 1, MAX_MESSAGE_LEN))
				photo_copy.name = "[(n_name ? text("[n_name]") : "photo")]"
			else
				. = FALSE
		if("dept") // choose which department receives the fax
			if(is_authenticated)
				var/lastdestination = destination
				var/list/combineddepartments = GLOB.alldepartments.Copy()
				if(long_range_enabled)
					combineddepartments += GLOB.admin_departments.Copy()
				if(obj_flags & EMAGGED)
					combineddepartments += GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
				if(syndie_restricted)
					combineddepartments = GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
					for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
						if(F.obj_flags & EMAGGED)//we can contact emagged faxes on the station
							combineddepartments |= F.department
				destination = input(usr, "To which department?", "Choose a department", "") as null|anything in combineddepartments
				if(!destination)
					destination = lastdestination
		if("send") // actually send the fax
			if(!(paper_copy || photo_copy) || !is_authenticated || !destination)
				return
			if(machine_stat & (BROKEN|NOPOWER))
				return
			if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments))
				var/cooldown_seconds = cooldown_seconds()
				if(cooldown_seconds > 0)
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					to_chat(usr, "<span class='warning'>[src] is not ready for another [cooldown_seconds] seconds.</span>")
					return
				send_admin_fax(usr, destination)
				sendcooldown = world.time + cooldown_time
			else
				sendfax(destination, usr)
	if(.)
		add_fingerprint(usr)

/obj/machinery/photocopier/faxmachine/proc/scan(obj/item/card/id/card = null)
	if(scan) // Card is in machine
		if(ishuman(usr))
			scan.forceMove(get_turf(src))
			if(!usr.get_active_hand() && Adjacent(usr))
				usr.put_in_hands(scan)
			scan = null
		else
			scan.forceMove(get_turf(src))
			scan = null
	else if(Adjacent(usr))
		if(!card)
			var/obj/item/I = usr.get_active_hand()
			if(istype(I, /obj/item/card/id))
				usr.dropItemToGround(I)
				I.forceMove(src)
				scan = I
		else if(istype(card))
			usr.dropItemToGround(card)
			card.forceMove(src)
			scan = card
	SStgui.update_uis(src)

/obj/machinery/photocopier/faxmachine/verb/eject_id()
	set category = null
	set name = "Eject ID Card"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(scan)
		to_chat(usr, "You remove [scan] from [src].")
		scan.forceMove(get_turf(src))
		if(!usr.get_active_hand() && Adjacent(usr))
			usr.put_in_hands(scan)
		scan = null
	else
		to_chat(usr, "There is nothing to remove from [src].")

/obj/machinery/photocopier/faxmachine/proc/sendfax(destination, mob/sender)
	use_power(active_power_usage)
	var/success = 0
	var/obj/item/copyitem
	if(paper_copy)
		copyitem = paper_copy
	else if(photo_copy)
		copyitem = photo_copy
	else
		visible_message("[src] beeps, \"Invalid fax item.\"")
		return

	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			success = F.receivefax(copyitem)
	if(success)
		var/datum/fax/F = new /datum/fax()
		F.name = copyitem.name
		F.from_department = department
		F.to_department = destination
		F.origin = src
		F.message = copyitem
		F.sent_by = sender
		F.sent_at = world.time

		visible_message("[src] beeps, \"Message transmitted successfully.\"")
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/receivefax(obj/item/incoming)
	if(machine_stat & (BROKEN|NOPOWER))
		return FALSE

	if(department == "Unknown")
		return FALSE //You can't send faxes to "Unknown"

	flick(receive_anim, src)

	playsound(loc, 'russstation/sound/machines/dotmatrix.ogg', 50, 1)
	addtimer(CALLBACK(src, .proc/print_fax, incoming), 2 SECONDS)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/print_fax(obj/item/incoming)
	if(istype(incoming, /obj/item/paper))
		make_paper_copy(incoming)
	else if(istype(incoming, /obj/item/photo))
		make_photo_copy(incoming)
	else
		return

	use_power(active_power_usage)

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(mob/sender, destination)
	use_power(active_power_usage)

	var/obj/item/copyitem
	if(paper_copy)
		copyitem = paper_copy
	else if(photo_copy)
		copyitem = photo_copy
	else
		visible_message("[src] beeps, \"Invalid fax item.\"")
		return

	var/datum/fax/admin/A = new /datum/fax/admin()
	A.name = copyitem.name
	A.from_department = department
	A.to_department = destination
	A.origin = src
	A.message = copyitem
	A.sent_by = sender
	A.sent_at = world.time

	//message badmins that a fax has arrived
	switch(destination)
		if("Central Command")
			message_admins(sender, "CENTCOM FAX", destination, copyitem, "#006100")
		if("Syndicate")
			message_admins(sender, "SYNDICATE FAX", destination, copyitem, "#DC143C")
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			F.receivefax(copyitem)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")

/obj/machinery/photocopier/faxmachine/proc/cooldown_seconds()
	if(sendcooldown < world.time)
		return 0
	return round((sendcooldown - world.time) / 10)

/obj/machinery/photocopier/faxmachine/proc/message_admins(mob/sender, faxname, faxtype, obj/item/sent, font_colour="#9A04D1")
	var/msg = "<span class='boldnotice'><font color='[font_colour]'>[faxname]: </font> [key_name_admin(sender)] | REPLY: (<A HREF='?_src_=holder;[faxname == "SYNDICATE FAX" ? "SyndicateReply" : "CentcommReply"]=[ref(sender)]'>RADIO</A>) (<a href='?_src_=holder;AdminFaxCreate=\ref[sender];originfax=\ref[src];faxtype=[faxtype];replyto=\ref[sent]'>FAX</a>) ([ADMIN_SM(sender)]) | REJECT: (<A HREF='?_src_=holder;FaxReplyTemplate=[ref(sender)];originfax=\ref[src]'>TEMPLATE</A>) (<A HREF='?_src_=holder;EvilFax=[ref(sender)];originfax=\ref[src]'>EVILFAX</A>) </span>: Receiving '[sent.name]' via secure connection... <a href='?_src_=holder;AdminFaxView=\ref[sent]'>view message</a>"
	var/fax_sound = sound('sound/effects/adminhelp.ogg')
	for(var/client/C in GLOB.admins)
		if(check_rights_for(C, R_ADMIN)) // ? checked nonexistant R_EVENT
			to_chat(C, msg)
			if(C.prefs.toggles & SOUND_ADMINHELP)
				SEND_SOUND(C, fax_sound)

/obj/machinery/photocopier/faxmachine/proc/become_mimic()
	if(scan)
		scan.forceMove(get_turf(src))
	var/mob/living/simple_animal/hostile/mimic/copy/M = new(loc, src, null, 1) // it will delete src on creation and override any machine checks
	M.name = "angry fax machine"
