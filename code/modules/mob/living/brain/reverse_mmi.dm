/datum/action/innate/brain_undeployment
	name = "Disconnect from shell"
	desc = "Stop controlling your shell and resume normal core operations."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/brain_undeployment/Trigger(/mob/owner, trigger_flags)
	if(!..())
		return FALSE
	var/obj/item/organ/internal/brain/cybernetic/ai/shell_to_disconnect = owner.get_organ_by_type(/obj/item/organ/internal/brain/cybernetic/ai)

	shell_to_disconnect.undeploy()
	return TRUE

/obj/item/organ/internal/brain/cybernetic/ai
	name = "AI-uplink brain"
	desc = "Can be inserted into a body with NO ORGANIC INTERNAL ORGANS (robotic organs only) to allow AIs to control it. Comes with its own health sensors beacon. MUST be a humanoid or bad things happen to the consciousness."
<<<<<<< HEAD
	/// The AI that owns this brain/shell.
	var/mob/living/silicon/ai/mainframe_ai
	/// Is the AI owner currently deployed/connected to this brain/shell.
=======
	/// The AI that owns this brain/shell. Once owned, this disallows other AIs from deploying into it.
	var/mob/living/silicon/ai/mainframe_ai
	/// Is the mainframe AI currently deployed to this brain/shell?
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
	var/deployed = FALSE
	/// The action for undeployment.
	var/datum/action/innate/brain_undeployment/undeployment_action = new
	/// A weakref to our imaginary brain radio implant.
	var/datum/weakref/radio_weakref


/obj/item/organ/internal/brain/cybernetic/ai/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "eyes move with machine precision.", BODY_ZONE_PRECISE_EYES)

/obj/item/organ/internal/brain/cybernetic/ai/Destroy()
<<<<<<< HEAD
	. = ..()
	QDEL_NULL(undeployment_action)

/obj/item/organ/internal/brain/cybernetic/ai/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	if(is_sufficiently_augmented())
		GLOB.available_ai_shells |= organ_owner
	organ_owner.add_traits(list(TRAIT_MEDICAL_HUD, TRAIT_NO_MINDSWAP, TRAIT_CORPSELOCKED), REF(src))
	update_med_hud_status(organ_owner)
	RegisterSignal(organ_owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_med_hud_status))
	RegisterSignal(organ_owner, COMSIG_CLICK, PROC_REF(owner_clicked))
	RegisterSignal(organ_owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	RegisterSignals(organ_owner, list(COMSIG_QDELETING, COMSIG_LIVING_PRE_WABBAJACKED), PROC_REF(undeploy))
	RegisterSignal(organ_owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_organ_gain))
	if(organ_owner.ai_controller) // If the owner is a monkey, delete its AI.
		QDEL_NULL(organ_owner.ai_controller)
=======
	if(mainframe_ai)
		mainframe_ai.connected_ipcs -= owner
	GLOB.available_ai_shells -= owner
	. = ..()
	undeploy()
	mainframe_ai = null
	QDEL_NULL(undeployment_action)

/obj/item/organ/internal/brain/cybernetic/ai/on_insert(mob/living/carbon/carb_owner, special, movement_flags)
	. = ..()
	carb_owner.add_traits(list(TRAIT_MEDICAL_HUD, TRAIT_NO_MINDSWAP, TRAIT_CORPSELOCKED), REF(src))
	update_med_hud_status(carb_owner)
	RegisterSignal(carb_owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_med_hud_status))
	RegisterSignal(carb_owner, COMSIG_CLICK, PROC_REF(owner_clicked))
	RegisterSignal(carb_owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	RegisterSignals(carb_owner, list(COMSIG_QDELETING, COMSIG_LIVING_PRE_WABBAJACKED), PROC_REF(undeploy))
	RegisterSignals(carb_owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN), PROC_REF(on_organ_gain))
	if(carb_owner.ai_controller) // If the owner is a monkey, delete its AI
		QDEL_NULL(carb_owner.ai_controller)
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
	var/obj/item/implant/radio/radio = new(owner)
	radio.implant(owner, null, TRUE, TRUE)
	radio_weakref = WEAKREF(radio)
	RegisterSignal(radio, COMSIG_IMPLANT_REMOVED, PROC_REF(implant_loss))
<<<<<<< HEAD

/obj/item/organ/internal/brain/cybernetic/ai/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(mainframe_ai)
		mainframe_ai.connected_ipcs -= organ_owner
		mainframe_ai = null
	if(deployed)
		undeploy()
	GLOB.available_ai_shells -= organ_owner
	organ_owner.remove_traits(list(TRAIT_MEDICAL_HUD, TRAIT_NO_MINDSWAP, TRAIT_CORPSELOCKED), REF(src))
	UnregisterSignal(organ_owner, list(COMSIG_LIVING_HEALTH_UPDATE, COMSIG_CLICK, COMSIG_MOB_GET_STATUS_TAB_ITEMS, COMSIG_QDELETING, COMSIG_LIVING_PRE_WABBAJACKED, COMSIG_CARBON_GAIN_ORGAN))
=======
	if(check_if_augmented())
		GLOB.available_ai_shells |= carb_owner

/obj/item/organ/internal/brain/cybernetic/ai/Remove(mob/living/carbon/carb_owner, special, movement_flags)
	if(mainframe_ai)
		mainframe_ai.connected_ipcs -= owner
	GLOB.available_ai_shells -= owner
	undeploy()
	mainframe_ai = null
	. = ..()
	carb_owner.remove_traits(list(TRAIT_MEDICAL_HUD, TRAIT_NO_MINDSWAP, TRAIT_CORPSELOCKED), REF(src))
	UnregisterSignal(carb_owner, list(COMSIG_LIVING_HEALTH_UPDATE, COMSIG_CLICK, COMSIG_MOB_GET_STATUS_TAB_ITEMS, COMSIG_QDELETING, COMSIG_LIVING_PRE_WABBAJACKED))
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
	var/obj/item/implant/radio/radio = radio_weakref.resolve()
	if(radio)
		QDEL_NULL(radio)

// No thoughts. Only wifi.
/obj/item/organ/internal/brain/cybernetic/ai/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	return FALSE

/// Adds the the connected AI's statpanel.
/obj/item/organ/internal/brain/cybernetic/ai/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	if(!mainframe_ai)
		return
	items += mainframe_ai.get_status_tab_items()

/// Updates the shell's vital status on medical HUD.
/obj/item/organ/internal/brain/cybernetic/ai/proc/update_med_hud_status(mob/living/mob_parent)
	SIGNAL_HANDLER
	var/image/holder = mob_parent.active_hud_list?[STATUS_HUD]
	if(isnull(holder))
		return
	var/icon/size_check = icon(mob_parent.icon, mob_parent.icon_state, mob_parent.dir)
	holder.pixel_y = size_check.Height() - ICON_SIZE_Y
	if(IS_DEAD_OR_INCAP(mob_parent) || isnull(mainframe_ai))
		holder.icon_state = "huddead2"
		holder.pixel_x = -8 // New icon states? Nuh uh.
		return
	holder.icon_state = "hudtrackingai"
	holder.pixel_x = -16

<<<<<<< HEAD
=======
// no thoughts only wifi
/obj/item/organ/internal/brain/cybernetic/ai/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	return FALSE

>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
/// Shows the status description to any AI that clicks on the shell.
/obj/item/organ/internal/brain/cybernetic/ai/proc/owner_clicked(datum/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER
	if(!isAI(user))
		return
	var/list/lines = list()
	lines += span_bold("[owner]")
	lines += "Target is currently [!HAS_TRAIT(owner, TRAIT_INCAPACITATED) ? "functional" : "incapacitated"]."
	lines += "Estimated organic/inorganic integrity: [owner.health]"
<<<<<<< HEAD
	if(mainframe_ai != user)
		if(deployed)
			lines += span_warning("Already occupied by another digital entity.")
		else
			lines += span_warning("Uplink is locked by another digital entity.")
	else if(!is_sufficiently_augmented())
=======
	if(mainframe_ai && deployed)
		lines += span_warning("Already occupied by another digital entity.")
	else if(mainframe_ai && mainframe_ai != user)
		lines += span_warning("Uplink is locked by another digital entity.")
	else if(!check_if_augmented())
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
		lines += span_warning("Organic organs detected. Robotic organs only, cannot take over.")
	else
		lines += "<a href='byond://?src=[REF(src)];ai_take_control=[REF(user)]'>[span_boldnotice("Take control?")]</a><br>"
	to_chat(user, boxed_message(jointext(lines, "\n")), type = MESSAGE_TYPE_INFO)

/obj/item/organ/internal/brain/cybernetic/ai/Topic(href, href_list)
<<<<<<< HEAD
	. = ..()
	if(. || !href_list["ai_take_control"])
=======
	..()
	if(!href_list["ai_take_control"] || !check_if_augmented() || deployed)
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
		return
	var/mob/living/silicon/ai/prospective_ai = locate(href_list["ai_take_control"]) in GLOB.silicon_mobs
	if(isnull(prospective_ai))
		return
	if(mainframe_ai && mainframe_ai != prospective_ai) // This shell already belongs to an AI.
		return
	if(prospective_ai.controlled_equipment)
		to_chat(prospective_ai, span_warning("You are already loaded into an onboard computer!"))
		return
	if(!SScameras.is_visible_by_cameras(owner))
		to_chat(prospective_ai, span_warning("Target is no longer near active cameras."))
		return
	deploy(prospective_ai)

<<<<<<< HEAD
/// Deploys the AI into this shell.
/obj/item/organ/internal/brain/cybernetic/ai/proc/deploy(mob/living/silicon/ai/deploying_ai)
	mainframe = deploying_ai
	mainframe.deployed_shell = owner
	mainframe.mind.transfer_to(owner)
	mainframe = AI
	connected_ai = AI
	last_connected_ai = AI
	mainframe.connected_ipcs |= owner
=======
	AI.deployed_shell = owner
	deploy_init(AI)

/**
 * deploy_init: Deploys AI unit into AI shell
 *
 * Arguments:
 * * AI - AI unit that initiated the deployment into the AI shell
 */
/obj/item/organ/internal/brain/cybernetic/ai/proc/deploy_init(mob/living/silicon/ai/AI)
	mainframe_ai = AI
	mainframe_ai.connected_ipcs |= owner
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(undeploy))
	RegisterSignal(AI, COMSIG_QDELETING, PROC_REF(ai_deleted))
	undeployment_action.Grant(owner)
	update_med_hud_status(owner)

	owner.add_traits(list(TRAIT_SILICON_ACCESS), REF(src))
	ADD_TRAIT(mainframe_ai.mind, TRAIT_UNCONVERTABLE, REF(src))
	ADD_TRAIT(mainframe_ai, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	AI.mind.transfer_to(owner)
	deployed = TRUE
	to_chat(owner, span_boldbig("You are still considered a silicon/cyborg/AI. Follow your laws."))

	var/obj/item/implant/radio/implant = radio_weakref.resolve()
	if(!implant?.radio || !AI.radio)
		return
	if(AI.radio.syndie) /// AI has Syndie radio if traitor.
		AI.radio.make_syndie()
	implant.radio.subspace_transmission = TRUE
	implant.radio.command = TRUE
	implant.radio.channels = AI.radio.channels
	for(var/channel in implant.radio.channels)
		LAZYSET(implant.radio.secure_radio_connections, channel, add_radio(implant.radio, GLOB.radiochannels[channel]))

/// Handles exiting the shell.
/obj/item/organ/internal/brain/cybernetic/ai/proc/undeploy(datum/source)
	SIGNAL_HANDLER
	if(!owner?.mind || !mainframe_ai)
		return
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	UnregisterSignal(mainframe_ai, COMSIG_QDELETING)
	var/last_loc = owner.loc
	mainframe_ai.redeploy_action.Grant(mainframe_ai)
	mainframe_ai.redeploy_action.last_used_shell = owner
	owner.mind.transfer_to(mainframe_ai)
	deployed = FALSE
	mainframe_ai.deployed_shell = null
	undeployment_action.Remove(owner)
	if(mainframe_ai.laws)
		mainframe_ai.laws.show_laws(mainframe_ai)
	if(mainframe_ai.eyeobj)
		mainframe_ai.eyeobj.setLoc(last_loc)
		last_loc = null
	REMOVE_TRAIT(mainframe_ai.mind, TRAIT_UNCONVERTABLE, REF(src))
	REMOVE_TRAIT(mainframe_ai, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	owner.remove_traits(list(TRAIT_SILICON_ACCESS), REF(src)) // we don't want randoms using our body as free AA, so we only have it when we active.
	var/obj/item/implant/radio/implant = radio_weakref.resolve()
	if(implant)
		implant.radio.resetChannels()
	get_status_tab_item()
	update_med_hud_status(owner)

<<<<<<< HEAD

/// Checks if the owner is sufficiently augmented with robotic organs.
/obj/item/organ/brain/cybernetic/ai/proc/is_sufficiently_augmented()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/organ/organ as anything in carbon_owner.organs)
		if(istype(organ, /obj/item/organ/external))
			continue
		if(!IS_ROBOTIC_ORGAN(organ) && !istype(organ, /obj/item/organ/internal/tongue)) // Tongues are not in the exosuit fab and nobody is going to bother to find them so...
			return FALSE
	return TRUE

/* Is called if the radio implant is removed or deleted after brain insertion.
=======
/** Checks if the owner's organs are fully robotic.
*
*If they are, returns TRUE and sets 'is_shell to TRUE'.
*If not, returns FALSE and sets 'is_shell' to FALSE.
**/
/obj/item/organ/internal/brain/cybernetic/ai/proc/check_if_augmented()
	var/mob/living/carbon/carb_owner = owner
	. = TRUE
	if(!istype(carb_owner))
		return FALSE
	for(var/obj/item/organ/organ as anything in carb_owner.organs)
		if(organ.organ_flags && istype(organ, /obj/item/organ/external))
			continue
		if(!IS_ROBOTIC_ORGAN(organ) && !istype(organ, /obj/item/organ/internal/tongue)) //tongues are not in the exosuit fab and nobody is going to bother to find them so
			return FALSE

/** Is called if the radio implant is removed or deleted after brain insertion.
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
*
* If it is deleted, return.
* If it is removed from owner, wait until it is in an implantcase.
**/
/obj/item/organ/internal/brain/cybernetic/ai/proc/implant_loss(datum/source)
// To handle deleting properly, we need to wait until implant is cased, so we will set RegisterSignal
	SIGNAL_HANDLER
	if(!owner) // If the brain & body is gone, return
		return
	var/obj/item/implant/radio/implant = radio_weakref.resolve()
	if(!radio_weakref) // if it is already deleted
		return
	UnregisterSignal(implant, COMSIG_IMPLANT_REMOVED)
	if(implant in owner.implants)
		return
	RegisterSignal(implant, COMSIG_IMPLANT_CASED, PROC_REF(qdel_implant)) // If it is not being deleted, it will register until implant is moved to an implant case.

/// When the implant case is dropped, creates spark effects & deletes it.
/obj/item/organ/internal/brain/cybernetic/ai/proc/qdel_implant(datum/source, silent = FALSE, special = 0)
	SIGNAL_HANDLER
	var/obj/item/implant/radio/implant = source
	var/obj/item/implantcase/implantcase = implant.loc
	if(implantcase)
		to_chat(owner, span_hear("You feel a tiny jolt from inside of you as your internal radio is removed."))
		implantcase.visible_message(span_warning("[implantcase] bursts into sparks!"))
		do_sparks(number = 2, cardinal_only = FALSE, source = owner)
		qdel(implantcase)
	UnregisterSignal(radio_weakref, COMSIG_IMPLANT_CASED)

<<<<<<< HEAD
/// Called when any organs are added to our shell.
/obj/item/organ/internal/brain/cybernetic/ai/proc/on_organ_gain(datum/source, obj/item/organ/inserted_organ, special)
	SIGNAL_HANDLER
	if(is_sufficiently_augmented())
		GLOB.available_ai_shells |= owner
		return
	if(connected_ai)
=======
/// Is called when any organs are added & removed after uplink is inserted
/obj/item/organ/internal/brain/cybernetic/ai/proc/on_organ_gain(datum/source, obj/item/organ/inserted_organ, special)
	SIGNAL_HANDLER
	if(check_if_augmented())
		GLOB.available_ai_shells |= owner
		return
	GLOB.available_ai_shells -= owner
	if(mainframe_ai)
>>>>>>> 8e6207ebeb1664548b6a64deabce2fa8e56db20a
		to_chat(owner, span_danger("Connection failure. Organic organs detected."))
		undeploy()
	GLOB.available_ai_shells -= owner

/// Called when connected AI's original body dies or gets deleted.
/obj/item/organ/internal/brain/cybernetic/ai/proc/ai_killed_or_deleted(datum/source)
	SIGNAL_HANDLER
	to_chat(owner, span_danger("Your core has been rendered inoperable..."))
	undeploy()
