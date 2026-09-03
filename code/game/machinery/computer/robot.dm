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
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, TRUE)
		unlock_cyborg()
	return ..()

/obj/machinery/computer/robotics/on_set_machine_stat(old_value)
	if(!isnull(locked_cyborg))
		if(machine_stat & NOPOWER)
			playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
			say("Automatic release of [locked_cyborg.name]. Cause: power outage!")
			unlock_cyborg()
		else if(machine_stat & (BROKEN|MAINT)) // Computers don't really use MAINT, but we have it just in case.
			playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
			say("Automatic release of [locked_cyborg.name]. Cause: system failure!")
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
			if(!target_cyborg.lockcharge)
				if(!isnull(locked_cyborg))
					to_chat(usr, span_danger("You can lock down only one cyborg at a time."))
					return
				lock_cyborg(usr, target_cyborg)
				return
			if(target_cyborg.wires?.is_cut(WIRE_LOCKDOWN))
				to_chat(usr, span_danger("Cyborg's motor controller is irresponsive!"))
				return
			// AIs can only unlock any cyborgs, but only if it was locked by them first.
			if(isAI(usr) && !target_cyborg.ai_lockdown)
				to_chat(usr, span_danger("Cyborg was locked by an user with superior permissions."))
				return
			unlock_cyborg(usr, target_cyborg)
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

/// Unlocks the targetted cyborg.
/obj/machinery/computer/robotics/proc/unlock_cyborg(mob/user, mob/living/silicon/robot/target_cyborg = locked_cyborg)
	if(target_cyborg != locked_cyborg && (SEND_SIGNAL(target_cyborg, COMSIG_CYBORG_LOCKDOWN_CONSOLE_UNLOCK_ATTEMPT, src) & CYBORG_LOCKDOWN_CONSOLE_INTERCEPTED))
		return

	if(QDELETED(target_cyborg))
		if(target_cyborg == locked_cyborg)
			use_power = IDLE_POWER_USE
			locked_cyborg = null
		return

	if(target_cyborg == locked_cyborg)
		UnregisterSignal(locked_cyborg, COMSIG_LIVING_DEATH)
		UnregisterSignal(locked_cyborg, COMSIG_QDELETING)
		UnregisterSignal(locked_cyborg, COMSIG_CYBORG_LOCKDOWN_CONSOLE_UNLOCK_ATTEMPT)
		UnregisterSignal(locked_cyborg, COMSIG_CYBORG_LOCKDOWN_UNLOCK)
		if(locked_cyborg.lockcharge)
			locked_cyborg.ai_lockdown = FALSE
			locked_cyborg.try_lockdown(FALSE)
		use_power = IDLE_POWER_USE
		locked_cyborg = null
	inform_and_log_unlock(target_cyborg, user)

/// Locks a cyborg and assigns them to this computer.
/obj/machinery/computer/robotics/proc/lock_cyborg(mob/user, mob/living/silicon/robot/target_cyborg)
	locked_cyborg = target_cyborg
	if(isAI(user))
		locked_cyborg.ai_lockdown = TRUE
	locked_cyborg.try_lockdown(TRUE)
	use_power = ACTIVE_POWER_USE

	RegisterSignal(locked_cyborg, COMSIG_LIVING_DEATH, PROC_REF(on_cyborg_death))
	RegisterSignal(locked_cyborg, COMSIG_QDELETING, PROC_REF(on_cyborg_deleted))
	RegisterSignal(locked_cyborg, COMSIG_CYBORG_LOCKDOWN_CONSOLE_UNLOCK_ATTEMPT, PROC_REF(on_cyborg_unlock_intercept))
	RegisterSignal(locked_cyborg, COMSIG_CYBORG_LOCKDOWN_UNLOCK, PROC_REF(on_cyborg_unlocked))
	inform_and_log_unlock(user, locked_cyborg)

/// Logs and informs the user and cyborg about their unlocked status.
/obj/machinery/computer/robotics/proc/inform_and_log_unlock(mob/informed_user, mob/living/silicon/robot/informed_cyborg)
	to_chat(informed_cyborg, span_notice("Your lockdown has been lifted!"))
	if(informed_cyborg.connected_ai)
		to_chat(informed_cyborg.connected_ai, "[span_notice("NOTICE - Cyborg lockdown lifted")]: <a href='byond://?src=[REF(informed_cyborg.connected_ai)];track=[html_encode(informed_cyborg.name)]'>[informed_cyborg.name]</a><br>")
	if(informed_user)
		message_admins(span_notice("[ADMIN_LOOKUPFLW(informed_user)] released [ADMIN_LOOKUPFLW(informed_cyborg)]!"))
		log_silicon("[key_name(informed_user)] released [key_name(informed_cyborg)]!")
		log_combat(informed_user, informed_cyborg, "released cyborg")

/// Logs and informs the user and cyborg about their locked status.
/obj/machinery/computer/robotics/proc/inform_and_log_lock(mob/informed_user, mob/living/silicon/robot/informed_cyborg)
	to_chat(informed_cyborg, span_alert("Your have been locked down!"))
	to_chat(informed_cyborg, span_alert("The approximate location of the console that is keeping you locked down is [get_area_name(src)]."))
	if(informed_cyborg.connected_ai)
		to_chat(informed_cyborg.connected_ai, "[span_alert("ALERT - Cyborg lockdown detected")]: <a href='byond://?src=[REF(informed_cyborg.connected_ai)];track=[html_encode(informed_cyborg.name)]'>[informed_cyborg.name]</a><br>")
	if(informed_user)
		message_admins(span_notice("[ADMIN_LOOKUPFLW(informed_user)] locked down [ADMIN_LOOKUPFLW(informed_cyborg)]!"))
		log_silicon("[key_name(informed_user)] locked down [key_name(informed_cyborg)]!")
		log_combat(informed_user, informed_cyborg, "locked down cyborg")

/// Unlocks the cyborg and informs those nearby that it was because the cyborg died.
/obj/machinery/computer/robotics/proc/on_cyborg_death(datum/source, gibbed)
	SIGNAL_HANDLER
	playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
	say("Automatic release of [locked_cyborg.name]. Cause: unresponsive telemetry!")
	log_silicon("Robotics console automatically released [key_name(locked_cyborg)] upon death!")
	unlock_cyborg()

/// Unassigns the cyborg and informs those nearby that it was because the cyborg deleted.
/obj/machinery/computer/robotics/proc/on_cyborg_deleted(datum/source, force)
	SIGNAL_HANDLER
	playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
	say("Automatic release of [locked_cyborg.name]. Cause: telemetry no longer exists!")
	log_silicon("Robotics console automatically released [key_name(locked_cyborg)] upon deletion!")
	unlock_cyborg()

/// Unlocks the cyborg and informs those nearby that it was because of a different robotics console.
/obj/machinery/computer/robotics/proc/on_cyborg_unlock_intercept(datum/source, obj/machinery/computer/robotics/unlocking_console)
	SIGNAL_HANDLER
	playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
	say("Automatic release of [locked_cyborg.name]. Cause: unlocked by different robotics console!")
	unlock_cyborg()
	return CYBORG_LOCKDOWN_CONSOLE_INTERCEPTED

/// Informs those nearby that the cyborg was unlocked through external intervention.
/obj/machinery/computer/robotics/proc/on_cyborg_unlocked(datum/source)
	SIGNAL_HANDLER
	playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
	say("Automatic release of [locked_cyborg.name]. Cause: external intervention!")
	unlock_cyborg()

