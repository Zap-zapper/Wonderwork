/obj/vehicle
	var/can_buckle = 0
	var/buckle_movable = 0
	var/buckle_dir = 0
	var/buckle_lying = -1 //bed-like behavior, forces mob.lying = buckle_lying if != -1
	var/buckle_require_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/mob/living/buckled_mob = null

/obj/vehicle/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/obj/vehicle/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M))
		user_buckle_mob(M, user)

//Cleanup

/obj/vehicle/Del()
	unbuckle_mob()
	return ..()


/obj/vehicle/proc/buckle_mob(mob/living/M)
	if(!can_buckle || !istype(M) || (M.loc != loc) || M.buckled || M.pinned.len || (buckle_require_restraints && !M.restrained()))
		return 0

	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	add_fingerprint(M)

	return 1

/obj/vehicle/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob = null

		post_buckle_mob(.)

/obj/vehicle/proc/post_buckle_mob(mob/living/M)
	return

/obj/vehicle/proc/user_buckle_mob(mob/living/M, mob/user)
	if(!user.Adjacent(M) || user.restrained() || user.lying || user.stat || istype(user, /mob/living/silicon/pai))
		return
	if(M == buckled_mob)
		return
	if(istype(M, /mob/living/carbon/metroid))
		user << "<span class='warning'>The [M] is too squishy to buckle in.</span>"
		return
	if (buckled_mob)
		user << "<span class='warning'>[buckled_mob.name] is already there, unbuckle them first!.</span>"
		return

	add_fingerprint(user)
	unbuckle_mob()//this is now just for safety, buckling someone into an occupied chair will fail, instead of removing the occupant

	if(buckle_mob(M))
		if(M == user)
			M.visible_message(\
				"<span class='notice'>[M.name] buckles themselves to [src].</span>",\
				"<span class='notice'>You buckle yourself to [src].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='danger'>[M.name] is buckled to [src] by [user.name]!</span>",\
				"<span class='danger'>You are buckled to [src] by [user.name]!</span>",\
				"<span class='notice'>You hear metal clanking.</span>")

/obj/vehicle/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[M.name] was unbuckled by [user.name]!</span>",\
				"<span class='notice'>You were unbuckled from [src] by [user.name].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='notice'>[M.name] unbuckled themselves!</span>",\
				"<span class='notice'>You unbuckle yourself from [src].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		add_fingerprint(user)
	return M