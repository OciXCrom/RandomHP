#include <amxmodx>
#include <fun>

#define PLUGIN_VERSION "2.0"

enum _:Cvars
{
	randomhp_vip_flag,
	randomhp_amount,
	randomhp_vip_amount,
	randomhp_amount_random,
	randomhp_team
}

new g_eCvars[Cvars]
new g_iSayText

public plugin_init()
{
	register_plugin("Random HP on Round Start", PLUGIN_VERSION, "OciXCrom")
	register_cvar("RandomHP", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_dictionary("RandomHP.txt")
	
	register_logevent("OnRoundStart", 2, "1=Round_Start")
	g_iSayText = get_user_msgid("SayText")
	
	g_eCvars[randomhp_vip_flag] = register_cvar("randomhp_vip_flag", "b")
	g_eCvars[randomhp_amount] = register_cvar("randomhp_amount", "20")
	g_eCvars[randomhp_vip_amount] = register_cvar("randomhp_vip_amount", "0")
	g_eCvars[randomhp_amount_random] = register_cvar("randomhp_amount_random", "0")
	g_eCvars[randomhp_team] = register_cvar("randomhp_team", "0")
}

public OnRoundStart()
{
	new iPlayers[32], iPnum
	
	switch(get_pcvar_num(g_eCvars[randomhp_team]))
	{
		case 0: get_players(iPlayers, iPnum, "a")
		case 1: get_players(iPlayers, iPnum, "ae", "TERRORIST")
		case 2: get_players(iPlayers, iPnum, "ae", "CT")
	}
	
	if(!iPnum)
		return
	
	new id = iPlayers[random(iPnum)]
	
	if(id && is_user_alive(id))
	{
		new iHealth, iVipHealth = get_pcvar_num(g_eCvars[randomhp_vip_amount])
		
		if(iVipHealth > 0)
		{
			new szFlag[2]
			get_pcvar_string(g_eCvars[randomhp_vip_flag], szFlag, charsmax(szFlag))
			iHealth = (get_user_flags(id) & read_flags(szFlag)) ? iVipHealth : get_pcvar_num(g_eCvars[randomhp_amount])
		}
		else
			iHealth = get_pcvar_num(g_eCvars[randomhp_amount])
		
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		
		new iRandom = get_pcvar_num(g_eCvars[randomhp_amount_random])
		
		if(iRandom > 0)
			iHealth = random_num(iHealth, iHealth + iRandom)
		
		set_user_health(id, get_user_health(id) + iHealth)
		ColorChat(0, "%L", LANG_PLAYER, "RANDOM_HEALTH", szName, iHealth)
	}
}
	
ColorChat(const id, const szInput[], any:...)
{
	new iPlayers[32], iCount = 1
	static szMessage[191]
	vformat(szMessage, charsmax(szMessage), szInput, 3)
	
	replace_all(szMessage, charsmax(szMessage), "!g", "^4")
	replace_all(szMessage, charsmax(szMessage), "!n", "^1")
	replace_all(szMessage, charsmax(szMessage), "!t", "^3")
	
	if(id)
		iPlayers[0] = id
	else
		get_players(iPlayers, iCount, "ch")
	
	for(new i; i < iCount; i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_iSayText, _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMessage)
			message_end()
		}
	}
}