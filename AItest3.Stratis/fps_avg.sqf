// average over the last 16 diag_fps results
// introduces and updates global variable "FPS_AVG", as averaged/smoothed replacement of diag_fps
// usage execVM "fps_avg.sqf";

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
