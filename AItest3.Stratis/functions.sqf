debug_log = {
	/* 	=== SCRIPT BY FLUIT ===
		Use a log level for writing to the RPT
		Released: 2014-06-21
		Version 1.0
		Usage example:
			LogLevel = 2; publicVariable "LogLevel";
			[format["Testing %1", "level 1"], 1] spawn debug_log;
	*/
	private ["_message", "_level"];
	_message = "";
	_level = 0;
	if (typeName _this == "ARRAY") then
	{
		_message = _this select 0;
		if (count _this > 1) then {_level = _this select 1};
	};
	if (typeName _this == "STRING") then
	{
		_message = _this;
	};
	if (isNil "LogLevel") then { LogLevel = 0; publicVariable "LogLevel"; };
	if (LogLevel >= _level) then { diag_log _message; };
};

fps_avg_loop = {
	/*	=== SCRIPT BY FRED41
		Average over the last 16 diag_fps results
		Introduces and updates global variable "FPS_AVG", as averaged/smoothed replacement of diag_fps
		Usage: [] spawn fps_avg_loop, if needed;
	*/
	private ["_fps_arr","_fps_idx","_fps_sum","_avg_num"];

	FPS_AVG = 0;
	_avg_num = 16;
	_fps_arr = [];
	_fps_arr resize _avg_num;
	{ _fps_arr set [_forEachIndex, 50.0] } foreach _fps_arr;
	_fps_idx = 0;

	while {true} do {
		_fps_arr set [_fps_idx, diag_fps];
		_fps_idx = (_fps_idx + 1) mod _avg_num;
		_fps_sum = 0;
		{ _fps_sum = _fps_sum + _x } foreach _fps_arr;
		FPS_AVG = _fps_sum / _avg_num;
		sleep(0.32); // 320ms -> max. 16 frames
	};
}; 