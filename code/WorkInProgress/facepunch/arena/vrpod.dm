//This is so we can access it easily
var/global/list/mob/living/carbon/arenaplayers = list()

/obj/structure/literal_firewall
	name = "system firewall"
	desc = "Man, your port doesn't feel like it's allowed through there! If only there was a way to open it."
	icon = 'icons/obj/vrstuff.dmi'
	icon_state = "vwall"
	density = 1
	opacity = 1
	anchored = 1

/obj/structure/literal_firewall/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/weapon/keycard))
		to_chat(user, "<span style=\"color:blue\">keycard -c 'ufw allow 2323/stcp from ::1'</span>")
		del(src)
	else
		return

/obj/machinery/vrpod
	name = "Virtual Realityator"
	icon = 'icons/obj/vrpods.dmi'
	icon_state = "med_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/occupant = null
	var/mob/living/linkedmob = null
	use_power = 1
	active_power_usage = 500
	idle_power_usage = 100

/obj/machinery/vrpod/New()
	switch(orient)
		if("LEFT")
			icon_state = "med_0"
		if("RIGHT")
			icon_state = "med_0-r"

/obj/machinery/vrpod/process()
	if(occupant && linkedmob)
		if(occupant.stat == 2)//Main body dies
			if(linkedmob.stat == 0)
				occupant.client = linkedmob.client
				occupant.loc = src.loc
				linkedmob = null
				occupant = null
				icon_state = "med_1"
		if(linkedmob.stat == 2)//VR body dies
			occupant.client = linkedmob.client
			occupant.loc = src.loc
			linkedmob = null
			occupant = null
			icon_state = "med_1"

/obj/machinery/vrpod/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.blob_act()
		del(src)
	return

/obj/machinery/vrpod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
	return

/obj/machinery/vrpod/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/vrpod/proc/go_out()
	if(!src.occupant)
		return
	use_power = 1
	for(var/obj/O in src)
		O.loc = src.loc
	if(src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	if(orient == "RIGHT")
		icon_state = "med_0-r"
	return

/obj/machinery/vrpod/verb/eject()
	set name = "Eject Virtual Realityator"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(usr == occupant)//Only the user
		src.go_out()
	add_fingerprint(usr)
	if(orient == "RIGHT")
		icon_state = "med_0-r"
	else
		src.icon_state = "med_0"
	return

/obj/machinery/vrpod/verb/move_inside()
	set name = "Enter Virtual Realityator"
	set category = "Object"
	set src in oview(1)

	if(usr in arenaplayers)
		usr << "You have not signed up!"
		return

	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
		return

	if(src.occupant)
		usr << "\blue <B>The Virtual Realityator is already occupied!</B>"
		return

	for(var/mob/living/carbon/metroid/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return

	visible_message("[usr] starts climbing into the Virtual Realityator.", 3)
	if(do_after(usr, 20))
		if(src.occupant)
			usr << "\blue <B>The Virtual Realityator is already occupied!</B>"
			return
		use_power = 2
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr
		src.icon_state = "med_1"
		if(orient == "RIGHT")
			icon_state = "med_1-r"

		for(var/obj/O in src)
			del(O)
		src.add_fingerprint(usr)
		icon_state = "med_1"
		if(occupant)
			occupant.client.lastknownmob = usr
			var/mob/living/carbon/human/virtual/S1 = new/mob/living/carbon/human/virtual
			S1.prevmob = usr.client.mob
			S1.prevname = usr.client.mob.real_name
			linkedmob = S1
			var/team = 1
			var/mob/living/carbon/human/M = S1
			switch(team)
				if(1)
					M.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(M), slot_w_uniform)
					M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
					M.update_icons()
					for(var/list/obj/effect/landmark/vrstart/G in world)
						M.loc = G.loc
			for(var/obj/item/X in S1)
				X.canremove = 0
			usr.client.mob = S1
			S1.linkedmachine = src
			S1 << "Welcome to the system, [occupant]. Your body will remain were it last was, and it can be moved away from the machine. We are not responsible to any harm your main body has. If you die in the simulation, you will be put back in your body no matter the state unless it was blown up. You can also manually return to your body. Right click the pod after you have awoken and Eject yourself from it."
		return
	return