//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
#define nDEBUG 1
#define PLUGIN_NAME  "DoDs_medicaid"
#define PLUGIN_VERSION "1.0"
#define GAME_DOD
#include "k64t"//#include <sourcemod> 
// Global Var
//int MedicUsed[MAX_PLAYERS+1][2];

//TODO: Medkit park https://github.com/zadroot/DoD_Dropmanager/blob/master/addons/sourcemod/scripting/dropmanager/healthkit.sp

#define HEALTH 0
#define MEDKIT 1
#define CURE   2 // 4-(start action) MOVETYPE_NONE; 3-MOVETYPE_WALK, vector down; 2 - drag; 1- Cure; 0 - finish
int HealthProcess[MAX_PLAYERS+1][3];
int MinHealth,MaxHealth;
float g_DrugAngles[11] = {-2.5,-2.0,-1.5,-1.0,-0.5 , 0.0, 0.5, 1.0, 1.5, 2.0, 2.5 };
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
HookEvent("player_death",		Event_PlayerDeath);
HookEvent("player_spawn",		Event_PlayerSpawn);
HookEvent("player_hurt",		Event_PlayerHurt);
HookEvent("player_team",		Event_PlayerNotInGame);
HookEvent("player_disconnect",	Event_PlayerNotInGame);
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
//	{	
//	HealthProcess[i][HEALTH]=0;
//	HealthProcess[i][MEDKIT]=0;
	HealthProcess[i][CURE]=0;
//	}
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
HealthProcess[client][HEALTH]=intBuff++;
#if !defined DEBUG	
HealthProcess[client][MEDKIT]--;
#endif 
HealthProcess[client][CURE]=4;
SetEntityMoveType(client, MOVETYPE_NONE);
CreateTimer(1.0,Cure,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
return Plugin_Handled;
}
//*************************	
public  Action Cure(Handle timer, int client){
//*************************	
//if (HealthProcess[client][HEALTH]==0){HealthProcess[client][CURE]=0;return Plugin_Stop;}
if (HealthProcess[client][CURE]==0)return Plugin_Stop;
if (HealthProcess[client][CURE]==4)
	{
	HealthProcess[client][CURE]--;
	float angs[3];
	GetClientEyeAngles(client, angs);
	angs[0]=90.0;
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Continue;
	}
if (HealthProcess[client][CURE]==3)
	{
	HealthProcess[client][CURE]--;
	ScreenFade(client,255,0,0,192,1000,FFADE_OUT);
	float angs[3];
	GetClientEyeAngles(client, angs);	
	angs[2] = g_DrugAngles[GetRandomInt(0,10)];
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);	
	return Plugin_Continue;
	}
if (HealthProcess[client][CURE]==2)
	{		
	HealthProcess[client][CURE]--;	
	ScreenFade(client,255,0,0,192,1000,FFADE_IN);
	return Plugin_Continue;
	}
if (HealthProcess[client][CURE]==1)
	{	
	float angs[3];
	GetClientEyeAngles(client, angs);	
	angs[2] += g_DrugAngles[GetRandomInt(0,10)];
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);	
	SetEntityHealth(client,HealthProcess[client][HEALTH]);
	HealthProcess[client][HEALTH]+=2;
	if (HealthProcess[client][HEALTH]>=MaxHealth)
		{
		StopCure(client);
		HealthProcess[client][CURE]=0;		
		ScreenFade(client,0,255,0,8,100,FFADE_IN);		
		return Plugin_Stop;
		}
	}
return Plugin_Continue;
}
void StopCure(int client){
	HealthProcess[client][CURE]=0;	
	float angs[3];
	GetClientEyeAngles(client, angs);	
	angs[2] = 0.0;
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);
}

public void Event_PlayerNotInGame(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerSpawn");
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));
	HealthProcess[client][CURE]=0;	
	}
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerSpawn");
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));	
	HealthProcess[client][MEDKIT]=1;
	HealthProcess[client][CURE]=0;	
	}
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerDeath %d",GetClientOfUserId(event.GetInt("userid")));
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));
	if (HealthProcess[client][CURE]!=0)	StopCure(client);
	}	
public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerHurt %d",GetClientOfUserId(event.GetInt("userid")));
	#endif 	
	if (event.GetInt("health")!=0)
	{
		int client=GetClientOfUserId(event.GetInt("userid"));	
		if (HealthProcess[client][CURE]!=0)	
			{
			ScreenFade(client,255,255,0,192,50,FFADE_IN,50);
			StopCure(client);	
			}
	}	
}
	

#if defined DEBUG	
public Action Command_degradate_health(int client,int args){
SetEntityHealth(client,GetRandomInt(1,MinHealth-1));
}
#endif 

#endinput
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 







