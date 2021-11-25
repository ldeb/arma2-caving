private ["_actions_script","_vehicle","_inVehicle","_onLadder","_canDo","_ownerID","_isPZombie","_cursorTarget","_typeOfCursorTarget","_isCave","_isCaveOpen","_isEventualCaveEntrance","_isOwnCaveEnd","_isCaveExit","_canDig"];

//waituntil {!isnil "bis_fnc_init"};

waitUntil{!isNil "cavingInitLoaded"};
sleep 0.3;
// Temporisation de sécurité pour mission MP : pour connexion rapide (LAN), il vaut mieux vérifier de
// l'existence du joueur, et temporiser, sans quoi les scripts destinés au joueur se lance "dans le vide"
waituntil{player iskindof "man"};
sleep 0.3;
waituntil{alive player};
sleep 0.3;
///////////////////////////////////////////////
// INCLUDES
///////////////////////////////////////////////
//[]execVM "caving\ac_functions.sqf";
[] call compile preprocessFileLineNumbers "caving\ac_functions.sqf";
[] call compile preprocessFileLineNumbers "caving\caving_fn_utils.sqf";
[] call compile preprocessFileLineNumbers "caving\caving_fn.sqf";
[] call compile preprocessFileLineNumbers "caving\caving_actions_fn.sqf";
_actions_script = "caving\caving_actions.sqf";
///////////////////////////////////////////////
// INIT
///////////////////////////////////////////////
DIG_tempDate = [];
DIG_inCave = false;

// Reset Action-Menu cvars
s_player_cave_upgradeto_entrance = -1;
s_player_cave_downgrade_entrance = -1;
s_player_cave_open = -1;
s_player_cave_close = -1;
s_player_cave_test = -1;
s_player_cave_getin = -1;
s_player_cave_getout = -1;
s_player_cave_dig = -1;
s_player_cave_dig_exit = -1;
s_player_cave_preview = -1;

fn_reset_cave_actions = {
	player removeAction s_player_cave_downgrade_entrance;
	s_player_cave_downgrade_entrance = -1;
	player removeAction s_player_cave_upgradeto_entrance;
	s_player_cave_upgradeto_entrance = -1;
	player removeAction s_player_cave_test;
	s_player_cave_test = -1;
	player removeAction s_player_cave_open;
	s_player_cave_open = -1;
	player removeAction s_player_cave_close;
	s_player_cave_close = -1;
	player removeAction s_player_cave_getout;
	s_player_cave_getout = -1;
	player removeAction s_player_cave_getin;
	s_player_cave_getin = -1;
	player removeAction s_player_cave_dig;
	s_player_cave_dig = -1;
	player removeAction s_player_cave_dig_exit;
	s_player_cave_dig_exit = -1;
	player removeAction s_player_cave_preview;
	s_player_cave_preview = -1;
};

//player addEventHandler ["AnimChanged", "systemChat(format['AnimChanged %1',_this select 1])"];

//player addEventHandler ["AnimDone", "_txt=format['AnimDone %1',_this select 1]; systemChat(_txt);"];

//player addEventHandler ["GetOutMedium", "_txt=format['GetOut %1',_this select 1]; systemChat(GetOut); diag_log(GetOut)"];
	
///////////////////////////////////////////////
// Starting the check loop
///////////////////////////////////////////////
while{alive player} do {

	sleep 2;
	
	//diag_log(formatText["anim: %1", (animationState player)]);
	//diag_log(formatText["BIS? %1", (!isNil "BIS_fnc_init")]);
	//diag_log(formatText["BIS? %1", (!isNil "BIS_fnc_relPos")]);
	
	//hint formatText["animationState: %1", (animationState player)];
	
	
	// Do not allow if any script is running.		
	if (!DZE_ActionInProgress) then {
	
		_vehicle = vehicle player;
		_inVehicle = (_vehicle != player);
		_onLadder =	(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
		_canDo = !_onLadder;
		
		// Dayz Epoch mode :
		if(DIG_DZE_mode) then {
			_isPZombie = player isKindOf "PZombie_VB";
			_canDo = _canDo && (!_isPZombie && !r_drag_sqf && !r_player_unconscious);
		};
		
		// Has some kind of target
		if (!isNull cursorTarget && !_inVehicle && (player distance cursorTarget < DIG_CursorDist) && _canDo) then {
			
			_cursorTarget = cursorTarget;
			_typeOfCursorTarget = typeOf _cursorTarget;
			_ownerID = _cursorTarget getVariable ["CharacterID","0"];			
			// get items && magazines only once			//_magazinesPlayer = magazines player;
			
			///////////////////////////////////////////////
			// ACTION TEST
			///////////////////////////////////////////////
			if (s_player_cave_test < 0) then {
				s_player_cave_test = player addAction ["<t color=""#ffffff"">test</t>", _actions_script, ["test",_cursorTarget], 0, false];
			};
			
			//////////////////////////////////////////////////////////////////////////////////////////////
			// OUTSIDE CAVE - CAVE ENTRANCE ACTIONS :
			//////////////////////////////////////////////////////////////////////////////////////////////
			
			_isEventualCaveEntrance = (_typeOfCursorTarget == DIG_EntranceObjClass);//&& ([_cursorTarget] call DIG_elem_onGround);
			if (!DIG_inCave && _isEventualCaveEntrance) then {	
			
				// Is eventual Cave Entrance
				
				_isCave = [_cursorTarget] call DIG_fnc_isCave;
				if (!_isCave ) then {	
				
					// Is not a Cave yet		
					
					if(_ownerID == dayz_characterID) then {
					
						// Is own Eventual Cave Entrance
						
						///////////////////////////////////////////////
						// OWNER ACTION UPGRADE TO ENTRANCE
						///////////////////////////////////////////////
						if (s_player_cave_upgradeto_entrance < 0) then {
							s_player_cave_upgradeto_entrance = player addAction ["<t color=""#ffffff"">Upgrade to Cave Entrance</t>", _actions_script, ["upgradeto_entrance", _cursorTarget], 1, true];
						};
						///////////////////////////////////////////////
						// OWNER ACTION SET CAVE DIRECTION
						///////////////////////////////////////////////
						
					};
					
				} else {		
					
					// Is already a Cave, Entrance actions
					
					_isCaveOpen = _cursorTarget getVariable ["isCaveOpen", 0];					
					if( _isCaveOpen != 1 ) then {
					
						// Cave not opened yet	
						
						if(_ownerID == dayz_characterID) then {
							// Is own Cave Entrance
							///////////////////////////////////////////////
							// OWNER ACTION OPEN
							///////////////////////////////////////////////
							if (s_player_cave_open < 0) then {
								s_player_cave_open = player addAction ["<t color=""#ffffff"">Open Cave</t>", _actions_script, ["open",_cursorTarget], 1, false];
							};							
							///////////////////////////////////////////////
							// OWNER ACTION DOWNGRADE ENTRANCE
							///////////////////////////////////////////////
							if (s_player_cave_downgrade_entrance < 0) then {
								s_player_cave_downgrade_entrance = player addAction ["<t color=""#ffffff"">Definitively close Cave Entrance</t>", _actions_script, ["downgrade_entrance",_cursorTarget], 0, false];
							};
						};
						
					} else {
					
						// Cave already opened
						
						///////////////////////////////////////////////
						// PUBLIC ACTION GET IN 
						///////////////////////////////////////////////
						if (s_player_cave_getin < 0) then {
							s_player_cave_getin = player addAction ["<t color=""#ffffff"">Get in Cave</t>", _actions_script, ["getIn",_cursorTarget], 1, false];
						};
						
						if(_ownerID == dayz_characterID) then {
							///////////////////////////////////////////////
							// OWNER ACTION CLOSE
							///////////////////////////////////////////////
							if (s_player_cave_close < 0) then {
								s_player_cave_close = player addAction ["<t color=""#ffffff"">Close Cave</t>", _actions_script, ["close",_cursorTarget], 0, false];
							};
							///////////////////////////////////////////////
							// ACTION PREVIEW
							///////////////////////////////////////////////
							/*if (s_player_cave_preview < 0) then {
								s_player_cave_preview = player addAction ["<t color=""#ffffff"">Preview Construction plans</t>", _actions_script, ["preview",_cursorTarget], 0, false];
							};*/
						};					
					};
				};
			} else {
				player removeAction s_player_cave_upgradeto_entrance;
				s_player_cave_upgradeto_entrance = -1;	
				player removeAction s_player_cave_open;
				s_player_cave_open = -1;
				player removeAction s_player_cave_downgrade_entrance;
				s_player_cave_downgrade_entrance = -1;
				player removeAction s_player_cave_getin;
				s_player_cave_getin = -1;
				player removeAction s_player_cave_close;
				s_player_cave_close = -1;
			};
			
			//////////////////////////////////////////////////////////////////////////////////////////////
			// INSIDE CAVE
			//////////////////////////////////////////////////////////////////////////////////////////////
			if ( DIG_inCave ) then {
			
				//////////////////////////////////////////////////////////////////////////////////////////////
				// CAVE EXIT ACTIONS
				//////////////////////////////////////////////////////////////////////////////////////////////
				
				_isCaveExit = (_typeOfCursorTarget == "Land_Misc_ConcPipeline_EP1") && (_cursorTarget getVariable ["isCaveExit", 0] == 1);			
				if ( _isCaveExit ) then {	
					///////////////////////////////////////////////
					// PUBLIC ACTION GET OUT 
					///////////////////////////////////////////////
					if (s_player_cave_getout < 0) then {
						s_player_cave_getout = player addAction ["<t color=""#ffffff"">Get out!</t>", _actions_script, ["getOut",_cursorTarget], 1, true];
					};
				} else {				
					player removeAction s_player_cave_getout;
					s_player_cave_getout = -1;
				};
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				// CAVE END ACTIONS
				//////////////////////////////////////////////////////////////////////////////////////////////
				
				_isOwnCaveEnd = (_typeOfCursorTarget == "MAP_R2_Boulder1") && (_cursorTarget getVariable ["isCaveEnd", 0] == 1) && (_ownerID == dayz_characterID);
				_canDig = true;	//check if has a SledgeHammer in hand
				if ( _isOwnCaveEnd && _canDig ) then {
					///////////////////////////////////////////////
					// PRIVATE ACTION DIG, finally
					///////////////////////////////////////////////
					if (s_player_cave_dig < 0) then {
						s_player_cave_dig = player addAction ["<t color=""#ffffff"">Dig!</t>", _actions_script, ["dig",_cursorTarget], 1, true, false];
					};
					///////////////////////////////////////////////
					// PRIVATE ACTION create End Cave Exit
					///////////////////////////////////////////////
					if (s_player_cave_dig_exit < 0) then {
						s_player_cave_dig_exit = player addAction ["<t color=""#ffffff"">Dig cave Exit</t>", _actions_script, ["digExit",_cursorTarget], 0, false];
					};
				} else {
					player removeAction s_player_cave_dig;
					s_player_cave_dig = -1;
					player removeAction s_player_cave_dig_exit;
					s_player_cave_dig_exit = -1;
				};
				
			};

		} else { // No target
			[] call fn_reset_cave_actions;
		};
	};
};
if( ! alive player ) then {	
	DIG_inCave = false;
};
/*while {alive player} do {
	[] call caving_selfActions;
	Sleep 2;
};*/

diag_log "*** caving.sqf loaded";