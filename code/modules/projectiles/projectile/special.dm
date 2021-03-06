/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"


	on_hit(var/atom/target, var/blocked = 0)
		empulse(target, 1, 1)
		return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"


	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 300


	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
		if(istype(target, /mob/living))
			var/mob/M = target
			M.bodytemperature = temperature
		return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.meteorhit(src)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
						shake_camera(M, 3, 1)
				del(src)
				return 1
		else
			return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/living/M = target
//		if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
		if(ishuman(target))
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				if(prob(15))
					M.apply_effect((rand(30,80)),IRRADIATE)
					M.Weaken(5)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
				if(prob(35))
				//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
				//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("\red The radiation beam singes you!")
				//	for (var/mob/V in viewers(src))
				//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
		else if(istype(target, /mob/living/carbon/))
		//	for (var/mob/V in viewers(src))
		//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/M = target
//		if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //These rays make plantmen fat.
		if(ishuman(target)) //These rays make plantmen fat.
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				M.nutrition += 30
		else if (istype(target, /mob/living/carbon/))
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"
	icon_state = "grray"

	on_hit(var/atom/target, var/blocked = 0)
		if(ishuman(target))
			var/mob/living/carbon/human/M = target
			M.adjustBrainLoss(20)
			M.hallucination += 20

//Kinetic Accelerator//

/obj/item/projectile/energy/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 10
	damage_type = BRUTE
	flag = "bomb"
	var/splash = 0
	var/range = 3 //This will de-increment every step. When 0, it will delete the projectile.

/obj/item/projectile/energy/kinetic/proc/Range()
	range--
	if(range <= 0 && loc)
		on_range()

/obj/item/projectile/energy/kinetic/proc/on_range() //if we want there to be effects when they reach the end of their range
	del(src)


/obj/item/projectile/energy/kinetic/super
	damage = 11
	range = 4

/obj/item/projectile/energy/kinetic/hyper
	damage = 12
	range = 5
	splash = 1

/obj/item/projectile/energy/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage *= 4
	..()

/obj/item/projectile/energy/kinetic/on_range()
	new /obj/item/effect/kinetic_blast(src.loc)
	..()

/obj/item/projectile/energy/kinetic/on_hit(atom/target)
	. = ..()
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = target_turf
		M.gets_drilled(firer)
	new /obj/item/effect/kinetic_blast(target_turf)
	if(src.splash)
		for(var/turf/T in range(splash, target_turf))
			if(istype(T, /turf/simulated/mineral))
				var/turf/simulated/mineral/M = T
				M.gets_drilled(firer)


/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	spawn(4)
		del(src)

/obj/item/projectile/energy/plasma
	name ="unstable plasma clot"
	icon_state = "plasma"
	damage = 50
	damage_type = BURN
	flag = "energy"


	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

//*****D2K5 SHIT*****//
/*
/obj/item/projectile/phaser
	name = "phaser shot"
	icon_state = "spark"
	nodamage = 1
	damage_type = BURN
	flag = "energy"
	var/loaded_effect = "stun"
	var/radius = 0.0
	var/power = 25.0

	proc/effect_tiles(turf/A, var/effect_type)
		if(effect_type == "stun")
			for (var/turf/phaseturf in range(radius,A))
				for(var/mob/living/carbon/M in phaseturf)
					M.stunned += power / 5
					M.weakened += power / 5
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, get_turf(A))
					s.start()
		return
*/