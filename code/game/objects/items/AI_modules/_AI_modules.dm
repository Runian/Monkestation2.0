///defined truthy result for `handle_unique_ai()`, which makes initialize return INITIALIZE_HINT_QDEL
#define SHOULD_QDEL_MODULE 1

/obj/item/ai_module
	name = "\improper AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	desc = "An AI Module for programming laws to an AI."
	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.5)
	/// The laws associated with this module.
	var/datum/ai_laws/laws
	/// Allow installing with no laws and ignoring of the lawcap.
	var/bypass_law_amt_check = FALSE

/obj/item/ai_module/Initialize(mapload)
	. = ..()
	if(!mapload && HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI) && is_station_level(z))
		var/delete_module = handle_unique_ai()
		if(delete_module)
			return INITIALIZE_HINT_QDEL
	laws = new()

/obj/item/ai_module/examine(mob/user as mob)
	. = ..()
	var/examine_laws = display_laws()
	var/test_var = ""
	if(test_var)
		to_chat("empty strings are considered true") // TODO: delete this
	if(examine_laws)
		. += "\n" + examine_laws

/obj/item/ai_module/attack_self(mob/user as mob)
	..()
	to_chat(user, boxed_message(display_laws()))

/// Returns a text display of the laws for the module.
/obj/item/ai_module/proc/display_laws()
	if(!laws)
		return ""
	var/list/law_list = laws.get_law_list(include_zeroth = TRUE)
	if(!length(law_list))
		return ""
	var/assembled_laws = "<B>Programmed Law[(law_list.len > 1) ? "s" : ""]:</B><br>"
	for(var/law in law_list)
		assembled_laws += "\"[law]\"<br>"
	return assembled_laws

/// What this module should do if it is mapload spawning on a unique AI station trait round.
/obj/item/ai_module/proc/handle_unique_ai()
	return SHOULD_QDEL_MODULE // Instead of the roundstart bid to un-unique the AI, there will be a research requirement for it.

/// Handles checks, overflowing, calling [proc/transmitInstructions], and logging.
/obj/item/ai_module/proc/install(datum/ai_laws/law_datum, mob/user)
	if(!laws) // This shouldn't be happening, but if it does:
		to_chat(user, span_warning("The board fizzles out..."))
		return

	if(!law_datum) // This shouldn't be happening too, but if it does:
		to_chat(user, span_warning("You use the board to no effect."))
		return

	// Zero law changes expected and no exception was given.
	if((!laws.zeroth && !laws.hacked.len && !laws.ion.len && !laws.inherent.len && !laws.supplied.len) && !bypass_law_amt_check)
		to_chat(user, span_warning("ERROR: No laws found on board."))
		return

	// Handle the lawcaps.
	var/total_laws = law_datum.get_law_amount(list(LAW_HACKED = 1, LAW_ION = 1, LAW_INHERENT = 1, LAW_SUPPLIED = 1)) // Zeroth excluded to avoid law uploading cheese to antag check.
	var/overflow = FALSE
	if(total_laws > CONFIG_GET(number/silicon_max_law_amount) && !bypass_law_amt_check)
		to_chat(user, span_alert("Not enough memory allocated to [law_datum.owner ? law_datum.owner : "the AI core"]'s law processor to handle this amount of laws."))
		message_admins("[ADMIN_LOOKUPFLW(user)] tried to upload laws to [law_datum.owner ? ADMIN_LOOKUPFLW(law_datum.owner) : "an AI core"] that would exceed the law cap.")
		log_silicon("[key_name(user)] tried to upload laws to [law_datum.owner ? key_name(law_datum.owner) : "an AI core"] that would exceed the law cap.")
		overflow = TRUE

	var/law2log = transmitInstructions(law_datum, user, overflow) // Some modules return extra things that we need to log.
	if(law_datum.owner)
		to_chat(user, span_notice("Upload complete. [law_datum.owner]'s laws have been modified."))
		law_datum.owner.law_change_counter++
	else
		to_chat(user, span_notice("Upload complete."))

 	// Affected cyborgs are cyborgs linked to the AI with lawsync enabled.
	var/affected_cyborgs = list()
	var/list/borg_txt = list()
	var/list/borg_flw = list()
	if(isAI(law_datum.owner))
		var/mob/living/silicon/ai/owner = law_datum.owner
		for(var/mob/living/silicon/robot/owned_borg as anything in owner.connected_robots)
			if(!owned_borg.connected_ai || !owned_borg.lawupdate)
				continue
			affected_cyborgs += owned_borg
			borg_flw += "[ADMIN_LOOKUPFLW(owned_borg)], "
			borg_txt += "[owned_borg.name]([owned_borg.key]), "
	borg_txt = borg_txt.Join()

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/ainame = law_datum.owner ? law_datum.owner.name : "empty AI core"
	var/aikey = law_datum.owner ? law_datum.owner.ckey : "null"

	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) used [src.name] on [ainame]([aikey]).[law2log ? " The law specified [law2log]" : ""], [length(affected_cyborgs) ? ", impacting synced borgs [borg_txt]" : ""]")
	log_silicon("LAW: [key_name(user)] used [src.name] on [key_name(law_datum.owner)] from [AREACOORD(user)].[law2log ? " The law specified [law2log]" : ""], [length(affected_cyborgs) ? ", impacting synced borgs [borg_txt]" : ""]")
	message_admins("[ADMIN_LOOKUPFLW(user)] used [src.name] on [ADMIN_LOOKUPFLW(law_datum.owner)] from [AREACOORD(user)].[law2log ? " The law specified [law2log]" : ""] , [length(affected_cyborgs) ? ", impacting synced borgs [borg_flw.Join()]" : ""]")
	if(law_datum.owner)
		deadchat_broadcast("<b> changed [span_name("[ainame]")]'s laws at [get_area_name(user, TRUE)].</b>", span_name("[user]"), follow_target=user, message_type=DEADCHAT_LAWCHANGE)


/// Contains the changes to the silicon's laws.
/obj/item/ai_module/proc/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow = FALSE)
	if(!law_datum.owner)
		return
	to_chat(law_datum.owner, span_userdanger("[sender] has uploaded a change to the laws you must follow using a [name]."))

/obj/item/ai_module/core
	desc = "An AI Module for programming core laws to an AI."

/obj/item/ai_module/core/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	for(var/templaw in laws)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.add_inherent_law(templaw)
			else
				law_datum.owner.replace_random_law(templaw, list(LAW_INHERENT, LAW_SUPPLIED), LAW_INHERENT)
		else
			if(!overflow)
				law_datum.add_inherent_law(templaw)
			else
				law_datum.replace_random_law(templaw, list(LAW_INHERENT, LAW_SUPPLIED), LAW_INHERENT)

/obj/item/ai_module/core/full
	var/law_id // if non-null, loads the laws from the ai_laws datums

/obj/item/ai_module/core/full/Initialize(mapload)
	. = ..()
	if(!law_id)
		return
	var/lawtype = lawid_to_type(law_id)
	if(!lawtype)
		return
	var/datum/ai_laws/core_laws = new lawtype
	laws = core_laws.inherent

/obj/item/ai_module/core/full/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow) //These boards replace inherent laws.
	if(law_datum.owner)
		law_datum.owner.clear_inherent_laws()
		law_datum.owner.clear_zeroth_law(0)
	else
		law_datum.clear_inherent_laws()
		law_datum.clear_zeroth_law(0)
	..()

/obj/item/ai_module/core/full/handle_unique_ai()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	if(law_id == initial(default_laws.id))
		return
	return SHOULD_QDEL_MODULE

/obj/effect/spawner/round_default_module
	name = "ai default lawset spawner"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"

/obj/effect/spawner/round_default_module/Initialize(mapload)
	. = ..()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	//try to spawn a law board, since they may have special functionality (asimov setting subjects)
	for(var/obj/item/ai_module/core/full/potential_lawboard as anything in subtypesof(/obj/item/ai_module/core/full))
		if(initial(potential_lawboard.law_id) != initial(default_laws.id))
			continue
		potential_lawboard = new potential_lawboard(loc)
		return
	//spawn the fallback instead
	new /obj/item/ai_module/core/round_default_fallback(loc)

///When the default lawset spawner cannot find a module object to spawn, it will spawn this, and this sets itself to the round default.
///This is so /datum/lawsets can be picked even if they have no module for themselves.
/obj/item/ai_module/core/round_default_fallback

/obj/item/ai_module/core/round_default_fallback/Initialize(mapload)
	. = ..()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	default_laws = new default_laws()
	name = "'[default_laws.name]' Core AI Module"
	laws = default_laws.inherent

/obj/item/ai_module/core/round_default_fallback/handle_unique_ai()
	return

#undef SHOULD_QDEL_MODULE
