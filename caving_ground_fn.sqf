private ["_version","_skip"];
_version = 1.00;

// redefine functions only if this file is a newer version
_skip = false;
if (!isNil "DIG_ground_fn") then {
	if (DIG_ground_fn >= _version) then {
		diag_log format ["evaluation of caving_ground_fn.sqf skipped, active version %1 is newer or equal than this file (version %2)", DIG_ground_fn, _version];
		_skip = true;
	};
};
if (_skip) exitWith {};

DIG_ground_fn = _version;
diag_log format ["DIG_ground_fn version %1", DIG_ground_fn];

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

