#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#define PLUGIN_VERSION "0.2"

new precachedModels
new precachedSounds
new precachedGeneric

new Array:modelList
new Array:soundList
new Array:genericList

public plugin_init()
{
	register_plugin("Precache Manager", PLUGIN_VERSION, "EfeDursun125")
	register_cvar("amx_pm_version", PLUGIN_VERSION)
	register_clcmd("amx_pm_limit", "show_limit")
	register_srvcmd("amx_pm_limit", "show_limit_server")

#if AMXX_VERSION_NUM > 182
	//new version[4]
	//get_amxx_verstring(version, charsmax(version))
	//if (str_to_float(version) > 1.82)
	hook_cvar_change(register_cvar("amx_pm_secure", "0"), "setHook") // to block precache error/warrnings
#endif

	modelList = ArrayCreate(128, 1)
	soundList = ArrayCreate(128, 1)
	genericList = ArrayCreate(128, 1)
}

public plugin_end()
{
	ArrayDestroy(modelList)
	ArrayDestroy(soundList)
	ArrayDestroy(genericList)
}

#if AMXX_VERSION_NUM > 182
new id
new id2
new id3
public setHook(pcvar, const oldValue[], const newValue[])
{
	if (oldValue[0] != 1 && newValue[0] == 1)
	{
		id = register_forward(FM_SetModel, "setModel")
		id2 = register_forward(FM_EmitSound, "emitSound")
		id3 = register_forward(FM_EmitAmbientSound, "emitSound")
	}

	if (oldValue[0] == 1 && newValue[0] != 1)
	{
		unregister_forward(FM_SetModel, id)
		unregister_forward(FM_EmitSound, id2)
		unregister_forward(FM_EmitAmbientSound, id3)
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
	while (!feof(file))
	{
		fgets(file, lineText, size)
		replace(lineText, size, "^n", "")

		if (lineText[0] == ';' || !lineText[0])
			continue

		trim(lineText)
		ArrayPushString(modelList, lineText)
	}

	fclose(file)
	formatex(fileName, charsmax(fileName), "%s/econf/precache_manager/unprecache_sounds.ini", path)
	file = fopen(fileName, "rt")
	if (!file)
		return
	
	while (!feof(file))
	{
		fgets(file, lineText, size)
		replace(lineText, size, "^n", "")

		if (lineText[0] == ';' || !lineText[0])
			continue

		trim(lineText)
		ArrayPushString(soundList, lineText)
	}

	fclose(file)
	formatex(fileName, charsmax(fileName), "%s/econf/precache_manager/unprecache_generics.ini", path)
	file = fopen(fileName, "rt")
	if (!file)
		return
	
	while (!feof(file))
	{
		fgets(file, lineText, size)
		replace(lineText, size, "^n", "")

		if (lineText[0] == ';' || !lineText[0])
			continue

		trim(lineText)
		ArrayPushString(soundList, lineText)
	}

	fclose(file)
}

public precacheModel(const model[])
{
	new i, size = ArraySize(modelList), temp[128], limit = charsmax(temp)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(modelList, i, temp, limit)
		if (strcmp(model, temp) == 0)
			return FMRES_SUPERCEDE 
	}

	precachedModels++
	return FMRES_IGNORED
}

public precacheSound(const sound[])
{
	new i, size = ArraySize(soundList), temp[128], limit = charsmax(temp)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(soundList, i, temp, limit)
		if (strcmp(sound, temp) == 0)
			return FMRES_SUPERCEDE 
	}

	precachedSounds++
	return FMRES_IGNORED
}

public precacheGeneric(const generic[])
{
	new i, size = ArraySize(genericList), temp[128], limit = charsmax(temp)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(genericList, i, temp, limit)
		if (strcmp(generic, temp) == 0)
			return FMRES_SUPERCEDE 
	}
	
	precachedGeneric++
	return FMRES_IGNORED
}

#if AMXX_VERSION_NUM > 182
public setModel(const model[])
{
	if (ArrayFindString(modelList, model) != -1)
		return FMRES_SUPERCEDE
	return FMRES_IGNORED
}

public emitSound(const sound[])
{
	if (ArrayFindString(soundList, sound) != -1)
		return FMRES_SUPERCEDE
	return FMRES_IGNORED
}
#endif
