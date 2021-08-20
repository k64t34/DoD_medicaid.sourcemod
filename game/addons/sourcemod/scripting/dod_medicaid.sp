//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
#define DEBUG 1
#define PLUGIN_NAME  "DoDs_medicaid"
#define PLUGIN_VERSION "1.0"
#define GAME_DOD
#include "k64t"//#include <sourcemod> 
// Global Var
//int MedicUsed[MAX_PLAYERS+1][2];

#define HEALTH 0
#define MEDKIT 1
#define CURE   2
int HealthProcess[MAX_PLAYERS+1][3];
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
HookEvent("player_death",	Event_PlayerDeath);
HookEvent("player_spawn",	Event_PlayerSpawn);
HookEvent("player_hurt",	Event_PlayerHurt);
HookEvent("player_team",	Event_PlayerDeath);
HookEvent("player_disconnect",	Event_PlayerDeath);
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
for (int i=1;i<=MAX_PLAYERS;i++)
	{	
	HealthProcess[i][HEALTH]=0;
	HealthProcess[i][MEDKIT]=0;
	HealthProcess[i][CURE]=0;
	}
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
if (HealthProcess[client][MEDKIT]==0)return Plugin_Handled;
intBuff=GetClientHealth(client);
if (intBuff>=MinHealth)return Plugin_Handled;
//SetClientScreenFade( client, 255, 0, 0, 192, 1000 );
ScreenFade(client,255,0,0,192,1000,FFADE_OUT);
HealthProcess[client][HEALTH]=intBuff++;
#if !defined DEBUG	
HealthProcess[client][MEDKIT]--;
#endif 
HealthProcess[client][CURE]=1;
CreateTimer(1.0,Cure,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
SetEntityMoveType(client, MOVETYPE_NONE);
return Plugin_Handled;
}
//*************************	
public  Action Cure(Handle timer, int client){
//*************************	
if (HealthProcess[client][HEALTH]==0)return Plugin_Stop;
if (HealthProcess[client][CURE]==1)
	{
	ScreenFade(client,255,0,0,192,1000,FFADE_IN);
	HealthProcess[client][CURE]=0;
	SetEntityMoveType(client, MOVETYPE_WALK);
	}
SetClientHealth(client,HealthProcess[client][HEALTH]);
HealthProcess[client][HEALTH]+=2;
if (HealthProcess[client][HEALTH]>=MaxHealth)
	{
	HealthProcess[client][HEALTH]=0;
	ScreenFade(client,0,255,0,8,100,FFADE_IN);
	//SetClientScreenFade( client, 0, 255, 0, 8, 500 );	
	return Plugin_Stop;
	}
return Plugin_Continue;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerSpawn");
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));
	HealthProcess[client][HEALTH]=0;
	HealthProcess[client][MEDKIT]=1;
	HealthProcess[client][CURE]=0;	
	}
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerDeath %d",GetClientOfUserId(event.GetInt("userid")));
	#endif 	
	HealthProcess[GetClientOfUserId(event.GetInt("userid"))][HEALTH]=0;
	}
	
public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerHurt %d",GetClientOfUserId(event.GetInt("userid")));
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));
	if (HealthProcess[client][HEALTH]!=0)
		{
		HealthProcess[client][HEALTH]=0;
		ScreenFade(client,0,255,255,192,50,FFADE_IN,50);
		}
	}	
	

#if defined DEBUG	
public Action Command_degradate_health(int client,int args){
SetClientHealth(client,GetRandomInt(1,MinHealth-1));
}
#endif 

#endinput
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 







