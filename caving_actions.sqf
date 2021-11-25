private ["_args","_option","_cursorTarget","_cond"];

if (DZE_ActionInProgress) exitWith { cutText ["Action already in progress." , "PLAIN DOWN"]; };
DZE_ActionInProgress = true;

// params: _args = _option:string, _cursorTarget:obj
_args = _this select 3;
_option = _args select 0;
_cursorTarget = _args select 1;	

[] call fn_reset_cave_actions;

switch (_option) do {
	
	///////////////////////////////////////////////
	// CAVE BUILDING ACTIONS
	///////////////////////////////////////////////
	case "upgradeto_entrance": {
		_cond = if(DIG_Debug) then {true} else {(DIG_RequiredBuildTools call AC_fnc_hasTools) && (DIG_RequiredBuildItemsEntrance call AC_fnc_checkAndRemoveRequirements)};
		if (_cond) then {
			if( !DIG_Debug) then { 
				["Medic", DIG_MaxRange] call DIG_fnc_doAnimationAndAlertZombies;//Medic
				sleep 5;
			};
			[_cursorTarget, (getDir player), 0] call DIG_fnc_action_upgradeto_entrance;
			titleText ["Village well upgraded to Cave entrance", "PLAIN", 2];
			titleFadeOut 2;
		};
	};	
	case "downgrade_entrance": {
		_cond = if(DIG_Debug) then {true} else {DIG_RequiredBuildTools call AC_fnc_hasTools};
		if (_cond) then {
			if( !DIG_Debug) then { 
				["Medic", DIG_MaxRange] call DIG_fnc_doAnimationAndAlertZombies;
				sleep 5;
			};
			[_cursorTarget] call DIG_fnc_action_downgrade_entrance;
			titleText ["Cave entrance downgraded to Village well", "PLAIN", 2];
			titleFadeOut 2;
		};
	};
	///////////////////////////////////////////////
	// CAVE ACTIONS
	///////////////////////////////////////////////
	case "open": {
		[_cursorTarget] call DIG_fnc_action_openCave;
		titleText ["Cave entrance opened.", "PLAIN", 2];
		titleFadeOut 2;
	};
	case "close": {
		[_cursorTarget] call DIG_fnc_action_closeCave;
		titleText ["Cave entrance closed.", "PLAIN", 2];
		titleFadeOut 2;
	};
	case "getIn": {
		titleText ["Now entenring the cave...", "PLAIN", 3];
		titleFadeOut 3;
		//LastGroundPos = getPosATL player;
		//diag_log(formatText["LastGroundPos : %1", LastGroundPos]);
		[_cursorTarget] call DIG_fnc_action_enterCave;
	};
	case "getOut": {
		titleText ["Now leaving the cave...", "PLAIN", 3];
		titleFadeOut 3;
		[_cursorTarget] call DIG_fnc_action_exitCave;
	};
	case "preview": {
		[_cursorTarget] call DIG_fnc_action_previewCave;
	};
	case "test": {
		[_cursorTarget] call DIG_fnc_action_testCave;
	};
	///////////////////////////////////////////////
	// CAVE END ACTIONS
	///////////////////////////////////////////////
	case "dig": {		
		_cond = if(DIG_Debug) then {true} else {(DIG_RequiredBuildTools call AC_fnc_hasTools) && (DIG_RequiredBuildItemsStep call AC_fnc_checkAndRemoveRequirements)};
		if (_cond) then {
			if( !DIG_Debug) then { 
				["Medic", DIG_MaxRange] call DIG_fnc_doAnimationAndAlertZombies;
				sleep 6;
			};			
			[_cursorTarget] call DIG_fnc_action_digCave;			
			titleText ["Cave extended!", "PLAIN", 2];
			titleFadeOut 2;
		};
	};
	case "digExit": {		
		_cond = if(DIG_Debug) then {true} else {(DIG_RequiredBuildTools call AC_fnc_hasTools) && (DIG_RequiredBuildItemsExit call AC_fnc_checkAndRemoveRequirements)};
		if (_cond) then {
			if( !DIG_Debug) then { 
				["Medic", DIG_MaxRange] call DIG_fnc_doAnimationAndAlertZombies;
				sleep 6;
			};
			[_cursorTarget] call DIG_fnc_action_digCaveExit;			
			titleText ["Cave exit build.", "PLAIN", 2];
			titleFadeOut 2;
		};
	};	
};
DZE_ActionInProgress = false;