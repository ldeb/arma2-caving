# arma2-caving
Mod (in development) for the Bohemia Interactive Studio's game *ArmA2*

**Ability for the user to create multiple underground caves systems**

*Last update: 2015-02-17*

## Notes
*(digged from my computer/memory, 6 years ago)*
- Intended to work with module CA, DayZ Epoch, Snap pro
- Exemple missions file in [missions.zip](missions.zip)
- Most recent scripts founded in: *[...]\Documents\ArmA 2 Other Profiles\myprofile\missions\caving.ProvingGrounds_PMC\caving\*
- Specific lines of code founded in *[...]\Documents\ArmA 2 Other Profiles\myprofile\missions\caving.ProvingGrounds_PMC\*
    - at the end of *init.sqf* file:
  ``` sqf
  if (_testclient) then {
      nul = [] call compile preprocessFileLineNumbers "caving\caving_init.sqf";
      nul = [] execVM "caving\caving.sqf";
  };
  diag_log("*** init.sqf loaded");
  ```
    - For debugging purposes, placing needed objects on the map to be ready for interaction in *mission.sqf* file