/// Sent from cyborg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "process_borgcharger_occupant"
/// Sent from cyborg mobs to itself for tools to catch an upcoming [Destroy()] that was due to safe deconstruction (rather than detonation).
#define COMSIG_CYBORG_SAFE_DECONSTRUCT "cyborg_safe_deconstruct"

#define COMSIG_CYBORG_CHECK_LOCKDOWN "cyborg_check_lockdown"
	#define SUCCESS_CYBORG_LOCKDOWN NONE
	#define FAILED_CYBORG_LOCKDOWN (1<<0)
