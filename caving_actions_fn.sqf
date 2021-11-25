private ["_version","_skip"];
_version = 1.00;

// redefine functions only if this file is a newer version
_skip = false;
if (!isNil "DIG_actions_fn") then {
	if (DIG_actions_fn >= _version) then {
		diag_log format ["evaluation of caving_actions_fn.sqf skipped, active version %1 is newer or equal than this file (version %2)", DIG_actions_fn, _version];
		_skip = true;
	};
};
if (_skip) exitWith {};

DIG_actions_fn = _version;
diag_log format ["DIG_actions_fn version %1", DIG_actions_fn];

////////////////////////////////////////////////////////////////////////
// BUILDING ACTIONS: Upgrade/Downgrade to Cave Entrance
////////////////////////////////////////////////////////////////////////
// TODO: Check if no other Cave entrances nearby (10m?)
// params: caveEntrance:object, _dir:num, _caveLength:num
DIG_fnc_action_upgradeto_entrance = {	
	private ["_caveEntrance","_dir","_location","_newloc","_newloc_bk","_caveLength"];	
	_caveEntrance = _this select 0;
	_dir = _this select 1;
	_caveLength = _this select 2;
	_location = _caveEntrance getVariable["OEMPos",(getposATL _caveEntrance)];
	
	///////////////////////////////////////
	// Change orientation
	///////////////////////////////////////
	// Change Cave orientation
	_caveEntrance setDir _dir;
	_caveEntrance setPosATL _location;	
	// Fill variables with loot	//_caveEntrance setVariable ["WeaponCargo", [["ItemGPS"],[1]],true];
	
	// Update DB, not working, reseting the Dir back..	 what about now?
	if(DIG_DZE_mode) then { 
		PVDZE_veh_Update = [_caveEntrance,"all"];//[_caveEntranceect,_type(all,position,gear,damage,killed,repair)] 
		publicVariableServer "PVDZE_veh_Update";
	};
	
	///////////////////////////////////////
	// Add an object next to the entrance, use it to store data
	///////////////////////////////////////
	//[centerPos, minDist, maxDist, minDistNearObj, waterMode, avgDiffAltitude, shoreMode,[blacklist],[defaultPos]] call BIS_fnc_findSafePos;
	_newloc_bk = [(_location select 0) + 3, _location select 1, 0];
	_newloc = [_location, 2.0, 2.4, 0.1, 0, 0, 0, [], _newloc_bk] call BIS_fnc_findSafePos;
	_newloc set [2, DIG_LinkedObjInitPosZ];
	[0, DIG_LinkedObjClass, _newloc, _caveLength, [], "DB"] call DIG_fnc_createObj;
	_caveEntrance setVariable ["caveLength", _caveLength, true];
};

// params: caveEntrance:object
DIG_fnc_action_downgrade_entrance = {	
	private ["_caveEntrance","_linkedObj"];
	_caveEntrance = _this select 0;		
	// If Cave is open, close and remove it (shouldn't be necessary)
	//[_caveEntrance] call DIG_fnc_action_closeCave;
	
	///////////////////////////////////////
	// Remove linked objects (bag)
	///////////////////////////////////////
	_linkedObj = [_caveEntrance] call DIG_fnc_getLinkedObj;
	if (!isNull _linkedObj) then {
		[_linkedObj] call DIG_fnc_deleteObj_DB;
		///////////////////////////////////////
		// Reset cached vars	
		///////////////////////////////////////		
		_caveEntrance setVariable ["isCave", 0, true];
		_caveEntrance setVariable ["caveLength", 0, true];
		// may be used later on...
		//_caveEntrance setVariable ["departureLoc", [], true];
		//_caveEntrance setVariable ["arrivalLoc", [], true];	
	};
	
};

////////////////////////////////////////////////////////////////////////
// Cave Entrance ACTIONS (open/close/getIn)
////////////////////////////////////////////////////////////////////////
// params: caveEntrance:object
DIG_fnc_action_openCave = {
	private ["_caveEntrance"];
	_caveEntrance = _this select 0;

	if(_caveEntrance getVariable ["isCaveLoaded", 0] == 0) then {
		///////////////////////////////////////
		// Cave not loaded yet, load it
		///////////////////////////////////////
		[0, _caveEntrance] call DIG_fnc_createTheCave;
		//_caveEntrance setVariable ["isCaveLoaded", 1, true];
	};
	
	///////////////////////////////////////
	// cache it
	///////////////////////////////////////
	_caveEntrance setVariable ["isCaveOpen", 1, true];
	
	///////////////////////////////////////
	// Animation Open door
	///////////////////////////////////////
	if(!DIG_Debug) then {["AmovPercMstpSnonWnonDnon_opendoor03_forgoten", 3.3] call DIG_switchMoveStop};
	//playSound("openLock");//_caveEntrance say ["openLock",10];
};

// params: caveEntrance:object
DIG_fnc_action_closeCave = {
	// TODO: check if someone is still inside...
	private ["_caveEntrance","_caveEntrance_end"];
	_caveEntrance = _this select 0;
	///////////////////////////////////////
	// Remove Cave
	///////////////////////////////////////
	if(_caveEntrance getVariable ["isCaveLoaded", 0] == 1) then {		
		[_caveEntrance] call DIG_fnc_removeTheCave;
		//_caveEntrance setVariable ["isCaveLoaded", 0, true];
		//_caveEntrance setVariable ["CaveEntranceEndObj", objNull, true];
	};
	///////////////////////////////////////
	// cache it	
	///////////////////////////////////////
	_caveEntrance setVariable ["isCaveOpen", 0, true];
	
	// Update End Cave Entrance vars
	//if( !isNull _caveEntrance getVariable ["CaveEntranceEndObj", objNull] ) then {
	if(_caveEntrance getVariable ["isCaveComplete", 0] == 1 ) then {
		_caveEntrance_end = [_caveEntrance] call DIG_fnc_getCaveEntrance_end;		
		_caveEntrance_end setVariable ["isCaveLoaded", 0, true];
		_caveEntrance_end setVariable ["isCaveOpen", 0, true];
		//_caveEntrance_end setVariable ["CaveEntranceObj", objNull, true];
	};
	
	///////////////////////////////////////
	// Animation Open door
	///////////////////////////////////////
	if(!DIG_Debug) then {["AmovPercMstpSnonWnonDnon_opendoor03_forgoten", 3.3] call DIG_switchMoveStop};
	//_caveEntrance say ["openLock",10];
};

// params: cave entrance:object
DIG_fnc_action_enterCave = {
	private ["_caveEntrance","_dir","_arrivalLoc","_departureLoc","_bkPos","_objNear"];
	
	_caveEntrance = _this select 0;	
	_dir = getDir _caveEntrance;
	_bkPos = getPosATL player;
	_departureLoc = _caveEntrance getVariable ["departureLoc", _bkPos];
	_arrivalLoc = _caveEntrance getVariable ["arrivalLoc", _bkPos];
	
	///////////////////////////////////////
	// Place player in front of the Entrance
	///////////////////////////////////////
	player setPosATL _departureLoc; // moveTo? hum, no...
	player setDir _dir;
	
	///////////////////////////////////////
	// Animation Climbing
	///////////////////////////////////////		
	player playActionNow "GetInMedium";
	// if V is pressed, changes animation!
	waitUntil{animationState player == "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinmedium"};
	
	
	[] spawn { 
		sleep 0.6;
		cutText ["","BLACK OUT", 0.5];
	};
	waitUntil{animationState player != "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinmedium"};
	
	/*player playActionNow "GetInLow";//GetInLow,GetOver,GestureSwing,Stop,GestureBark
	waitUntil{animationState player == "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinlow"};
	cutText ["","BLACK OUT",0.5];
	waitUntil{animationState player != "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinlow"};
	cutText ["","BLACK IN",0.5];*/	
	
		
	///////////////////////////////////////	
	// Set the Date temporary to a dark night
	///////////////////////////////////////	
	if(!DIG_Debug) then { 
		DIG_tempDate = date;
		setDate [(date select 0),(date select 1),(date select 2),0,0];
	};
	
	///////////////////////////////////////	
	// Teleport
	///////////////////////////////////////	
	sleep 0.5;
	playSound("getInCave");
	//_caveEntrance say ["getInCave",10];
	player setDir _dir;
	player setPosASL _arrivalLoc;
	DIG_inCave = true;
	
	cutText ["","BLACK IN",0.5];
	
	sleep 2;
	
	// get arrival object 	
	_objNear = nearestObject [_arrivalLoc, "WoodFloorQuarter_DZ"]; 		
	if (!isNull _objNear) then {
		_objNear say3D "closingDoorHard";
	};
};

////////////////////////////////////////////////////////////////////////
// Cave Exit ACTIONS (getOut)
////////////////////////////////////////////////////////////////////////
// params: cave exit:object, _lastGroundPos:loc
DIG_fnc_action_exitCave = {	
	private ["_caveExit","_arrivalLoc","_caveDir","_departureLoc","_bkPos","_objNear"];	
	
	_caveExit = _this select 0;
	_bkPos = getPos player;	//getPosATL
	_departureLoc = _caveExit getVariable ["departureLoc", _bkPos];
	_arrivalLoc = _caveExit getVariable ["arrivalLoc", _bkPos];
	_caveDir = _caveExit getVariable ["caveDir", 0];
	
	//diag_log(formatText["*** entrance: %1, exit: %2",_niceEntranceLoc,_niceExitLoc]);
	
	player setPos _departureLoc;
	player setDir (_caveDir + 180);
	// Message + anim + sound
	//["GetOutHigh","Now leaving the cave..."] call DIG_fnc_action_commonAnims;
	
	player playActionNow "GetInMedium";
	waitUntil{animationState player == "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinmedium"};
	[] spawn { 
		sleep 0.6;
		cutText ["","BLACK OUT", 0.5];
	};
	waitUntil{animationState player != "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinmedium"};
		
	///////////////////////////////////////	
	// Set the Date back to current server
	///////////////////////////////////////	
	if(!DIG_Debug) then {
		if(DIG_DZE_mode) then {
			setDate date;
		} else {
			setDate DIG_tempDate;
		}
	};
	
	///////////////////////////////////////	
	// Teleport
	///////////////////////////////////////	
	sleep 0.5;
	player setPosATL _arrivalLoc;
	DIG_inCave = false;
	
	cutText ["","BLACK IN",0.5];
	
	sleep 1;
	
	// get arrival object 	
	_objNear = nearestObject [_arrivalLoc, DIG_EntranceObjClass]; 		
	if (!isNull _objNear) then {
		_objNear say3D "closingDoor";
	};
};

DIG_fnc_action_previewCave ={

};


////////////////////////////////////////////////////////////////////////
// Cave End ACTIONS (Dig)
////////////////////////////////////////////////////////////////////////
// params: cave end:object

DIG_fnc_action_digCave = {	
	private ["_caveEnd","_caveEntrance","_newCaveLength","_linkedObj","_caveComp"];
	
	_caveEnd = _this select 0;
	_caveEntrance = _caveEnd getVariable ["CaveEntranceObj", objNull];
	_caveComp = _caveEnd getVariable ["CaveCompObj", objNull];
	//player playActionNow "GestureSwing";
	
	if(!isNull _caveEntrance && !isNull _caveComp) then {
        _newCaveLength = (_caveEntrance getVariable ["caveLength", 0]) + 1;
		//[_caveEntrance, _newCaveLength] call DIG_fnc_updateCave;
			
		_linkedObj = [_caveEntrance] call DIG_fnc_getLinkedObj;
		if (!isNull _linkedObj) then { 
		
			// Change _linkedObj's direction as a trick to save Cave's length
			_linkedObj setDir _newCaveLength;
			
			// Update DB
			if(DIG_DZE_mode) then { 
				PVDZE_veh_Update = [_linkedObj,"all"];
				publicVariableServer "PVDZE_veh_Update";
			};
			
			// set vars
			_newCaveLength = round (getDir _linkedObj);
			_newCaveLength = if(_newCaveLength>300) then { 0 } else { _newCaveLength };
			_caveEntrance setVariable ["caveLength", _newCaveLength, true];
			
			// add new step to the tunnel:
			[0, _caveEnd, _newCaveLength, _caveComp] call DIG_fnc_updateCaveLength;
		};
	};
};
// params: cave end:object

DIG_fnc_action_digCaveExit = {	

	private ["_caveEnd","_caveEntrance","_caveComp","_newCaveExit"];
	
	_caveEnd = _this select 0;
	_caveEntrance = _caveEnd getVariable ["CaveEntranceObj", objNull];
	_caveComp = _caveEnd getVariable ["CaveCompObj", objNull];
	
	if(!isNull _caveEntrance && !isNull _caveComp) then {
		
		// Test if possible de create _caveEntrance_end on the ground 
		
		// create exit objects :
		_newCaveExit = [0, _caveEnd, _caveComp] call DIG_fnc_updateCaveComplete;
		
		if (!isNull _newCaveExit) then {
			
			// set vars
			
		};
	};
};


////////////////////////////////////////////////////////////////////////
// DEBUG
////////////////////////////////////////////////////////////////////////

DIG_fnc_action_testCave = {
	private ["_obj","_type","_name"];	
	_obj = _this select 0;	
	_type = typeOf _obj;
	_name = getText(configFile >> "cfgVehicles" >> _type >> "displayName");
	
	systemChat("************");
	systemChat(format["Loc player: %1",(getposATL player)]);
	systemChat(format["%1 (%2)   %3", _name,_type,_obj]);
	systemChat(format["Dir: %1",(getDir _obj)]);
	systemChat(format["Loc: %1",(getposATL _obj)]);
	systemChat(format["Oem: %1", _obj getVariable["OEMPos",[]]]);
	
	if( _obj getVariable ["isCave", 0] == 1 ) then {		
		systemChat("------ isCave:");
		systemChat(format["isCaveOpen  : %1",	_obj getVariable ["isCaveOpen", 0]]);
		systemChat(format["isCaveLoaded: %1",	_obj getVariable ["isCaveLoaded", 0]]);
		systemChat(format["isCaveComplete: %1",	_obj getVariable ["isCaveComplete", 0]]);
		systemChat(format["departureLoc: %1",_obj getVariable ["departureLoc", []]]);
		systemChat(format["arrivalLoc  : %1",_obj getVariable ["arrivalLoc", []]]);
		systemChat(format["caveLength: %1",_obj getVariable ["caveLength", -1]]);
		//systemChat(format["CaveEntranceObj: %1",_obj getVariable ["CaveEntranceObj", -1]]);
		//systemChat(format["CaveEntranceEndObj: %1",_obj getVariable ["CaveEntranceEndObj", -1]]);
	};
	
	if( _obj getVariable ["isCaveExit", 0] == 1 ) then {		
		systemChat("------ isCaveExit:");
		systemChat(format["departureLoc: %1",_obj getVariable ["departureLoc", []]]);
		systemChat(format["arrivalLoc  : %1",_obj getVariable ["arrivalLoc", []]]);
		systemChat(format["caveDir: %1",_obj getVariable ["caveDir", []]]);
	};
	
	if( _obj getVariable ["isCaveEnd", 0] == 1 ) then {		
		systemChat("------ isCaveEnd:");
		systemChat(format["CaveEntranceObj: %1",_obj getVariable ["CaveEntranceObj", objNull]]);
		systemChat(format["CaveCompObj: %1",_obj getVariable ["CaveCompObj", objNull]]);
	};
	
	//removeAllWeapons player;	
	//player addWeapon "MeleeSledge";/ItemSledge
	
	
	[_obj] call DIG_fnc_animRocks;

	// Smoke effect
	/*_smoketheEngine = [0,"SmokeShell",(getPosATL _obj),0,[], "" ] call DIG_fnc_createObj;			// tunnel end
	sleep 2.5;
	[_smoketheEngine] call DIG_fnc_deleteObj;*/


	/*
	_departureLoc = _obj getVariable ["departureLoc", []];
	if( count _departureLoc > 0 ) then {
		player setPosATL _departureLoc;
		player setDir 0;
	};
	player playActionNow "GetInHigh";//GetInLow,GetOver,GestureSwing,Stop,GestureBark
	waitUntil{animationState player == "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinhigh"};
	[] spawn { 
		sleep 0.6;
		cutText ["","BLACK OUT", 0.5];
	};
	waitUntil{animationState player != "amovpercmstpsnonwnondnon_acrgpknlmstpsnonwnondnon_getinhigh"};
	cutText ["","BLACK IN",0.5];
	*/
	
	//player enablesimulation false;
		
	//player playMove "AmovPercMstpSnonWnonDnon_AcrgPknlMstpSnonWnonDnon_getOutMedium";
	/*
	//"_pos", "_minDist", "_maxDist", "_objNearbyDist", "_waterMode", "_maxGradient", "_shoreMode"...
	_newloc = [_loc, 0.5, 2.5, 0.2, 0, 0, 0] call BIS_fnc_findSafePos;
	_newloc set [2, (getposATL player) select 2];
	
	systemChat(format["BIS_fnc_findSafePos: %1",_newloc]);	
	
	//_newloc = [_loc, 2, random 360] call BIS_fnc_relPos;
	//systemChat(format["BIS_fnc_relPos: %1",_newloc]);
	
	_dirLookCave = [_loc, _newloc] call BIS_fnc_dirTo;
	_dirLookCave = _dirLookCave + 180;

	player setDir _dirLookCave;
	player setPosATL _newloc;
	*/
	
//	["AwopPercMstpSgthWnonDnon_end", 1] call DIG_switchMoveLoop;	// coup de poing
	
//	["AmovPercMstpSnonWnonDnon_opendoor03_forgoten", 3.3] call DIG_switchMoveStop;	// open door
	
//	player playAction "GetInMedium";
//	sleep 1.3;
	
	//["AwopPercMstpSgthWnonDnon_throw", 2] call DIG_switchMoveStop;
	
	//["DraggingAmmoBox", -1] call DIG_switchMoveStop;
	//player setVelocity [0,0,3];
};

DIG_switchMoveLoop = {	
	private ["_nb","_lanim","_nbmax"];	
	_lanim = _this select 0;
	_nbmax = _this select 1;
	_nb = 1;
	while{alive player} do {
		if(_nb > _nbmax) exitWith{};
		player switchmove _lanim;
		waitUntil{animationState player != _lanim};
		_nb = _nb + 1;
	};
};
DIG_switchMoveStop = {	
	private ["_lanim","_duree"];	
	_lanim = _this select 0;
	_duree = _this select 1;
	player switchmove _lanim;
	if( _duree > -1) then {
		sleep _duree;
		player switchMove '';
	};
};

/* MOVES
["AmovPercMstpSnonWnonDnon_opendoor01_forgoten","AmovPercMstpSnonWnonDnon_opendoor02_forgoten","AmovPercMstpSnonWnonDnon_opendoor03_forgoten",
"AidlPercMstpSnonWnonDnon01","AidlPercMstpSnonWnonDnon05","AidlPercMstpSnonWnonDnon06","AidlPercMstpSnonWnonDnon07",
"AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutLow","AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutMedium","ActsPsitMstpSnonWnonDnon_AmovPercMstpSnonWnonDnon_JumpFromWall",
"DraggingAmmoBox","AovrPercMstpSnonWnonDf","AwopPercMstpSgthWnonDnon_end"]
*/
/*
// params: action:string, msg:string
DIG_fnc_action_commonAnims = {
	// Anim player
	player playActionNow (_this select 0);//GetInLow

	// Message
	sleep 0.3;
	titleText [(_this select 1), "PLAIN DOWN", 2]; 
	titleFadeOut 1;
	
	// Sound
	//playSound "BunkerIn";
};*/

diag_log("*** caving_actions_fn.sqf loaded");