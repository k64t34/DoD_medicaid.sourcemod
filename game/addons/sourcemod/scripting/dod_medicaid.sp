//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
#define DEBUG 
#define LOG 
#define PLUGIN_AUTHOR "Kom64t"
#define PLUGIN_NAME  "DoDs_medicaid"
#define PLUGIN_VERSION "1.1"
#define SND_SPRINT "player\\sprint.wav" 
#define GAME_DOD
#include "k64t"//#include <sourcemod> 
// Global Var
//int MedicUsed[MAX_PLAYERS+1][2];

//TODO: Medkit park https://github.com/zadroot/DoD_Dropmanager/blob/master/addons/sourcemod/scripting/dropmanager/healthkit.sp
//TODO: Выносливость пропорциональна здоровью https://github.com/zadroot/DoD_StaminaHealth/blob/master/scripting/dod_staminahealth.sp
#define HEALTH 0 
#define MEDKIT 1 // Количество аптечек. По умолчанию одна.
#define CURE   2 // Этапы лечение с 4 по 0: 4-(start action) MOVETYPE_NONE; 3-MOVETYPE_WALK, vector down; 2 - drag; 1- Cure; 0 - finish

int HealthProcess[MAX_PLAYERS+1][4];
#define MAXdragAngle 10.0
float g_maxDragAngle=MAXdragAngle;
float g_minDragAngle=-MAXdragAngle;
#define dpDRIFT 0 
#define dpSTEP 1 
float DriftProcess[MAX_PLAYERS+1][2]; // Угол поворота взгляда при лечении

char g_snd_SPRINT[] = SND_SPRINT;

int MinHealth,MaxHealth;
//float g_DrugAngles[11] = {-3.5,-2.4,-1.3,-0.5,-0.1 , 0.0, 1.1, 2.2, 3.3, 4.4, 5.5 };
//float g_DrugAngles[11] = {-5.0,-4.0,-3.0,-2.0,-1.0 , 0.0, 0.1, 0.2, 0.3, 0.4, 0.5 };

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
cvarMaxHealth	= CreateConVar( "medicaid_MaxHealth", "60");
AutoExecConfig(true, PLUGIN_NAME);
MinHealth=GetConVarInt(cvarMinHealth);
MaxHealth=GetConVarInt(cvarMaxHealth);
for (int i=1;i<=MaxClients;i++)
	{	
//	HealthProcess[i][HEALTH]=0;
//	HealthProcess[i][MEDKIT]=0;
	HealthProcess[i][CURE]=0;	
	}
PrecacheSound(g_snd_SPRINT,true);	
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
{
char clientName[32];GetClientName(client, clientName, 31);
DebugPrint("Command_medic %s",clientName);
LogMessage("Command_medic %s",clientName);
}
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
#if defined LOG 
{char clientName[32];GetClientName(client, clientName, 31);
LogMessage("Player %s use medic",clientName);}
#endif
#if defined DEBUG
{char clientName[32];GetClientName(client, clientName, 31);
LogMessage("Player %s use medic",clientName);}
#endif


return Plugin_Handled;
}
//*************************	
public  Action Cure(Handle timer, int client){
//*************************	
//if (HealthProcess[client][HEALTH]==0){HealthProcess[client][CURE]=0;return Plugin_Stop;}
#if defined DEBUG	
	char clientName[32];GetClientName(client, clientName, 31);
	DebugPrint("Cure %s",clientName);
#endif
if (HealthProcess[client][CURE]==0)return Plugin_Stop;
if (HealthProcess[client][CURE]==4)
	{
	 
	 //EmitSoundToClient(client,g_snd_SPRINT,SOUND_FROM_PLAYER,SNDCHAN_BODY,SNDLEVEL_NORMAL,SNDVOL_NORMAL); //CHAN_BODY
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
	//angs[2] = g_DrugAngles[GetRandomInt(0,10)];
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
	DriftProcess[client][dpDRIFT]=0.0;
	CreateTimer(1.0,Cure1,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
	/*float angs[3];
	GetClientEyeAngles(client, angs);	
	//angs[2] += g_DrugAngles[GetRandomInt(0,10)];
	angs[2] += 	GetRandomFloat(-10.0,10.0);
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);	
	SetEntityHealth(client,HealthProcess[client][HEALTH]);
	HealthProcess[client][HEALTH]+=2;
	if (HealthProcess[client][HEALTH]>=MaxHealth)
		{
		StopCure(client);
		HealthProcess[client][CURE]=0;		
		ScreenFade(client,0,255,0,8,100,FFADE_IN);		
		return Plugin_Stop;
		} */
	}
return Plugin_Continue;
}
//*************************	
public  Action Cure1(Handle timer, int client){
//*************************	
#if defined DEBUG	
	char clientName[32];GetClientName(client, clientName, 31);
	DebugPrint("Cure1 %s",clientName);
#endif
if (HealthProcess[client][CURE]==0)return Plugin_Stop;
if (DriftProcess[client][dpDRIFT]==0.0)
{
	DriftProcess[client][dpDRIFT]=GetRandomFloat(g_minDragAngle,g_maxDragAngle);
	//DebugPrint("DriftProcess [DRIFT]= %f",DriftProcess[client][dpDRIFT]);
	if (DriftProcess[client][dpDRIFT]>0.0)DriftProcess[client][dpSTEP]=2.0;
	else if (DriftProcess[client][dpDRIFT]<0.0)DriftProcess[client][dpSTEP]=-2.0;
	//DebugPrint("DriftProcess [STEP]= %f",DriftProcess[client][dpSTEP]);
}

DriftProcess[client][dpDRIFT]-=DriftProcess[client][dpSTEP];
float angs[3];
GetClientEyeAngles(client, angs);
if (DriftProcess[client][dpSTEP]>0.0 && DriftProcess[client][dpDRIFT]<0.0 || 
	DriftProcess[client][dpSTEP]<0.0 && DriftProcess[client][dpDRIFT]>0.0)
	{
	DriftProcess[client][dpDRIFT]=0.0;
	angs[2]=0.0;
	}
//DebugPrint("DriftProcess [DRIFT]= %f",DriftProcess[client][dpDRIFT]);
//DebugPrint("angs= %f DriftProcess [STEP]= %f",angs[2],DriftProcess[client][dpSTEP]);
angs[2] += DriftProcess[client][dpSTEP];
//DebugPrint("angs= %f",angs[2]);
if (angs[2] <g_minDragAngle) {angs[2]=g_minDragAngle;DriftProcess[client][dpDRIFT]=0.0;}
else if (g_maxDragAngle < angs[2] ) {angs[2]=g_maxDragAngle;DriftProcess[client][dpDRIFT]=0.0;}
//DebugPrint("angs= %f",angs[2]);
TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);

/*float angs[3];
GetClientEyeAngles(client, angs);	
float drift=GetRandomFloat(-10.0,10.0);
angs[2] += drift;
if (angs[2] <-30.0 || 30.0 > angs[2] ){if (drift>0) {angs[2] =30;}else  {angs[2] =-30;}}
TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);	*/
SetEntityHealth(client,HealthProcess[client][HEALTH]);
HealthProcess[client][HEALTH]+=1;
//int h=GetRandomInt(0,10);
//if (h>5) {HealthProcess[client][HEALTH]+=1;
//#if defined DEBUG	
//	char clientName[32];GetClientName(client, clientName, 31);
//	DebugPrint("Cure1 %s +1",clientName);
//#endif
//}
if (HealthProcess[client][HEALTH]>=MaxHealth)
	{
	StopCure(client);
	HealthProcess[client][CURE]=0;		
	ScreenFade(client,0,255,0,8,100,FFADE_IN);		
	return Plugin_Stop;
	}	
else
{
ScreenFade(client,0,128,0,8,10,FFADE_IN);	
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
	//DebugPrint("Event_PlayerSpawn");
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));
	HealthProcess[client][CURE]=0;	
	}
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	//DebugPrint("Event_PlayerSpawn");
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));	
	HealthProcess[client][MEDKIT]=1;
	HealthProcess[client][CURE]=0;		
	}
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	//DebugPrint("Event_PlayerDeath %d",GetClientOfUserId(event.GetInt("userid")));
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));
	if (HealthProcess[client][CURE]!=0)	StopCure(client);
	}	
public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	//DebugPrint("Event_PlayerHurt %d",GetClientOfUserId(event.GetInt("userid")));
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
return Plugin_Continue ;
}
#endif 

#endinput
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 







