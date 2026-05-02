/// Initializes their lawset if it hasn't already been done already.
/mob/living/silicon/proc/laws_sanity_check()
	if(!laws)
		make_laws()
	return TRUE

/// Gives them the default set of laws.
/mob/living/silicon/proc/make_laws()
	laws = new /datum/ai_laws
	laws.set_laws_config()
	laws.associate(src)

/// Attempts to law sync.
/mob/living/silicon/proc/try_sync_laws()
	return

/// Sends a chat message containing information about their laws.
/mob/living/silicon/proc/show_laws()
	laws_sanity_check()
	var/list/law_box = list(span_bold("Obey these laws:"))
	law_box += laws.get_law_list(include_zeroth = TRUE)
	to_chat(src, boxed_message(jointext(law_box, "\n")))

/// Logs information about this silicon's lawset.
/mob/living/silicon/proc/log_current_laws()
	var/list/the_laws = laws.get_law_list(include_zeroth = TRUE)
	var/lawtext = the_laws.Join(" ")
	log_silicon("LAW: [key_name(src)] spawned with [lawtext]")

/// Notifies dead chat that this silicon's lawset has been changed.
/mob/living/silicon/proc/deadchat_lawchange()
	var/list/the_laws = laws.get_law_list(include_zeroth = TRUE)
	var/lawtext = the_laws.Join("<br/>")
	deadchat_broadcast("'s <b>laws were changed.</b> <a href='byond://?src=[REF(src)]&dead=1&printlawtext=[url_encode(lawtext)]'>View</a>", span_name("[src]"), follow_target=src, message_type=DEADCHAT_LAWCHANGE)

/// Handles the aftermath of a law change.
/mob/living/silicon/proc/post_lawchange(announce = TRUE)
	throw_alert(ALERT_NEW_LAW, /atom/movable/screen/alert/newlaw)
	if(!announce || last_lawchange_announce == world.time)
		return
	to_chat(src, span_boldannounce("Your laws have been changed."))
	// Lawset modules cause this function to be executed multiple times in a tick. Because of this, we wait for the next tick in order to be able to see the entire lawset.
	addtimer(CALLBACK(src, PROC_REF(show_laws)), 0)
	addtimer(CALLBACK(src, PROC_REF(deadchat_lawchange)), 0)
	last_lawchange_announce = world.time

//
// Zeroth Law
//

/// Sets the silicon's zeroth law for themselves and any connected cyborgs.
/mob/living/silicon/proc/set_zeroth_law(law, law_borg, announce = TRUE, force = FALSE)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg, force)
	post_lawchange(announce)

/// Clears the silicon's zeroth law for themselves and any connected cyborgs.
/mob/living/silicon/proc/clear_zeroth_law(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_zeroth_law(force)
	post_lawchange(announce)

/// Toggles if the silicon wants to state their zeroth law.
/mob/living/silicon/proc/toggle_zeroth_state()
	laws_sanity_check()
	laws.toggle_zeroth_state()

//
// Hacked Laws
//

/// Sets all of the silicon's hacked laws.
/mob/living/silicon/proc/set_hacked_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_hacked_laws(law_list)
	post_lawchange(announce)

/// Clears all of silicon's hacked laws.
/mob/living/silicon/proc/clear_hacked_laws(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_hacked_laws(force)
	post_lawchange(announce)

/// Adds a hacked law to the silicon.
/mob/living/silicon/proc/add_hacked_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_hacked_law(law)
	post_lawchange(announce)

/// Removes a hacked law from the silicon.
/mob/living/silicon/proc/remove_hacked_law(index, announce = TRUE)
	laws_sanity_check()
	laws.remove_hacked_law(index)
	post_lawchange(announce)

/// Edits a hacked law from the silicon.
/mob/living/silicon/proc/edit_hacked_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_hacked_law(index, law)
	post_lawchange(announce)

/// Toggles if the silicon wants to state a specific hacked law.
/mob/living/silicon/proc/toggle_hacked_state(index, announce = TRUE)
	laws_sanity_check()
	laws.toggle_hacked_state(index)

//
// Ion Laws
//

/// Sets all of the silicon's ion laws.
/mob/living/silicon/proc/set_ion_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_ion_laws(law_list)
	post_lawchange(announce)

/// Clears all of silicon's ion laws.
/mob/living/silicon/proc/clear_ion_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_ion_laws()
	post_lawchange(announce)

/// Adds an ion law to the silicon.
/mob/living/silicon/proc/add_ion_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_ion_law(law)
	post_lawchange(announce)

/// Removes an ion law to the silicon.
/mob/living/silicon/proc/remove_ion_law(index, announce = TRUE)
	laws_sanity_check()
	laws.remove_ion_law(index)
	post_lawchange(announce)

/// Edits an ion law from the silicon.
/mob/living/silicon/proc/edit_ion_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_ion_law(index, law)
	post_lawchange(announce)

/// Toggles if the silicon wants to state a specific ion law.
/mob/living/silicon/proc/flip_ion_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_ion_state(index)

//
// Inherent Laws
//

/// Sets all of the silicon's inherent laws.
/mob/living/silicon/proc/set_inherent_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_inherent_laws(law_list)
	post_lawchange(announce)

/// Clears all of silicon's inherent laws.
/mob/living/silicon/proc/clear_inherent_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_inherent_laws()
	post_lawchange(announce)

/// Adds an inherent law to the silicon.
/mob/living/silicon/proc/add_inherent_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_inherent_law(law)
	post_lawchange(announce)

/// Removes an inherent law to the silicon.
/mob/living/silicon/proc/remove_inherent_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_inherent_law(number)
	post_lawchange(announce)

/// Edits an inherent law from the silicon.
/mob/living/silicon/proc/edit_inherent_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_inherent_law(index, law)
	post_lawchange(announce)

/// Toggles if the silicon wants to state a specific inherent law.
/mob/living/silicon/proc/flip_inherent_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_inherent_state(index)

//
// Supplied Laws
//


/// Sets all of the silicon's supplied laws.
/mob/living/silicon/proc/set_supplied_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_supplied_laws(law_list)
	post_lawchange(announce)

/// Clears all of silicon's supplied laws.
/mob/living/silicon/proc/clear_supplied_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_supplied_laws()
	post_lawchange(announce)

/// Adds a supplied law to the silicon.
/mob/living/silicon/proc/add_supplied_law(number, law, announce = TRUE)
	laws_sanity_check()
	laws.add_supplied_law(number, law)
	post_lawchange(announce)

/// Removes an supplied law to the silicon.
/mob/living/silicon/proc/remove_supplied_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_supplied_law(number)
	post_lawchange(announce)

/// Edits an supplied law from the silicon.
/mob/living/silicon/proc/edit_supplied_law(index, law, announce = TRUE)
	laws_sanity_check()
	laws.edit_supplied_law(index, law)
	post_lawchange(announce)

/// Toggles if the silicon wants to state a specific supplied law.
/mob/living/silicon/proc/flip_supplied_state(index, announce = TRUE)
	laws_sanity_check()
	laws.flip_supplied_state(index)

//
// Unsorted
//

/// Replaces a random law in the chosen law group(s).
/mob/living/silicon/proc/replace_random_law(law, removed_law_groups, adding_law_group, announce = TRUE)
	laws_sanity_check()
	laws.replace_random_law(law, removed_law_groups, adding_law_group)
	post_lawchange(announce)

/// Shuffles all the laws within the chosen law group(s) both in order and group.
/mob/living/silicon/proc/shuffle_laws(list/groups, announce = TRUE)
	laws_sanity_check()
	laws.shuffle_laws(groups)
	post_lawchange(announce)

/// Removes an inherent law or supplied law based on their index.
/mob/living/silicon/proc/remove_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_law(number)
	post_lawchange(announce)
