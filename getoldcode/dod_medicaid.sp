//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
#define DEBUG 1
#define PLUGIN_NAME  "dod_medicaid"
#define PLUGIN_VERSION "0.1"


#include "k64t"
// ConVar
new Handle:cvarMinHealth = INVALID_HANDLE;
new Handle:cvarMaxHealth = INVALID_HANDLE;
new Handle:cvarUsageMySelf = INVALID_HANDLE;
//new gUsageMySelf;
new Handle:cvarUsageTM = INVALID_HANDLE;
//new gUsageTM;
// Global Var
new gPLUGIN_NAME[]=PLUGIN_NAME;
new MedicUsed[MAX_PLAYERS+1][2];
new HealProcess[MAX_PLAYERS+1][MAX_PLAYERS+1];
#define MYSELF 0
#define TM 1
new Handle:HealProcessTimer[MAX_PLAYERS+1] = INVALID_HANDLE;

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "k64t@ya.ru",
    description = "Plugin allows to heal yourself and teammate",
    version = PLUGIN_VERSION,
    url = ""
};
//***********************************************
public OnPluginStart(){
//***********************************************
#if defined DEBUG
DebugPrint("OnPluginStart");
#endif 
LoadTranslations("dod_medicaid.phrases");

cvarMinHealth = CreateConVar( "medicaid_MinHealth", "33");
cvarMaxHealth = CreateConVar( "medicaid_MaxHealth", "50");
cvarUsageMySelf = CreateConVar( "medicaid_UsageMySelf", "1");
cvarUsageTM = CreateConVar( "medicaid_UsageTeammate", "2");


//HookEvents
HookEvent("player_death", EventPlayerDeath);
HookEvent("player_spawn", Event_PlayerSpawn );

RegConsoleCmd("healmyself", HealMySelf,"");
RegConsoleCmd("healyou", healyou,"");

cvarMinHealth = CreateConVar( "medicaid_minhealth", "33" );

}
//***********************************************
public OnMapStart(){
//***********************************************
AutoExecConfig(true, gPLUGIN_NAME);
}
//***********************************************
public EventPlayerDeath(Handle:event,const String:name[],bool:dontBroadcast){}
//*****************************************************************************
public  Action:HealMySelf(client, args){
//*****************************************************************************
if( !IsPlayerAlive( client ) )
	{		
	PrintToChat( client, "[%s] You can't receive medicaid while you are dead!",gPLUGIN_NAME );		
	return Plugin_Handled;
	}
new tmpInt;
tmpInt=GetConVarInt(cvarUsageMySelf);
if (MedicUsed[client][MYSELF]>=tmpInt)
	{
	PrintToChat( client, "[%s] You can receive medicaid înly %d time(s)", gPLUGIN_NAME,tmpInt);
	return Plugin_Handled;
	}	
tmpInt = GetConVarInt( cvarMinHealth );	
if( GetClientHealth( client ) >= tmpInt )
	{
	PrintToChat( client, "[%s] Your health must be lower than '%d' to use medicaid!",gPLUGIN_NAME,tmpInt );		
	return Plugin_Handled;	
	}
MedicUsed[client][MYSELF]++;
PrintToChat( client, "[%s] Successfully use medicaid.",gPLUGIN_NAME );
SetClientHealth( client, GetConVarInt( cvarMaxHealth ) );
SetClientScreenFade( client, 255, 0, 0, 60, 1 );
	
return Plugin_Continue;
}
//*****************************************************************************
public  Action:healyou(client, args){
//*****************************************************************************
MedicUsed[client][TM]++;
return Plugin_Handled;
}


//*****************************************************************************
public Action:Event_PlayerSpawn( Handle:event, const String:name[], bool:dontBroadcast ){
//*****************************************************************************
//new id = GetClientOfUserId( GetEventInt( event, "userid" ) );
MedicUsed[GetClientOfUserId( GetEventInt( event, "userid" ) )][MYSELF] = 0;
MedicUsed[GetClientOfUserId( GetEventInt( event, "userid" ) )][TM] = 0;
}

#endinput




