

if (isServer || !hasInterface) then 
{	
	//--- set the servers view distance and stuff
	setViewDistance 2000;
	setObjectViewDistance 2000;
	setTerrainGrid 3.125;
	
	// Wait until player or Headless is initialized
	if (!isServer) then
		{
			waitUntil {!isNull player && isPlayer player};
		};
		
		//--- Sort the params
		for '_i' from 0 to (count (missionConfigFile >> "Params"))-1 do 
			{
				_paramName = (configName ((missionConfigFile >> "Params") select _i));
				_value = if (isMultiplayer) then {paramsArray select _i} else {getNumber (missionConfigFile >> "Params" >> _paramName >> "default")};
				missionNamespace setVariable [_paramName, _value];
			};
		sleep 1;
		
		call compile preprocessFileLineNumbers "functions.sqf";
		
		[16,50.0,45,5] execFSM "fps_avg.fsm";
		waituntil {sleep 0.1; !isNil("fps_avg")};
		
		//--- check if headless param is on or off
		if (HEADLESS == 1) then {HEADLESSON = true} else {HEADLESSON = false};
		publicVariable "HEADLESSON";
		
		//--- check if split AI is on
		if (SPLITAI == 1) then {SPLITAION = true}else{SPLITAION = false};
		publicVariable "SPLITAION";
		
		publicVariable "LogLevel";
		
		if ((!HEADLESSON) && (SPLITAION)) exitwith {["SCRIPT STOPPED HEADLESS PARAM OFF", 1] call debug_log;};
		
	//--- run on Headless if headless on	
	if (HEADLESSON && !isServer && !hasinterface && !SPLITAION) then {
		//--- do some stuff
		_script = [] spawn {
			_i = 0;
			_aicount = 0;
			_timer = CREATETIME / 100;
			["===========AI HEADLESS TEST SETTINGS===========", 1] call debug_log;
			if (ENABLEFPSLIMIT > 0) then {["**** FPS LIMIT ON", 1] call debug_log;}else{["**** FPS LIMIT OFF", 1] call debug_log;};
			if (SPLITAI > 0) then {["**** SPLITAI ON", 1] call debug_log;}else{["**** SPLITAI OFF", 1] call debug_log;};
			[format["**** HEADLESSON = %1", HEADLESSON], 1] call debug_log;
			[format["**** FPSLIMIT = %1", FPSLIMIT], 1] call debug_log;
			[format["**** TIME PER UNIT = %1", _timer], 1] call debug_log;
			[format["**** AI PER BATCH = %1", AIPERBATCH], 1] call debug_log;
			if (ENABLEFPSLIMIT > 0) then {[format["**** BATCH   TIME = %1", (BATCHTIME / 2)], 1] call debug_log;}else{[format["**** BATCH   TIME = %1", BATCHTIME], 1] call debug_log;};
			[format["**** MAX TOTAL AI = %1", TOTALAI], 1] call debug_log;
			["=============================================", 1] call debug_log;
			_grp = createGroup west;
			while {true} do {
				if (ENABLEFPSLIMIT > 0) then {
					sleep delay_adapt;
					[format ["delay_adapt = %1",delay_adapt],2] call debug_log;
					if (fps_avg <= FPSLIMIT) then {
						[format["**FPS Wait** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount + 1], 1] call debug_log;
						waituntil {sleep _timer; fps_avg > FPSLIMIT};
					};
				} else {
				sleep _timer;
				[format ["_timer = %1",_timer],2] call debug_log;
				};
				
				helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
				_unit = "B_recon_F" createUnit [getPos helper, _grp];
				_i = _i + 1;
				_aicount = _aicount + 1;

				if (_i > (AIPERBATCH - 1)) then {
					_i = 0;
					_grp = createGroup west;
					[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
					sleep (BATCHTIME / 2);
					[format["**BATCH Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount], 1] call debug_log;
					[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
					sleep (BATCHTIME / 2);
				};

				if (_aicount >= TOTALAI) exitwith {
					[format["======== AI CREATION STOPPED @ %1 AI ========", _aicount], 1] call debug_log;
					while {true} do {
						[format["----THE END fps = %1 ::: fpsmin = %2 ::: loop %3sec ::: _aicount = %4",fps_avg,round diag_fpsmin,BATCHTIME,_aicount], 2] call debug_log;
						sleep BATCHTIME;
					};
				};
			};
		};
	};

	//--- run on server if headless off
	if (!HEADLESSON && isServer && !SPLITAION) then {
		//--- do some stuff
		_script = [] spawn {
			_i = 0;
			_aicount = 0;
			_timer = CREATETIME / 100;
			["===========AI SERVER TEST SETTINGS===========", 1] call debug_log;
			if (ENABLEFPSLIMIT > 0) then {["**** FPS LIMIT ON", 1] call debug_log;}else{["**** FPS LIMIT OFF", 1] call debug_log;};
			if (SPLITAI > 0) then {["**** SPLITAI ON", 1] call debug_log;}else{["**** SPLITAI OFF", 1] call debug_log;};
			[format["**** HEADLESSON = %1", HEADLESSON], 1] call debug_log;
			[format["**** FPSLIMIT = %1", FPSLIMIT], 1] call debug_log;
			[format["**** TIME PER UNIT = %1", _timer], 1] call debug_log;
			[format["**** AI PER BATCH = %1", AIPERBATCH], 1] call debug_log;
			[format["**** BATCH   TIME = %1", BATCHTIME], 1] call debug_log;
			[format["**** MAX TOTAL AI = %1", TOTALAI], 1] call debug_log;
			["=============================================", 1] call debug_log;
			_grp = createGroup west;
			while {true} do {
				if (ENABLEFPSLIMIT > 0) then {
					sleep delay_adapt;
					[format ["delay_adapt = %1",delay_adapt],2] call debug_log;
					if (fps_avg <= FPSLIMIT) then {
						[format["**FPS Wait** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount + 1], 1] call debug_log;
						waituntil {sleep _timer; fps_avg > FPSLIMIT};
					};
				} else {
				sleep _timer;
				[format ["_timer = %1",_timer],2] call debug_log;
				};
				
				helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
				_unit = "B_recon_F" createUnit [getPos helper, _grp];
				_i = _i + 1;
				_aicount = _aicount + 1;

				if (_i > (AIPERBATCH - 1)) then {
					_i = 0;
					_grp = createGroup west;
					[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
					sleep (BATCHTIME / 2);
					[format["**BATCH Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount], 1] call debug_log;
					[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
					sleep (BATCHTIME / 2);
				};

				if (_aicount >= TOTALAI) exitwith {
					[format["======== AI CREATION STOPPED @ %1 AI ========", _aicount], 1] call debug_log;
					while {true} do {
						[format["----THE END fps = %1 ::: fpsmin = %2 ::: loop %3sec ::: _aicount = %4",fps_avg,round diag_fpsmin,BATCHTIME,_aicount], 2] call debug_log;
						sleep BATCHTIME;
					};
				};
			};
		};
	};
	
	//--- run on headless then on server if split ai is on
	if (SPLITAION) then {
		RUNONSERVER = false;
		if (HEADLESSON && !isServer && !RUNONSERVER) then {
			//--- do some stuff
			_script = [] spawn {
				_i = 0;
				_aicount = 0;
				_timer = CREATETIME / 100;
				["===========AI HEADLESS TEST SETTINGS SPLIT===========", 1] call debug_log;
				if (ENABLEFPSLIMIT > 0) then {["**** FPS LIMIT ON", 1] call debug_log;}else{["**** FPS LIMIT OFF", 1] call debug_log;};
				if (SPLITAI > 0) then {["**** SPLITAI ON", 1] call debug_log;}else{["**** SPLITAI OFF", 1] call debug_log;};
				[format["**** HEADLESSON = %1", HEADLESSON], 1] call debug_log;
				[format["**** FPSLIMIT = %1", FPSLIMIT], 1] call debug_log;
				[format["**** TIME PER UNIT = %1", _timer], 1] call debug_log;
				[format["**** AI PER BATCH = %1", AIPERBATCH], 1] call debug_log;
				if (ENABLEFPSLIMIT > 0) then {[format["**** BATCH   TIME = %1", (BATCHTIME / 2)], 1] call debug_log;}else{[format["**** BATCH   TIME = %1", BATCHTIME], 1] call debug_log;};
				[format["**** MAX TOTAL AI = %1", TOTALAI], 1] call debug_log;
				["=============================================", 1] call debug_log;
				_grp = createGroup west;
				while {true} do {
					if (ENABLEFPSLIMIT > 0) then {
						sleep delay_adapt;
						[format ["delay_adapt = %1",delay_adapt],2] call debug_log;
						if (fps_avg <= FPSLIMIT) exitwith {
							diag_log "HEADLESS FPS LIMIT REACHED SWAPPING CREATION EXIT 1";
							RUNONSERVER = true; 
							publicVariable "RUNONSERVER";
						};
					} else {
						sleep _timer;
						[format ["_timer = %1",_timer],2] call debug_log;
					};
					
					helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
					_unit = "B_recon_F" createUnit [getPos helper, _grp];
					_i = _i + 1;
					_aicount = _aicount + 1;
					
					if (_i > (AIPERBATCH - 1)) then {
						_i = 0;
						_grp = createGroup west;
						[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
						sleep (BATCHTIME / 2);
						[format["**BATCH Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount], 1] call debug_log;
						[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
						sleep (BATCHTIME / 2);
					};
					
					if (RUNONSERVER) exitwith {diag_log "HEADLESS FPS LIMIT REACHED SWAPPING CREATION EXIT 2";};
					
					if (_aicount >= (TOTALAI / 2)) exitwith {
					[format["======== AI CREATION STOPPED @ %1 AI ========", _aicount], 1] call debug_log;
					RUNONSERVER = true; publicVariable "RUNONSERVER";
						while {true} do {
							[format["---- HCfps = %1 ::: HCfpsmin = %2 ::: loop %3sec ::: _aicount = %4", round fps_avg,round diag_fpsmin,(BATCHTIME / 2),_aicount], 2] call debug_log;
							sleep (BATCHTIME / 2);
						};
					};
				};
			};
		};
		
		//--- make the server wait until HC has finished creating
		waituntil {sleep 0.5; RUNONSERVER};
		if (HEADLESSON && isServer && RUNONSERVER) then {
			EXITSERVER = false;
			//--- do some stuff
			_script = [] spawn {
				_i = 0;
				_aicount = 0;
				_timer = CREATETIME / 100;
				["===========AI SERVER TEST SETTINGS SPLIT===========", 1] call debug_log;
				if (ENABLEFPSLIMIT > 0) then {["**** FPS LIMIT ON", 1] call debug_log;}else{["**** FPS LIMIT OFF", 1] call debug_log;};
				if (SPLITAI > 0) then {["**** SPLITAI ON", 1] call debug_log;}else{["**** SPLITAI OFF", 1] call debug_log;};
				[format["**** HEADLESSON = %1", HEADLESSON], 1] call debug_log;
				[format["**** FPSLIMIT = %1", FPSLIMIT], 1] call debug_log;
				[format["**** TIME PER UNIT = %1", _timer], 1] call debug_log;
				[format["**** AI PER BATCH = %1", AIPERBATCH], 1] call debug_log;
				if (ENABLEFPSLIMIT > 0) then {[format["**** BATCH   TIME = %1", (BATCHTIME / 2)], 1] call debug_log;}else{[format["**** BATCH   TIME = %1", BATCHTIME], 1] call debug_log;};
				[format["**** MAX TOTAL AI = %1", TOTALAI], 1] call debug_log;
				["=============================================", 1] call debug_log;
				_grp = createGroup west;
				while {true} do {
					if (ENABLEFPSLIMIT > 0) then {
						sleep delay_adapt;
						[format ["delay_adapt = %1",delay_adapt],2] call debug_log;
						if (fps_avg <= FPSLIMIT) then {
							[format["**FPS Wait** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount + 1], 1] call debug_log;
							waituntil {sleep _timer; fps_avg > FPSLIMIT};
						};
					} else {
					sleep _timer;
					[format ["_timer = %1",_timer],2] call debug_log;
					};
					
					helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
					_unit = "B_recon_F" createUnit [getPos helper, _grp];
					_i = _i + 1;
					_aicount = _aicount + 1;

					if (_i > (AIPERBATCH - 1)) then {
						_i = 0;
						_grp = createGroup west;
						[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
						sleep (BATCHTIME / 2);
						[format["**BATCH Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",fps_avg,round diag_fpsmin,round time,_aicount], 1] call debug_log;
						[format ["Batch sleep = %1",(BATCHTIME / 2)],2] call debug_log;
						sleep (BATCHTIME / 2);
					};

					if (_aicount >= TOTALAI) exitwith {
						[format["======== AI CREATION STOPPED @ %1 AI ========", _aicount], 1] call debug_log;
						while {true} do {
							[format["----THE END fps = %1 ::: fpsmin = %2 ::: loop %3sec ::: _aicount = %4",fps_avg,round diag_fpsmin,BATCHTIME,_aicount], 2] call debug_log;
							sleep BATCHTIME;
						};
					};
				};
			};
		};
	};
};