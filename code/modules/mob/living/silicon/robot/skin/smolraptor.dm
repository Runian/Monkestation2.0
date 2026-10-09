/datum/robot_skin/smolraptor
	abstract_type = /datum/robot_skin/smolraptor
	icon = 'icons/mob/silicon/robots_smolraptors.dmi'
	icon_state_light = "smolraptor"
	base_pixel_x = -16
	hat_offset = list(
		"north" = list(16, 0),
		"south" = list(16, -1),
		"east" = list(37, 0),
		"west" = list(-5, 0),
	)
	badge_offset = list(
		"north" = list(16, -6),
		"south" = list(16, -7),
		"east" = list(25, -6),
		"west" = list(7, -6),
	)
	ride_offset = list(
		"north" = list(0, 8),
		"south" = list(0, 8),
		"east" = list(11, 8),
		"west" = list(-11, 8),
	)
	light_offset = list(
		"north" = list(16, 0),
		"south" = list(16, 0),
		"east" = list(32, 0),
		"west" = list(0, 0),
	)
	features = list(BORG_FEATURE_RIDER_OVERLAY)

/datum/robot_skin/smolraptor/cargo
	name = "Cargo Smolraptor"
	icon_state = "smolraptor_cargo"

/datum/robot_skin/smolraptor/centcom
	name = "Centcom Smolraptor"
	icon_state = "smolraptor_centcom"

/datum/robot_skin/smolraptor/engineer
	name = "Engineer Smolraptor"
	icon_state = "smolraptor_engineer"

/datum/robot_skin/smolraptor/janitor
	name = "Janitor Smolraptor"
	icon_state = "smolraptor_janitor"

/datum/robot_skin/smolraptor/medical
	name = "Medical Smolraptor"
	icon_state = "smolraptor_medical"

/datum/robot_skin/smolraptor/miner
	name = "Miner Smolraptor"
	icon_state = "smolraptor_miner"

/datum/robot_skin/smolraptor/ninja
	name = "Ninja Smolraptor"
	icon_state = "smolraptor_ninja"

/datum/robot_skin/smolraptor/peacekeeper
	name = "Peacekeeper Smolraptor"
	icon_state = "smolraptor_peacekeeper"

/datum/robot_skin/smolraptor/science
	name = "Science Smolraptor"
	icon_state = "smolraptor_science"

/datum/robot_skin/smolraptor/security
	name = "Security Smolraptor"
	icon_state = "smolraptor_security"

/datum/robot_skin/smolraptor/service
	name = "Service Smolraptor"
	icon_state = "smolraptor_service"

/datum/robot_skin/smolraptor/standard
	name = "Standard Smolraptor"
	icon_state = "smolraptor_standard"

/datum/robot_skin/smolraptor/syndicate
	name = "Syndicate Smolraptor"
	icon_state = "smolraptor_syndicate"
