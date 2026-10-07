/obj/item/robot_model/syndicate/compact
	name = "Syndicate Compact"
	hud_icon_state = "malf"
	default_skin = /datum/robot_skin/syndicate_compact/default
	basic_modules = list( // Full support with no dedicated weapons.
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/borg/cyborg_omnitool/engineering/syndie,
		/obj/item/borg/cyborg_omnitool/engineering/syndie,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/borg/apparatus/circuit,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/analyzer,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/stack/cable_coil,
		/obj/item/borg/apparatus/sheet_manipulator,
		/obj/item/borg/charger,
		/obj/item/healthanalyzer/cyborg/advanced,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/borg/cyborg_omnitool/medical/upgraded,
		/obj/item/borg/cyborg_omnitool/medical/upgraded,
		/obj/item/blood_filter,
		/obj/item/stack/medical/gauze,
		/obj/item/emergency_bed/silicon,
		/obj/item/gun/medbeam,
		/obj/item/borg/apparatus/organ_storage,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/dest_tagger/borg,
		/obj/item/borg_chameleon,
		/obj/item/card/emag,
	)
	traits = list(TRAIT_PUSHIMMUNE, TRAIT_NEGATES_GRAVITY, TRAIT_KNOW_ENGI_WIRES, TRAIT_KNOW_ROBO_WIRES, TRAIT_CAN_CLIMB_DISPOSALS)

/obj/item/robot_model/syndicate/compact/Initialize(mapload)
	. = ..()
	if(!cyborg_owner)
		return
	var/datum/action/cooldown/borg_sight_vision/thermal/sight_vision_thermal = new(cyborg_owner)
	sight_vision_thermal.Grant(cyborg_owner)
	sight_vision_ref = WEAKREF(sight_vision_thermal)
