// CARGO
/obj/item/robot_model/cargo
	name = "Cargo"
	default_skin = /datum/robot_skin/cargo/default
	available_skins = list(
		/datum/robot_skin/cargo/default,
		/datum/robot_skin/cargo/zoomba,
		/datum/robot_skin/cargo/kerfus
	)
	basic_modules = list(
		/obj/item/stamp,
		/obj/item/stamp/denied,
		/obj/item/pen/cyborg,
		/obj/item/clipboard/cyborg,
		/obj/item/stack/package_wrap/cyborg,
		/obj/item/stack/wrapping_paper/xmas/cyborg,
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/hydraulic_clamp,
		/obj/item/borg/hydraulic_clamp/mail,
		/obj/item/storage/bag/mail_token_catcher,
		/obj/item/hand_labeler/cyborg,
		/obj/item/dest_tagger,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher,
		/obj/item/universal_scanner,
		/obj/item/cargo_teleporter,
		/obj/item/boxcutter,
	)
	radio_channels = list(RADIO_CHANNEL_SUPPLY)
	emag_modules = list(
		/obj/item/stamp/chameleon,
		/obj/item/borg/paperplane_crossbow,
	)
	model_select_icon = "cargo"
	canDispose = TRUE
