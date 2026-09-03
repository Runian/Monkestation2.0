/// Sent from cyborg recharger when it successfully charged the occupant: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "process_borgcharger_occupant"

/// Sent from cyborg mobs to itself for tools to catch an upcoming [Destroy()] that was due to safe deconstruction (rather than detonation).
#define COMSIG_CYBORG_SAFE_DECONSTRUCT "cyborg_safe_deconstruct"

/// Sent from [/obj/machinery/computer/robotics/proc/unlock_cyborg] when a different robotics console tries to unlock the cyborg: (obj/machinery/computer/robotics/unlocking_console)
#define COMSIG_CYBORG_LOCKDOWN_CONSOLE_UNLOCK_ATTEMPT "cyborg_lockdown_console_attempt"
	// Stops further action for the robotic console's lockdown attempt.
	#define CYBORG_LOCKDOWN_CONSOLE_INTERCEPTED (1 << 0)

/// Sent from [/mob/living/silicon/robot/proc/try_lockdown] if the cyborg was successfully unlocked: ()
#define COMSIG_CYBORG_LOCKDOWN_UNLOCK "cyborg_lockdown_unlock"
