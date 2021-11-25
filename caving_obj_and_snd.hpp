/*
// TOO BAD, seems impossible to make a children class from Arma built-ins
class CfgPatches {
	class Caving {
		units[]={};
		weapons[]={};
		requiredVersion=0.1;
		requiredAddons[]={
			"CAStructures_E_Misc_Misc_Well"
		};
	};
};
class CfgVehicles {
	class Land_Misc_Well_L_EP1;
	class VillageWell_DZ: Land_Misc_Well_L_EP1{
		transportMaxMagazines=1;
		transportMaxWeapons=1;
		transportMaxBackpacks=1;	
	};
};
*/
class CfgSounds {
	sounds[] = {
		BunkerIn,openLock,closingDoorHard,closingDoor
	};
	class BunkerIn {
		name="bunker_in";
		sound[]={"caving\sounds\houses-sfx-07.wss",0.5,1}; 	// found in Arma 2 Operation Arrowhead\AddOns\sounds\Ambient\houses
		titles[] = {};
	};
	
	class openLock {
		name="openLock";
		sound[]={"caving\sounds\houses-sfx-02.wss",0.5,1};
		titles[] = {};
	};
	class closingDoorHard {
		name="closingDoorHard";
		sound[]={"caving\sounds\houses-sfx-01.wss",0.5,1};
		titles[] = {};
	};
	class closingDoor {
		name="closingDoor";
		sound[]={"caving\sounds\houses-sfx-02.wss",0.5,1};
		titles[] = {};
	};
	class getInCave {
		name="getInCave";
		sound[]={"caving\sounds\padak_getIN.wss",0.5,1};
		titles[] = {};
	};
};