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
