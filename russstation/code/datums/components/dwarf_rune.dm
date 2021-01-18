#define RUNE_INEFFECTIVE_DROP_CHANCE 20

// Dwarf rune component- makes an item unusable by non-dwarves
/datum/component/dwarf_rune
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/enchanted = FALSE // after enchantment, non-dwarves can use this item

/datum/component/dwarf_rune/Initialize(obj/item/source)
	if(!isitem(source))
		return COMPONENT_INCOMPATIBLE

/datum/component/dwarf_rune/RegisterWithParent()
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/onAttackBy)
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ), .proc/onItemAttack)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/dwarf_rune/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ, COMSIG_PARENT_EXAMINE))

/datum/component/dwarf_rune/proc/onAttackBy(datum/source, obj/item/attacker, mob/user)
	SIGNAL_HANDLER

	// apply rune and expend it
	var/obj/item/dwarf_rune/rune = attacker
	if(!istype(rune))
		return
	if(rune.expended)
		to_chat(user, "<span class='notice'>You rub the [attacker] on [source] but nothing happens.</span>")
		return
	enchanted = TRUE
	rune.expend()

/datum/component/dwarf_rune/proc/onItemAttack(atom/source, mob/living/user)
	SIGNAL_HANDLER

	// only dwarves can use these effectively, unless enchanted
	if(!enchanted && !is_species(user, /datum/species/dwarf))
		to_chat(user, "<span class='notice'>You can't seem to wield the [src] effectively.</span>")
		if(prob(RUNE_INEFFECTIVE_DROP_CHANCE) && user.dropItemToGround(src))
			to_chat(user, "<span class='warning'>You fumble [src] and drop it!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/dwarf_rune/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(enchanted)
		examine_list += "<span class='notice'>It has a faint magical aura, and smells of beer.</span>"
