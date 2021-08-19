//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
#define DEBUG 1
#define PLUGIN_NAME  "DoDs_medicaid"
#define PLUGIN_VERSION "1.0"
#define GAME_DOD
#include "k64t"//#include <sourcemod> 
// Global Var
//int MedicUsed[MAX_PLAYERS+1][2];
int HealthProcess[MAX_PLAYERS+1];
int MinHealth,MaxHealth;
public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Kom64t",
    description = "DoD:S Call Medic",
    version = PLUGIN_VERSION,
    url = "https://github.com/k64t34/DoD_medicaid.sourcemod"
};
//*************************
public void OnPluginStart(){
//*************************
#if defined DEBUG	
DebugPrint("OnPluginStart");
LogMessage("OnPluginStart");
#endif 
//LoadTranslations("dod_medicaid.phrases");
//RegConsoleCmd("say",		Command_Say);
//RegConsoleCmd("say_team", 	Command_Say);
RegConsoleCmd("medic",		Command_medic);
HookEvent("player_death", Event_PlayerDeath);
HookEvent("player_spawn", Event_PlayerSpawn);
#if defined DEBUG
RegConsoleCmd("antimedic",Command_degradate_health);
#endif
}
//*************************
public void OnMapStart(){
//*************************
#if defined DEBUG	
DebugPrint("OnMapStart");
LogMessage("OnMapStart");
#endif 

// ConVar
Handle cvarMinHealth = INVALID_HANDLE;
Handle cvarMaxHealth = INVALID_HANDLE;
cvarMinHealth	= CreateConVar( "medicaid_MinHealth", "33");
cvarMaxHealth	= CreateConVar( "medicaid_MaxHealth", "50");
AutoExecConfig(true, PLUGIN_NAME);
MinHealth=GetConVarInt(cvarMinHealth);
MaxHealth=GetConVarInt(cvarMaxHealth);
for (int i=1;i<=MAX_PLAYERS;i++)HealthProcess[i]=0;
}
#if defined DEBUG		
//*************************
public void OnMapEnd(){
//*************************	
DebugPrint("OnMapEnd");
LogMessage("OnMapEnd");
}
#endif
//*************************
public Action Command_medic(int client,int args){
//*************************	
#if defined DEBUG	
DebugPrint("Command_medic");
LogMessage("Command_medic");
#endif 
if(client == 0)return Plugin_Handled;
int intBuff=GetClientTeam(client);
if (!(intBuff==DOD_TEAM_ALLIES || intBuff==DOD_TEAM_AXIS))return Plugin_Handled;
if(!IsPlayerAlive(client)) return Plugin_Handled;
intBuff=GetClientHealth(client);
if (intBuff>=MinHealth)return Plugin_Handled;
SetClientScreenFade( client, 255, 0, 0, 192, 1000 );
HealthProcess[client]=intBuff++;
CreateTimer(1.0,Cure,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
return Plugin_Handled;
}
//*************************	
public  Action Cure(Handle timer, int client){
//*************************	
if (HealthProcess[client]==0)return Plugin_Stop;
SetClientHealth(client,HealthProcess[client]);
HealthProcess[client]++;
if (HealthProcess[client]>=MaxHealth){HealthProcess[client]=0;return Plugin_Stop;}
return Plugin_Continue;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerDeath %d",GetClientOfUserId(event.GetInt("userid")));
	#endif 	
	HealthProcess[GetClientOfUserId(event.GetInt("userid"))]=0;
	}
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerSpawn");
	#endif 	
	HealthProcess[GetClientOfUserId(event.GetInt("userid"))]=0;}

#if defined DEBUG	
public Action Command_degradate_health(int client,int args){
SetClientHealth(client,GetRandomInt(1,MinHealth-1));
}
#endif 

#endinput
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#include "k64t"

Handle cvarUsageMySelf = INVALID_HANDLE;
//new gUsageMySelf;
Handle cvarUsageTM = INVALID_HANDLE;
//new gUsageTM;

#define MYSELF 0
#define TM 1
Handle HealProcessTimer[MAX_PLAYERS+1] = INVALID_HANDLE;

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "k64t@ya.ru",
    description = "Plugin allows to heal yourself and teammate",
    version = PLUGIN_VERSION,
    url = ""
};
//***********************************************
void OnPluginStart(){
//***********************************************
#if defined DEBUG
DebugPrint("OnPluginStart");
#endif 
LoadTranslations("dod_medicaid.phrases");
//HookEvents
HookEvent("player_death", EventPlayerDeath);
HookEvent("player_spawn", Event_PlayerSpawn );

RegConsoleCmd("healmyself", HealMySelf,"");
RegConsoleCmd("healyou", healyou,"");

cvarMinHealth = CreateConVar( "medicaid_minhealth", "33" );

}

//***********************************************
void EventPlayerDeath(Handle:event,const String:name[],bool:dontBroadcast){}
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






