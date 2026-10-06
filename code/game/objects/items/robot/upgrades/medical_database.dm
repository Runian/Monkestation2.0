/obj/item/borg/upgrade/surgical_database
	name = "medical cyborg surgical database"
	desc = "An upgrade to the Medical model, installing a surgical databank that can record available surgeries and gives instructions on how to perform surgical procedures."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate/medical)
	model_flags = BORG_MODEL_MEDICAL
	/// Action that looks for nearby objects to load new surgeries from.
	var/datum/action/database_scanner
	// List of surgeries that can be started.
	var/list/loaded_surgeries = list()

/obj/item/borg/upgrade/surgical_database/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	RegisterSignal(borg, COMSIG_SURGERY_STARTING, PROC_REF(check_surgery))
	RegisterSignal(borg, COMSIG_MOB_SURGERY_STEP_SUCCESS, PROC_REF(on_step_completion))
	database_scanner = new /datum/action/item_action/cyborg_surgical_database(src)
	database_scanner.Grant(borg)

/obj/item/borg/upgrade/surgical_database/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	UnregisterSignal(borg, list(COMSIG_SURGERY_STARTING, COMSIG_MOB_SURGERY_STEP_SUCCESS))
	database_scanner.Remove(borg)
	QDEL_NULL(database_scanner)

/obj/item/borg/upgrade/surgical_database/ui_action_click(mob/user, actiontype)
	playsound(src, 'sound/machines/terminal_processing.ogg', 25, TRUE)
	user.balloon_alert(user, "downloading surgery data...")
	if(!do_after(user, 1 SECONDS, user))
		user.balloon_alert(user, "surgery download interrupted!")
		return
	playsound(src, 'sound/machines/terminal_success.ogg', 25, TRUE)
	var/list/surgeries_to_add = list()
	for(var/obj/nearby_object in range(1, user))
		if(istype(nearby_object, /obj/machinery/computer/operating))
			var/obj/machinery/computer/operating/operating_computer = nearby_object
			surgeries_to_add |= operating_computer.advanced_surgeries
			continue
		if(istype(nearby_object, /obj/item/disk/surgery))
			var/obj/item/disk/surgery/surgery_disk = nearby_object
			for(var/surgery in surgery_disk.surgeries)
				surgeries_to_add |= surgery
			continue
		if(istype(nearby_object, /obj/item/disk/tech_disk))
			var/obj/item/disk/tech_disk/tech_disk = nearby_object
			for(var/design in tech_disk.stored_research.researched_designs)
				var/datum/design/surgery/surgery_design = SSresearch.techweb_design_by_id(design)
				if(!istype(surgery_design))
					continue
				surgeries_to_add |= surgery_design.surgery
			continue
	if(!length(surgeries_to_add))
		user.balloon_alert(user, "no new surgery data found")
		return
	var/list/old_surgery_count = length(loaded_surgeries)
	loaded_surgeries |= surgeries_to_add
	var/list/new_surgery_count = length(loaded_surgeries)
	var/surgery_count_difference = new_surgery_count - old_surgery_count
	if(!surgery_count_difference)
		user.balloon_alert(user, "no new surgery data found")
		return
	user.balloon_alert(user, "installed [surgery_count_difference] new surgeries, [new_surgery_count] total loaded")

/obj/item/borg/upgrade/surgical_database/proc/check_surgery(mob/user, datum/surgery/surgery, mob/patient)
	SIGNAL_HANDLER
	if(surgery.replaced_by in loaded_surgeries)
		return COMPONENT_CANCEL_SURGERY
	if(surgery.type in loaded_surgeries)
		return COMPONENT_FORCE_SURGERY

/obj/item/borg/upgrade/surgical_database/proc/on_step_completion(mob/living/user, datum/surgery_step/current_step, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	SIGNAL_HANDLER
	var/possible_steps = list()
	if(current_step.repeatable)
		possible_steps += "[current_step.name]"
	var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
	if(!isnull(next_step))
		possible_steps += "[next_step.name]"
		qdel(next_step)
	if(!length(possible_steps))
		target.balloon_alert(user, "surgery done!")
		return
	target.balloon_alert(user, "next step: [english_list(possible_steps, and_text = " or ")]")

/datum/action/item_action/cyborg_surgical_database
	name = "Update Surgeries"
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "surgical_processor"
