private ["_version","_skip"];
_version = 1.00;

// redefine functions only if this file is a newer version
_skip = false;
if (!isNil "DIG_fn") then {
	if (DIG_fn >= _version) then {
		diag_log format ["evaluation of caving_fn.sqf skipped, active version %1 is newer or equal than this file (version %2)", DIG_fn, _version];
		_skip = true;
	};
};
if (_skip) exitWith {};

DIG_fn = _version;
diag_log format ["DIG_fn version %1", DIG_fn];

////////////////////////////////////////////////////////////////////////
// Global Cave functions
////////////////////////////////////////////////////////////////////////

// params: obj (entrance):object
// return: bool
DIG_fnc_isCave = {
	private ["_obj","_isCave","_linkedObj","_caveLength"];
	_obj = _this select 0;
	if ((typeOf _obj) != DIG_EntranceObjClass) exitWith { false };
	
	// cached ?
	_isCave = _obj getVariable ["isCave", 0];
	 if (_isCave > 0) exitWith { true };
	
	// Not cached, we still don't know if it's a Cave
	// use the owner nearby linked object to get infos...
	_linkedObj = [_obj] call DIG_fnc_getLinkedObj;//[_obj, DIG_LinkedObjClass, 5] call DIG_fnc_objNearby;		
	if (!isNull _linkedObj) then { 
		// _linkedObj is within 5m, so we consider it is a cave.
		_isCave = 1;
		_caveLength = round (getDir _linkedObj);
		_caveLength = if(_caveLength>300) then { 0 } else { _caveLength };
		_obj setVariable ["caveLength", _caveLength, true];
	};
	// cache it
	_obj setVariable ["isCave", _isCave, true];
	
	(_isCave  > 0)
};

/*
// params: obj (entrance):object, length:num
// return: bool
DIG_fnc_updateCave = {
	private ["_obj","_linkedObj","_caveLength"];
	
	_obj = _this select 0;
	_caveLength = _this select 1;
//	_lastCaveLength = _obj getVariable ["caveLength", 0];
	
	_linkedObj = [_obj] call DIG_fnc_getLinkedObj;
	if (!isNull _linkedObj) then { 
	
		// Change _linkedObj's direction as a trick to save Cave's length
		_linkedObj setDir _caveLength;
		_linkedObj setPosATL (getPosATL _linkedObj);
		
		// Update DB
		if(DIG_DZE_mode) then { 
			PVDZE_veh_Update = [_linkedObj,"all"];
			publicVariableServer "PVDZE_veh_Update";
		};
		
		_caveLength = round (getDir _linkedObj);
		_caveLength = if(_caveLength>300) then { 0 } else { _caveLength };
		_obj setVariable ["caveLength", _caveLength, true];
	};
};
*/

/*
// params: obj:object
// return: bool
DIG_fnc_isCaveExit = {
	private ["_obj","_b"];
	_obj = _this select 0;
	if ((typeOf _obj) != "Land_Misc_ConcPipeline_EP1") exitWith { false };
	_b = (_obj getVariable ["isCaveExit", 0] == 1);
	_b
};

// params: obj:object
// return: bool
DIG_fnc_isCaveEnd = {
	private ["_obj","_b"];
	_obj = _this select 0;
	if ((typeOf _obj) != "MAP_R2_Boulder1") exitWith { false };
	_b = (_obj getVariable ["isCaveEnd", 0] == 1);
	_b
};
*/

// params: entrance:object
// return: entrance's linked obj:object
DIG_fnc_getLinkedObj = {
	private ["_caveEntrance","_linkedObj"];
	_caveEntrance = _this select 0;
	_linkedObj = [_caveEntrance, DIG_LinkedObjClass, 5] call DIG_fnc_objNearby;
	_linkedObj
};

// params: cave:object, objClassToFind:string, dist:int
// return obj trouve ou objNull
DIG_fnc_objNearby = {	
	private ["_obj","_objClassToFind","_dist","_objNear"];
	_obj = _this select 0;
	_objClassToFind = _this select 1;
	_dist = _this select 2;	
	
	_objNear = nearestObject [_obj,_objClassToFind]; 		
	if (isNull _objNear) exitWith { objNull };
	if (_objNear distance _obj > _dist) exitWith { objNull };
	if( (_objNear getVariable ["CharacterID","0"]) != dayz_characterID) exitWith { objNull };
	/*if( (_obj getVariable ["CharacterID","0"]) != "0") then {
		if( (_objNear getVariable ["CharacterID","0"]) != dayz_characterID) exitWith { objNull };
	};*/
		
	_objNear
};




////////////////////////////////////////////////////////////////////////
// Get Entrance/Exit locations
////////////////////////////////////////////////////////////////////////
// params: cave entrance:object
// return: array 
DIG_fnc_getCaveLocation = {			// High altitude
	private ["_obj", "_location"];
	_obj = _this select 0;	
	_location = getposATL _obj;	//_location = _obj getVariable["OEMPos",(getposATL _obj)];	
	_location set [2, DIG_caveAltitude]; 
	_location
};

// params: cave entrance:object
// return: array 
DIG_fnc_getEntranceDepartureLoc = {	// -2.5m away
	private ["_obj", "_location"];
	_obj = _this select 0;
	_location = getPosATL _obj;
	_location = [_location, -2.5, (getDir _obj)] call BIS_fnc_relPos;
	_location set [2, 0]; 
	_location
};
/*
// params: cave entrance:object
// return: array 
DIG_fnc_getEntranceArrivalLoc = {	// +2.5m height
	private ["_caveEntrance","_caveloc", "_location"];
	_caveEntrance = _this select 0;
	_caveloc = [_caveEntrance] call DIG_fnc_getCaveLocation;
	_location = [_caveloc select 0, _caveloc select 1, (_caveloc select 2) + 2.5];
	_location
};*/
// params: cave loc:loc
// return: array 
DIG_fnc_getEntranceArrivalLoc = {	// +2.5m height
	private ["_caveloc", "_location"];
	_caveloc = _this select 0;
	_location = [_caveloc select 0, _caveloc select 1, (_caveloc select 2) + 2.5];
	_location
};
// params: cave entrance departure loc:loc
// return: array 
DIG_fnc_getExitArrivalLoc = {		// +0.5m height
	private ["_departureLoc", "_location"];
	_departureLoc = _this select 0;
	_location = [_departureLoc select 0, _departureLoc select 1, (_departureLoc select 2) + 1];
	_location
};
// params: cave loc:loc, cave dir:num
// return: array 
DIG_fnc_getExitDepartureLoc = {		// +1m away
	private ["_caveloc", "_caveDir", "_location"];
	_caveloc = _this select 0;
	_caveDir = _this select 1;
	_location = [_caveloc, 0.8, _caveDir] call BIS_fnc_relPos;
	_location
};

// params: cave entrance:obj
// return: new cave entrance:obj
DIG_fnc_getCaveEntrance_end = {
	private ["_caveEntrance","_caveDir","_caveLength","_caveEntranceLoc_end","_caveEntrance_end"];
	_caveEntrance = _this select 0;
	_caveDir = (getDir _caveEntrance);
	_caveLength = _caveEntrance getVariable ["caveLength", 0];
	
	_caveEntranceLoc_end = [_caveEntrance, 2.35 + ((_caveLength + 1) * DIG_stepLength), _caveDir] call BIS_fnc_relPos;
	_caveEntranceLoc_end set [2, 0.5];
	_caveEntrance_end = [_caveEntranceLoc_end, DIG_EntranceObjClass, 1] call DIG_fnc_objNearby;
	
	_caveEntrance_end
};
	
////////////////////////////////////////////////////////////////////////
// Create Cave Entrance Composition
////////////////////////////////////////////////////////////////////////
// params: _local:num, _caveEntrance:obj, _caveComp:obj
// return: _caveExit:obj
DIG_fnc_createCaveEntranceObjs = {
	private ["_local","_caveEntrance","_caveComp","_caveExit","_caveloc","_departureLoc","_arrivalLoc","_caveDir"];
	_local = _this select 0;
	_caveEntrance = _this select 1;	
	_caveComp = _this select 2;	
	_caveDir = getDir _caveEntrance;
	_caveloc = [_caveEntrance] call DIG_fnc_getCaveLocation;
	
	_caveExit = [_local,"Land_Misc_ConcPipeline_EP1",[0,0,3.85],0,[[0,0,-1],[0,1,0]], "", _caveComp ] call DIG_fnc_createObj;	// vertical pipeline
	[_local,"WoodFloorQuarter_DZ",[0,0,5],0,[[-1,0,0],[0,0,-1]], "", _caveComp ] call DIG_fnc_createObj;						// ceiling 1
	[_local,"WoodFloorQuarter_DZ",[0,0,5.2],0,[[0,1,0],[0,0,-1]], "", _caveComp ] call DIG_fnc_createObj;					// ceiling 2
	[_local,"MAP_R2_Boulder1",[0,0.9,-0.2],140,[], "", _caveComp ] call DIG_fnc_createObj;									// floor
	[_local,"MAP_R2_Boulder1",[-2,0,1.4],0,[[0,0,-1],[-0.5,0.5,0]], "", _caveComp ] call DIG_fnc_createObj;					// left side
	//[_local,"MAP_R2_Boulder1",[0.52,-0.7,1.4],0,[[0,0.2,-0.8],[-0.4,-0.6,0]], "", _caveComp ] call DIG_fnc_createObj;		// back side
	[_local,"MAP_R2_Boulder1",[-0.45, -1.9, 1.4],0,[[0,0,-1],[-0.75,-0.25,0]], "", _caveComp ] call DIG_fnc_createObj;		// back side left
	[_local,"MAP_R2_Boulder1",[1.6, -0.95, 1.3],0,[[0, 0.1, -0.9],[-0,-1,0]], "", _caveComp ] call DIG_fnc_createObj;		// back side right
	[_local,"MAP_R2_Boulder1",[2,0,1.5],0,[[0,0,1],[0.5,0.5,0]], "", _caveComp ] call DIG_fnc_createObj;					// right side
	[_local,"MAP_R2_Boulder2",[1.15,1.1,2.3],0,[[0,0,1],[0,-1,0]], "", _caveComp ] call DIG_fnc_createObj;					// right seal hole
	[_local,"MAP_R2_Boulder2",[-1.15,1.0,2.5],0,[[0,0,1],[0,-1,0]], "", _caveComp ] call DIG_fnc_createObj;					// left seal hole

	///////////////////////////////////////
	// Set Cave Entrance obj vars
	///////////////////////////////////////
	_departureLoc = [_caveEntrance] call DIG_fnc_getEntranceDepartureLoc;
	_arrivalLoc = [_caveloc] call DIG_fnc_getEntranceArrivalLoc;
		
	_caveEntrance setVariable ["isCaveLoaded", 1, true];
	_caveEntrance setVariable ["departureLoc", _departureLoc, true];
	_caveEntrance setVariable ["arrivalLoc", _arrivalLoc, true];
	
	///////////////////////////////////////
	// Set Cave Exit obj vars	
	///////////////////////////////////////
	_arrivalLoc = [_departureLoc] call DIG_fnc_getExitArrivalLoc;
	_departureLoc = [_caveloc, _caveDir] call DIG_fnc_getExitDepartureLoc;
	
	_caveExit setVariable ["isCaveExit", 1, true];
	_caveExit setVariable ["caveDir", _caveDir, true];
	_caveExit setVariable ["departureLoc", _departureLoc, true];
	_caveExit setVariable ["arrivalLoc", _arrivalLoc, true];

	_caveExit
};
// params: _local:num, _caveEntrance:obj, _caveEntrance_end,:obj _caveComp:obj
DIG_fnc_createEndCave = {

	
private ["_local","_caveEntrance","_caveEntrance_end","_caveComp","_caveLength","_caveCompLoc_end","_caveComp_end","_caveExit_end"];
_local = _this select 0;
	_caveEntrance = _this select 1;
	_caveEntrance_end = _this select 2;
	_caveComp = _this select 3;
	_caveLength = _caveEntrance getVariable ["caveLength", 0];
	
	///////////////////////////////////////
	// create end cave objects
	///////////////////////////////////////
	_caveCompLoc_end = [0, ((_caveLength + 1) * DIG_stepLength) + 2.35, 0.1 + 0.001 * _caveLength];	
	_caveComp_end = [_local, "DebugBoxPlayer_DZ", _caveCompLoc_end, 180,[], "", _caveComp ] call DIG_fnc_createObj;
	_caveExit_end = [_local, _caveEntrance_end, _caveComp_end] call DIG_fnc_createCaveEntranceObjs;
		
	///////////////////////////////////////
	// Set Cave Entrance End obj vars
	///////////////////////////////////////
	_caveEntrance_end setVariable ["isCaveOpen", 1, true];
	_caveEntrance_end setVariable ["isCaveComplete", 1, true];
	//_caveEntrance_end setVariable ["CaveEntranceObj", _caveEntrance, true];
	
	///////////////////////////////////////
	// Set Cave Entrance obj vars
	///////////////////////////////////////
	_caveEntrance setVariable ["isCaveComplete", 1, true];
	//_caveEntrance setVariable ["CaveEntranceEndObj", _caveEntrance_end, true];
	
	_caveExit_end
};

// params: _local:num, _caveEntrance:obj
// return: _caveExit:obj
DIG_fnc_createTheCave = {
	private ["_local","_caveEnd","_caveloc","_caveDir","_isCaveComplete","_caveComp","_caveExit","_i","_caveLength","_caveEntrance","_caveExit_end","_caveEntrance_end"];	
	
	_local = _this select 0;
	_caveEntrance = _this select 1;
	_caveloc = [_caveEntrance] call DIG_fnc_getCaveLocation;
	_caveDir = (getDir _caveEntrance);			
	_caveLength = _caveEntrance getVariable ["caveLength", 0];
	_isCaveComplete = 0;// _this select 2;
	//_isCaveComplete = _caveEntrance getVariable ["isCaveComplete", 0];
	
	diag_log(formatText["--- [%1,%2] DIG_fnc_createTheCave", _local,_caveEntrance]);
	
	_caveComp = [_local, "DebugBoxPlayer_DZ", _caveloc, _caveDir,[], ""] call DIG_fnc_createObj;			// object parent
	_caveComp setPosASL _caveloc;
	_caveExit = [_local, _caveEntrance, _caveComp] call DIG_fnc_createCaveEntranceObjs;						// build cave Entrance Objs
	
	[_local,"Land_Misc_ConcPipeline_EP1",[0,2.6,1.3],0,[], "", _caveComp ] call DIG_fnc_createObj;			// tunnel 1	
	// Build tunnels
	for [{_i=0}, {_i<_caveLength}, {_i=_i+1}] do {
		[_local,"Land_Misc_ConcPipeline_EP1",[0, 2.6 + ((_i +1) * DIG_stepLength), 1.301 + (_i * 0.001)],0,[], "", _caveComp ] call DIG_fnc_createObj;	// tunnel x
	};
	
	// TEST IF CAVE IS COMPLETE
	// look at direction and caveLength if a corresponding CaveEntrance is found (opposite Direction and same Length)
	// --> if a Village Well and a linkedObj next to it is found 
	_caveEntrance_end = [_caveEntrance] call DIG_fnc_getCaveEntrance_end;
	if (!isNull _caveEntrance_end) then {					
		if([_caveEntrance_end] call DIG_fnc_isCave) then {
			//_caveEntrance_end setVariable ["isCave", 1, true];
			//_caveEntrance_end setVariable ["caveLength", x, true];
			_isCaveComplete = 1;
		};
	};
			
	if(_isCaveComplete == 0) then {
		_caveEnd = [_local,"MAP_R2_Boulder1",[0.5, 4.4 + (_i * DIG_stepLength),1.65],0,[[0,0,-1],[0,1,0]], "", _caveComp ] call DIG_fnc_createObj;		// tunnel end
		_caveEnd setVariable ["isCaveEnd", 1, true];
		_caveEnd setVariable ["CaveEntranceObj", _caveEntrance, true];
		_caveEnd setVariable ["CaveCompObj", _caveComp, true];		
	} else {		
		///////////////////////////////////////
		// create end cave objects
		///////////////////////////////////////
		_caveExit_end = [_local, _caveEntrance, _caveEntrance_end, _caveComp] call DIG_fnc_createEndCave;
	};
	
	_caveExit
};
// params: _local:num, _caveEnd:obj, _newCaveLength:num, _caveComp:obj
DIG_fnc_updateCaveLength = {
	private ["_local","_caveEnd","_newCaveLength","_caveComp", "_lastTunnel","_newCaveEnd","_caveEntrance"];
	
	_local = _this select 0;
	_caveEnd = _this select 1;
	_newCaveLength = _this select 2;
	_caveComp = _this select 3;
	//_caveEndPos = getPosATL _caveEnd;
	_caveEntrance = _caveEnd getVariable ["CaveEntranceObj", objNull];
	
	// Add tunnel
	_lastTunnel = [_local,"Land_Misc_ConcPipeline_EP1",[0, 2.6 + (_newCaveLength * DIG_stepLength), 1.301 + (_newCaveLength * 0.001)],0,[], "", _caveComp ] call DIG_fnc_createObj;					// tunnel 2
	
	// Create new caveEnd
	_newCaveEnd = [_local,"MAP_R2_Boulder1",[0.5, 4.4 + (_newCaveLength * DIG_stepLength),1.65],0,[[0,0,-1],[0,1,0]], "", _caveComp ] call DIG_fnc_createObj;			// tunnel end
	_newCaveEnd setVariable ["isCaveEnd", 1, true];
	_newCaveEnd setVariable ["CaveEntranceObj", _caveEntrance, true];
	_newCaveEnd setVariable ["CaveCompObj", _caveComp, true];
	//sleep 0.5;
	
	// Smoke effect
	//[object, intensity, time, lifecheck, fade] spawn BIS_Effects_Burn;
	[_caveEnd, 0.8, time, false, true] spawn BIS_Effects_Burn_silenced;
	//sleep 0.1;	
	// Animation collapsing rocks 
	[_lastTunnel] call DIG_fnc_animRocks;
	//sleep 0.2;
	// Delete caveEnd
	[_caveEnd] call DIG_fnc_deleteObj;	
	//_caveEnd setVelocity [0,28,0];
	//player setVelocity [0,2,0];
	//player setVelocity [(sin getdir player * 5),(cos getdir player * 5),0];
};

// params: _local:num, _caveEnd:obj, _caveComp:obj
// return: _newCaveExit:obj
DIG_fnc_updateCaveComplete = {

	private ["_local","_caveEnd","_caveComp","_caveEntrance","_caveLength","_caveDir","_caveDir_end","_caveEntranceLoc_end","_caveEntrance_end","_caveExit_end"];
	
	_local = _this select 0;
	_caveEnd = _this select 1;
	_caveComp = _this select 2;
	_caveEntrance = _caveEnd getVariable ["CaveEntranceObj", objNull];
	_caveLength = _caveEntrance getVariable ["caveLength", 0];
	_caveDir = getDir _caveEntrance;
		
	///////////////////////////////////////
	// create _caveEntrance_end
	///////////////////////////////////////
	_caveEntranceLoc_end = [_caveEntrance, ((_caveLength + 1) * DIG_stepLength) + 2.35, _caveDir] call BIS_fnc_relPos;
	_caveEntranceLoc_end set [2, 0.5];
	_caveDir_end = (getDir _caveEntrance) + 180;
	_caveEntrance_end = [_local, DIG_EntranceObjClass, _caveEntranceLoc_end, _caveDir_end,[], ""] call DIG_fnc_createObj;
	[_caveEntrance_end, _caveDir_end, _caveLength] call DIG_fnc_action_upgradeto_entrance;	// creates linkedObj
		
	///////////////////////////////////////
	// create _caveExit_end
	///////////////////////////////////////
	_caveExit_end = [_local, _caveEntrance, _caveEntrance_end, _caveComp] call DIG_fnc_createEndCave;
		
	// Smoke effect
	[_caveEnd, 0.8, time, false, true] spawn BIS_Effects_Burn_silenced;
	
	// Animation collapsing rocks 
	[_caveEnd] call DIG_fnc_animRocks;
	
	// Delete caveEnd
	[_caveEnd] call DIG_fnc_deleteObj;	
	
	
	_caveExit_end
};

// params: entrance:object
// return bool
DIG_fnc_removeTheCave = {	
	private ["_caveEntrance","_i","_caveLength","_caveloc","_caveDir","_centerLoc","_caveEntrance","_objsNear"];
	_caveEntrance = _this select 0;		
	_caveloc = [_caveEntrance] call DIG_fnc_getCaveLocation;
	_caveDir = (getDir _caveEntrance);			
	_caveLength = _caveEntrance getVariable ["caveLength", 0];
	_centerLoc = [_caveloc, ((_caveLength * 3.0 )/2), _caveDir] call BIS_fnc_relPos;
	
	diag_log(formatText["_caveloc  : %1", _caveloc]); 
	diag_log(formatText["_centerLoc: %1", _centerLoc]); 
	
	_i=0;
	_objsNear = nearestObjects [_centerLoc, ["DebugBoxPlayer_DZ","Land_Misc_ConcPipeline_EP1","WoodFloorQuarter_DZ","MAP_R2_Boulder1","MAP_R2_Boulder2"], 10 + ( _caveLength * 3.0 ) ];
	{
		diag_log(formatText["near: %1", _x]); 
		[_x] call DIG_fnc_deleteObj;
		_i = _i + 1;
	} forEach _objsNear;
	
	diag_log(formatText["*** tot: %1", _i]); 
		
	_caveEntrance setVariable ["isCaveLoaded", 0, true];
	
	true
};


diag_log("*** caving_fn.sqf loaded");