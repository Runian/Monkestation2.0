/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown linked Cyborgs and Drones."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	active_power_usage = STANDARD_CELL_CHARGE
	/// The cyborg that is currently locked down by us.
	var/mob/living/silicon/robot/locked_cyborg = null

/obj/machinery/computer/robotics/Destroy()
	if(!isnull(locked_cyborg))
		unlock_cyborg()
	return ..()

/obj/machinery/computer/robotics/on_set_machine_stat(old_value)
	if(!isnull(locked_cyborg) && (machine_stat & (NOPOWER|BROKEN|MAINT)))
		unlock_cyborg()
	return ..()

/obj/machinery/computer/robotics/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoboticsControlConsole", name)
		ui.open()

/obj/machinery/computer/robotics/ui_data(mob/user)
	var/list/data = list()

	data["can_hack"] = FALSE
	if(issilicon(user))
		var/mob/living/silicon/S = user
		if(S.hack_software)
			data["can_hack"] = TRUE
	else if(isAdminGhostAI(user))
		data["can_hack"] = TRUE

	data["can_detonate"] = FALSE
	if(isAI(user))
		var/mob/living/silicon/ai/ai = user
		data["can_detonate"] = !isnull(ai.malf_picker)

	var/turf/current_turf = get_turf(src)
	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if(!can_control(user, R))
			continue
		if(!is_valid_z_level(current_turf, get_turf(R)))
			continue
		var/list/cyborg_data = list(
			name = R.name,
			locked_down = R.lockcharge,
			status = R.stat,
			charge = R.cell ? round(R.cell.percent()) : null,
			module = R.model ? "[R.model.name] Model" : "No Model Detected",
			synchronization = R.connected_ai,
			emagged = R.emagged,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)

	data["drones"] = list()
	for(var/mob/living/basic/drone/drone in GLOB.drones_list)
		if(drone.hacked)
			continue
		if(!is_valid_z_level(current_turf, get_turf(drone)))
			continue
		var/list/drone_data = list(
			name = drone.name,
			status = drone.stat,
			ref = REF(drone)
		)
		data["drones"] += list(drone_data)

	return data

/obj/machinery/computer/robotics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("stopbot")
			if(!allowed(usr))
				to_chat(usr, span_danger("Access denied."))
				return
			var/mob/living/silicon/robot/target_cyborg = locate(params["ref"]) in GLOB.silicon_mobs
			if(!can_control(usr, target_cyborg))
				return
			if(target_cyborg.lockcharge)
				// Getting your wires cut is the ultimate form of lockdown.
				if(target_cyborg.wires?.is_cut(WIRE_LOCKDOWN))
					to_chat(usr, span_danger("Cyborg was locked through physical means."))
					return
				// AIs can only unlock cyborgs that they locked.
				if(isAI(usr) && !target_cyborg.ai_lockdown)
					to_chat(usr, span_danger("Cyborg locked by an user with superior permissions."))
					return
				if(isnull(locked_cyborg) || locked_cyborg != target_cyborg)
					to_chat(usr, span_danger("Cyborg was locked by a different console."))
					return
				unlock_cyborg(usr, target_cyborg)
				return
			if(!isnull(locked_cyborg))
				to_chat(usr, span_danger("You can lock down only one cyborg at a time."))
				return
			lock_cyborg(usr, target_cyborg)
			return
		if("killbot") //Malf AIs, and AIs with a combat upgrade, can detonate their cyborgs remotely.
			if(!isAI(usr))
				return
			var/mob/living/silicon/ai/ai = usr
			if(!ai.malf_picker)
				return
			var/mob/living/silicon/robot/target = locate(params["ref"]) in GLOB.silicon_mobs
			if(!istype(target))
				return
			if(target.connected_ai != ai)
				return
			target.self_destruct(usr)

		if("magbot")
			var/mob/living/silicon/S = usr
			if((istype(S) && S.hack_software) || isAdminGhostAI(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
				if(istype(R) && !R.emagged && (R.connected_ai == usr || isAdminGhostAI(usr)) && !R.scrambledcodes && can_control(usr, R))
					log_silicon("[key_name(usr)] emagged [key_name(R)] using robotic console!")
					message_admins("[ADMIN_LOOKUPFLW(usr)] emagged cyborg [key_name_admin(R)] using robotic console!")
					R.SetEmagged(TRUE)
					R.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

		if("killdrone")
			if(allowed(usr))
				var/mob/living/basic/drone/drone = locate(params["ref"]) in GLOB.mob_list
				if(drone.hacked)
					to_chat(usr, span_danger("ERROR: [drone] is not responding to external commands."))
				else
					var/turf/T = get_turf(drone)
					message_admins("[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(drone)] at [ADMIN_VERBOSEJMP(T)]!")
					log_silicon("[key_name(usr)] detonated [key_name(drone)]!")
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(3, TRUE, drone)
					s.start()
					drone.visible_message(span_danger("\the [drone] self-destructs!"))
					drone.investigate_log("has been gibbed by a robotics console.", INVESTIGATE_DEATHS)
					drone.gib()

/// Can this cyborg be affected by the robotics console at all?
/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/target_cyborg)
	if(!istype(target_cyborg))
		return FALSE
	if(isAI(user) && target_cyborg.connected_ai != user) // AIs may only affect all of their connected cyborgs.
		return FALSE
	if(iscyborg(user) && target_cyborg != user) // Cyborg may only affect themselves.
		return FALSE
	if(target_cyborg.scrambledcodes)
		return FALSE
	return TRUE

/// Unlocks the cyborg that was assigned to this computer.
/obj/machinery/computer/robotics/proc/unlock_cyborg(mob/user)
	if(!locked_cyborg)
		return

	UnregisterSignal(locked_cyborg, COMSIG_QDELETING)

	locked_cyborg.ai_lockdown = FALSE
	locked_cyborg.SetLockdown(FALSE)
	use_power = IDLE_POWER_USE

	to_chat(locked_cyborg, span_notice("Your lockdown has been lifted!"))
	if(locked_cyborg.connected_ai)
		to_chat(locked_cyborg.connected_ai, "[span_notice("NOTICE - Cyborg lockdown lifted")]: <a href='byond://?src=[REF(locked_cyborg.connected_ai)];track=[html_encode(locked_cyborg.name)]'>[locked_cyborg.name]</a><br>")

	if(user)
		message_admins(span_notice("[ADMIN_LOOKUPFLW(user)] released [ADMIN_LOOKUPFLW(locked_cyborg)]!"))
		log_silicon("[key_name(user)] released [key_name(locked_cyborg)]!")
		log_combat(user, locked_cyborg, "released cyborg")

	locked_cyborg = null

/// Locks a cyborg and assigns them to this computer.
/obj/machinery/computer/robotics/proc/lock_cyborg(mob/user, mob/living/silicon/robot/target_cyborg)
	if(locked_cyborg)
		return

	locked_cyborg = target_cyborg
	if(isAI(user))
		locked_cyborg.ai_lockdown = TRUE
	locked_cyborg.SetLockdown(TRUE)
	use_power = ACTIVE_POWER_USE

	RegisterSignal(locked_cyborg, COMSIG_QDELETING, PROC_REF(on_cyborg_deleted))

	to_chat(locked_cyborg, span_alert("Your have been locked down!"))
	to_chat(locked_cyborg, span_alert("The approximate location of the console that is keeping you locked down is [get_area_name(src)]."))
	if(locked_cyborg.connected_ai)
		to_chat(locked_cyborg.connected_ai, "[span_alert("ALERT - Cyborg lockdown detected")]: <a href='byond://?src=[REF(locked_cyborg.connected_ai)];track=[html_encode(locked_cyborg.name)]'>[locked_cyborg.name]</a><br>")

	if(user)
		message_admins(span_notice("[ADMIN_LOOKUPFLW(user)] locked down [ADMIN_LOOKUPFLW(locked_cyborg)]!"))
		log_silicon("[key_name(user)] locked down [key_name(locked_cyborg)]!")
		log_combat(user, locked_cyborg, "locked down cyborg")

/obj/machinery/computer/robotics/proc/on_cyborg_deleted(datum/source, force)
	SIGNAL_HANDLER
	locked_cyborg = null


// TODO
/*
	manual unlock (via wires) should disengage the lockdown on the computer & inform those nearby the computer that cyborg has been unlocked manually
*/
