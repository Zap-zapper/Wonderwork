/obj/machinery/party/gramophone
	name = "Gramophone"
	desc = "Old-time styley."
	icon = 'icons/obj/musician.dmi'
	icon_state = "gramophone"
	layer = MOB_LAYER + 0.2
	anchored = 1
	density = 1
	var/playing = 0

/obj/machinery/party/gramophone/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/party/gramophone/attack_hand(mob/living/user as mob)

	if (src.playing == 0)
		user << "\blue You turn on the gramophone."
		var/sound/S
		S = sound('sound/turntable/valz2.ogg')
		S.repeat = 1
		S.channel = 10
		S.falloff = 2
		S.wait = 1
		S.environment = 0
		var/area/A = src.loc.loc:master

		for(var/area/RA in A.related)
			playing = 1
			while(playing == 1)
				for(var/mob/M in world)
					if((M.loc.loc in A.related) && M.music == 0)
						M << S
						M.music = 1
					else if(!(M.loc.loc in A.related) && M.music == 1)
						var/sound/Soff = sound(null)
						Soff.channel = 10
						M << Soff
						M.music = 0
				sleep(10)
			return

	else
		user << "\blue You turn off the gramophone."
		(src.playing) = 0
		var/sound/S = sound(null)
		S.channel = 10
		S.wait = 1
		for(var/mob/M in world)
			M << S
			M.music = 0
		playing = 0
		var/area/A = src.loc.loc:master
		for(var/area/RA in A.related)