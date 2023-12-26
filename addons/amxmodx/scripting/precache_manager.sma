#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#define PLUGIN_VERSION "0.1"

new i
new precachedModels
new precachedSounds
new precachedGeneric

const MAX_MODELS = 400
new modelList[MAX_MODELS][128]
new modelCount

const MAX_SOUNDS = 400
new soundList[MAX_SOUNDS][128]
new soundCount

const MAX_GENERIC = 700
new genericList[MAX_GENERIC][128]
new genericCount

public plugin_init()
{
	register_plugin("Precache Manager", PLUGIN_VERSION, "EfeDursun125")
	register_cvar("amx_pm_version", PLUGIN_VERSION)
	register_clcmd("amx_pm_limit", "show_limit")
	register_srvcmd("amx_pm_limit", "show_limit_server")
#if AMXX_VERSION_NUM > 182
	hook_cvar_change(register_cvar("amx_pm_secure", "0"), "setHook") // to block precache error/warrnings
#endif
}

#if AMXX_VERSION_NUM > 182
new id
new id2
new id3
new id4
new id5
new id6

public setHook(pcvar, const oldValue[], const newValue[])
{
	if (oldValue[0] != 1 && newValue[0] == 1)
	{
		id = register_forward(FM_SetModel, "setModel")
		id2 = register_forward(FM_SetModel, "setModel", 1)
		id3 = register_forward(FM_EmitSound, "emitSound")
		id4 = register_forward(FM_EmitSound, "emitSound", 1)
		id5 = register_forward(FM_EmitAmbientSound, "emitSound")
		id6 = register_forward(FM_EmitAmbientSound, "emitSound", 1)
	}

	if (oldValue[0] == 1 && newValue[0] != 1)
	{
		unregister_forward(FM_SetModel, id)
		unregister_forward(FM_SetModel, id2, 1)
		unregister_forward(FM_EmitSound, id3)
		unregister_forward(FM_EmitSound, id4, 1)
		unregister_forward(FM_EmitAmbientSound, id5)
		unregister_forward(FM_EmitAmbientSound, id6, 1)
	}
}
#endif

public show_limit(id)
{
	if (is_user_connected(id))
		console_print(id, "^n^n---> Precache Manager %f^n-->^n--> Precached Models: %i^n--> Precached Sounds: %i^n--> Precached Generics: %i^n--^n---> Made by EfeDursun125^n^n", PLUGIN_VERSION, precachedModels, precachedSounds, precachedGeneric)
}

public show_limit_server()
{
	server_print("^n^n---> Precache Manager %f^n-->^n--> Precached Models: %i^n--> Precached Sounds: %i^n--> Precached Generics: %i^n-->^n---> Made by EfeDursun125^n^n", PLUGIN_VERSION, precachedModels, precachedSounds, precachedGeneric)
}

public plugin_precache()
{
	load_data()
	precachedModels = 0
	precachedSounds = 0
	precachedGeneric = 0
	register_forward(FM_PrecacheModel, "precacheModel")
	register_forward(FM_PrecacheSound, "precacheSound")
	register_forward(FM_PrecacheGeneric, "precacheGeneric")
}

public load_data()
{
	new path[256]
	get_configsdir(path, charsmax(path))

	new fileName[256]
	formatex(fileName, charsmax(fileName), "%s/econf/precache_manager/unprecache_models.ini", path)

	new file = fopen(fileName, "rt")
	if (!file)
		return
	
	new lineText[128]
	new size = charsmax(lineText)
	while (modelCount < MAX_MODELS && !feof(file))
	{
		fgets(file, lineText, size)
		replace(lineText, size, "^n", "")

		if (lineText[0] == ';' || !lineText[0])
			continue
		
		trim(lineText)
		modelList[modelCount] = lineText
		modelCount++ 
	}

	fclose(file)
	formatex(fileName, charsmax(fileName), "%s/econf/precache_manager/unprecache_sounds.ini", path)
	file = fopen(fileName, "rt")
	if (!file)
		return
	
	while (soundCount < MAX_SOUNDS && !feof(file))
	{
		fgets(file, lineText, size)
		replace(lineText, size, "^n", "")

		if (lineText[0] == ';' || !lineText[0])
			continue
		
		trim(lineText)
		soundList[soundCount] = lineText
		soundCount++
	}

	fclose(file)
	formatex(fileName, charsmax(fileName), "%s/econf/precache_manager/unprecache_generics.ini", path)
	file = fopen(fileName, "rt")
	if (!file)
		return
	
	while (genericCount < MAX_GENERIC && !feof(file))
	{
		fgets(file, lineText, size)
		replace(lineText, size, "^n", "")

		if (lineText[0] == ';' || !lineText[0])
			continue
		
		trim(lineText)
		genericList[genericCount] = lineText
		genericCount++
	}

	fclose(file)
}

public precacheModel(const model[])
{
	for (i = 0; i < modelCount; i++)
	{
		if (strcmp(model, modelList[i]) == 0)
			return FMRES_SUPERCEDE
	}
	
	precachedModels++
	return FMRES_IGNORED
}

public precacheSound(const sound[])
{
	for (i = 0; i < soundCount; i++)
	{
		if (strcmp(sound, soundList[i]) == 0)
			return FMRES_SUPERCEDE 
	}
	
	precachedSounds++
	return FMRES_IGNORED
}

public precacheGeneric(const generic[])
{
	for (i = 0; i < genericCount; i++)
	{
		if (strcmp(generic, genericList[i]) == 0)
			return FMRES_SUPERCEDE 
	}
	
	precachedGeneric++
	return FMRES_IGNORED
}

#if AMXX_VERSION_NUM > 182
public setModel(const model[])
{
	for (i = 0; i < modelCount; i++)
	{
		// do not allow to set unprecached models
		if (strcmp(model, modelList[i]) == 0)
			return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}

public emitSound(const sound[])
{
	for (i = 0; i < soundCount; i++)
	{
		// do not allow to emit unprecached sounds
		if (strcmp(sound, soundList[i]) == 0)
			return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}
#endif
