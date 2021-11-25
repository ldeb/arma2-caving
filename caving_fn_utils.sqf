private ["_version","_skip"];
_version = 1.00;

// redefine functions only if this file is a newer version
_skip = false;
if (!isNil "DIG_fn_utils") then {
	if (DIG_fn_utils >= _version) then {
		diag_log format ["evaluation of caving_fn_utils.sqf skipped, active version %1 is newer or equal than this file (version %2)", DIG_fn_utils, _version];
		_skip = true;
	};
};
if (_skip) exitWith {};

DIG_fn_utils = _version;
diag_log format ["DIG_fn_utils version %1", DIG_fn_utils];

fnc_SetPitchBankYaw = { 	
	private ["_object","_rotations","_aroundX","_aroundY","_aroundZ","_dirX","_dirY","_dirZ","_upX","_upY","_upZ","_dir","_up","_dirXTemp", "_upXTemp"]; 
	_object = _this select 0; 
	_rotations = _this select 1; 
	_aroundX = _rotations select 0;
	_aroundY = _rotations select 1; 
	_aroundZ = (360 - (_rotations select 2)) - 360; 
	_dirX = 0;
	_dirY = 1; 
	_dirZ = 0; 
	_upX = 0;
	_upY = 0; 
	_upZ = 1; 	
	if (_aroundX != 0) then { 
		_dirY = cos _aroundX; 
		_dirZ = sin _aroundX; 
		_upY = -sin _aroundX; 
		_upZ = cos _aroundX; 
	}; 	
	if (_aroundY != 0) then { 
		_dirX = _dirZ * sin _aroundY; 
		_dirZ = _dirZ * cos _aroundY; 
		_upX = _upZ * sin _aroundY; 
		_upZ = _upZ * cos _aroundY; 
	};
	if (_aroundZ != 0) then { _dirXTemp = _dirX; 
		_dirX = (_dirXTemp* cos _aroundZ) - (_dirY * sin _aroundZ); 
		_dirY = (_dirY * cos _aroundZ) + (_dirXTemp * sin _aroundZ); 
		_upXTemp = _upX; 
		_upX = (_upXTemp * cos _aroundZ) - (_upY * sin _aroundZ); 
		_upY = (_upY * cos _aroundZ) + (_upXTemp * sin _aroundZ); 
	}; 
	_dir = [_dirX,_dirY,_dirZ]; 
	_up = [_upX,_upY,_upZ]; 
	_object setVectorDirAndUp [_dir,_up]; 
}; 

////////////////////////////////////////////////////////////////////////
// Create/Delete objects
////////////////////////////////////////////////////////////////////////
// exemple: _caveComp = [_local, "DebugBoxPlayer_DZ", _caveloc, _caveDir,[], ""] call DIG_fnc_createObj;	// player: [210, 1540]
// params: local:bool, objClass:string, dir, loc, vectorDirUp, [action], [_comp]
// return: new obj created
DIG_fnc_createObj = {	
	private ["_local","_newclass","_newloc","_newdir","_vectorDirUp","_action","_comp", "_newobj","_newloc_bk"];
	
	_local = _this select 0;
	_newclass = _this select 1;
	_newloc = _this select 2;
	_newdir = _this select 3;
	_vectorDirUp = _this select 4;
	
	diag_log(formatText["--- DIG_fnc_createObj  : %1,%2,%3,%4,%5", _local,_newclass,_newloc,_newdir,_vectorDirUp]);
	
	_newloc_bk = [] + _newloc;
	
	if( (count _this) > 6 ) then {	// attachedTo
		_newloc = [0,0,DIG_caveAltitude];	
	};
	if(_local == 1) then {
		_newobj = _newclass createVehicleLocal _newloc;
	} else {
		_newobj = createVehicle [_newclass, _newloc, [], 0, "CAN_COLLIDE"];
	};
	_newobj addEventHandler ["HandleDamage", { false }];
	_newobj setVariable ["CharacterID", dayz_characterID, true];//_playerUID
	_newobj setVariable ["Classname", _newclass, true];
	
	if( (count _this) > 6 ) then {	// attachedTo
		_newloc = _newloc_bk;
		_comp = _this select 6;
		_newobj attachTo [_comp, _newloc];
	};	
	_newobj setDir _newdir;		
	if(count _vectorDirUp > 0) then {
		_newobj setVectorDirAndUp _vectorDirUp;		
	};
	//_newobj setPosATL _newloc;
	_newobj setVariable ["OEMPos", (getPosATL _newobj), true];
		
	// PUBLISH OBJECT TO DB ?
	if( (count _this) > 5 ) then {
		_action = _this select 5;
		if(_action == "DB" && DIG_DZE_mode) then {
			//[dayz_characterID,_tent,[_dir,_location],"TentStorage"]
			PVDZE_obj_Publish = [dayz_characterID, _newobj, [_newdir, _newloc], _newclass];
			publicVariableServer "PVDZE_obj_Publish";	
			//player reveal _newobj; ?
		};
	};
	_newobj
};


// params: [animation:string, range:number]
DIG_fnc_doAnimationAndAlertZombies = {
	private ["_animation","_range"];
	_animation = _this select 0;
	_range = _this select 1;
	player playActionNow _animation;
	if(DIG_DZE_mode) then {[player,_range,true,(getPosATL player)] spawn player_alertZombies;};
};

// https://community.bistudio.com/wiki/ParticleArray
// params: _obj
DIG_fnc_animRocks = {
	private ["_obj","_PS"];
	_obj = _this select 0;	
	
	_PS = "#particlesource" createVehicleLocal getpos _obj;
	_PS setParticleCircle [0, [0, 0, 0]];
	_PS setParticleRandom [0, [1.5, 1.5, 0], [0.25, 0.25, 0], 0, 1, [0, 0, 0, 0], 0, 0];
	_PS setParticleParams [
		["\Ca\Data\ParticleEffects\Pstone\Pstone.p3d", 8, 3, 1, 1], "", 
		"SpaceObject", 
		1, 
		1, 				// Lifetime
		[0, 0, 1.5], 		// pos
		[0, 0, -1.1], 	// velocity
		0.6, 10, 1, 0.8, 	// rotationVel,weight,volume,rubbing 0.2
		[1, 1], 
		[[1, 1, 1 ,1], [1, 1, 1, 1], [1, 1, 1, 1]], 
		[0, 1], 
		1, 0, "", "", _obj
	];
	_PS setDropInterval 0.005;
	sleep 0.7;
	_PS setDropInterval 0;
	
};

////////////////////////////////////////////////////////////////////////
// Create/Delete objects
////////////////////////////////////////////////////////////////////////
// params: obj:object
DIG_fnc_deleteObj = {
	private ["_obj"];
	_obj = _this select 0;
	deleteVehicle _obj
};
// params: obj:object id
DIG_fnc_deleteObj_DB = {	
	private ["_obj","_objectID","_objectUID"];
	_obj = _this select 0;
	if(DIG_DZE_mode) then {
		_objectID = _obj getVariable["ObjectID","0"];
		_objectUID = _obj getVariable["ObjectUID","0"];
		PVDZE_obj_Delete = [_objectID,_objectUID,player];	//PVDZE_obj_Delete = [_objectID,_objectUID]
		publicVariableServer "PVDZE_obj_Delete";
	};
	deleteVehicle _obj;	
};

// Object less then 1m near the ground;
// params: obj:object
// return: bool
DIG_elem_onGround = {	
    private ["_obj","_height"];
    _obj = _this select 0;
	_height = _obj getVariable["OEMPos",(getposATL _obj)];
	_height = _height select 2;
	_height = if(_height < 0) then {_height * -1} else { _height };
	(_height < 1)			
};
