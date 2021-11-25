///////////////////////////////////////////////////////////////////////////////////////////////////////
// global variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

if (isNil "DIG_Debug") then { DIG_Debug = true }; // debug flag


if (isNil "DIG_DZE_mode") then { DIG_DZE_mode = false; };//!DIG_Debug
if(!DIG_DZE_mode) then {
	DZE_ActionInProgress = false;
	DZE_BuildOnRoads = false; // Default: False
	dayz_characterID = "6";	
};

//AdminList = ["","76561197966665034", "76561198087210266"];
// AdminTools present on server?
/*_isAdmin = false;
if (!isNil "AdminList") then {
	_isAdmin = (getPlayerUID player) in AdminList;
};*/

if (isNil "DIG_EntranceObjClass") then { DIG_EntranceObjClass = "Land_Misc_Well_L_EP1" };
if (isNil "DIG_LinkedObjClass") then { DIG_LinkedObjClass = "Land_Crates_EP1" }; //Land_Bag_EP1
if (isNil "DIG_LinkedObjInitPosZ") then { DIG_LinkedObjInitPosZ = 0 }; // + diameter

if (isNil "DIG_MaxRange") then { DIG_MaxRange = 25 }; // zombie alert in m
if (isNil "DIG_CursorDist") then { DIG_CursorDist = 4 }; // cursor detection range in m

// Cherno offset = 15360
// Land_Dirthump03
// Land_Misc_ConcPipeline_EP1
// MAP_R2_Rock1
// MAP_Wall_VilVar2_4_2 (mur bois)

if (isNil "DIG_RequiredBuildTools") then { DIG_RequiredBuildTools = []};//"ItemToolbox", "ItemCrowbar"] }; // required tools for building an tunnel entrance/exit/step
if (isNil "DIG_RequiredBuildItemsEntrance") then { DIG_RequiredBuildItemsEntrance = [] }; // required items to build an entrance
if (isNil "DIG_RequiredBuildItemsExit") then { DIG_RequiredBuildItemsExit = [] }; // required items to build an exit
if (isNil "DIG_RequiredBuildItemsStep") then { DIG_RequiredBuildItemsStep = [] };//["CinderBlocks",2]] }; // required items to build an tunnel step

// DO NOT CHANGE:
if (isNil "DIG_stepLength") then { DIG_stepLength = 2.8; };
if (isNil "DIG_caveAltitude") then { DIG_caveAltitude = if(DIG_Debug) then {5} else {2500}; }; // debug

///////////////////////////////////////////////////////////////////////////////////////////////////////


if(DIG_DZE_mode) then{
	// Wait for the player full ingame so we can add the action-menu entry 
	// Wait for the character to load all required items
	waitUntil {!isNil "dayz_animalCheck"}; 
} else {
	DZE_ActionInProgress = false;
	dayz_characterID = "0";
	
	DZE_BuildOnRoads = false; // Default: False
};

//caving_selfActions = compile preprocessFileLineNumbers "custom\caving\caving_selfActions.sqf";
//caving_loop = compile preprocessFileLineNumbers "custom\caving\caving_loop.sqf";



cavingInitLoaded = true;
diag_log("*** caving_init.sqf loaded");


/************************************************************
	Relative Position

Parameters: [object or position, distance, direction]

Returns a position that is a specified distance and compass
direction from the passed position or object.

Example: [player, 5, 100] call BIS_fnc_relPos
************************************************************/

/*
BIS_fnc_buildingPositions
Get all available positions within a building or structure. 
*/

/* 
pushBack
Insert an element to the back of the given array. This command modifies the original array.
_arr = [1,2,3]; _arr pushBack 4;
 hint str _arr; //[1,2,3,4]
*/