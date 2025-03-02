#include "script_component.hpp"
/*
 * Author: mharis001, Timi007
 * Initializes the VECTOR content control.
 *
 * Arguments:
 * 0: Controls Group <CONTROL>
 * 1: Default Value <ARRAY>
 * 2: Settings <ARRAY>
 *   0: Minimum Values <ARRAY>
 *   1: Maximum Values <ARRAY>
 *   2: Only Allow Integers <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [CONTROL, [0, 0, 0], [[-1, 0, nil], [nil, nil, 50], false]] call zen_dialog_fnc_gui_vector
 *
 * Public: No
 */

params ["_controlsGroup", "_defaultValue", "_settings"];
_settings params ["_min", "_max", "_onlyIntegers"];

// Only allow numeric characters to be entered
private _fnc_textChanged = {
    params ["_ctrlEdit"];

    private _filter = toArray "0123456789";
    
    if !(_ctrlEdit getVariable [QGVAR(onlyIntegers), false]) then {
        _filter pushBack (toArray "." select 0);
    };
    
    private _min = _ctrlEdit getVariable QGVAR(min);
    
    if (isNil "_min" || {_min < 0}) then {
        _filter pushBack (toArray "-" select 0);
    };

    private _text = toString (toArray ctrlText _ctrlEdit select {_x in _filter});
    _ctrlEdit ctrlSetText _text;
};

private _controls = [];

{
    private _ctrlEdit = _controlsGroup controlsGroupCtrl (IDCS_ROW_VECTOR select _forEachIndex);

    _ctrlEdit setVariable [QGVAR(min), _min param [_forEachIndex, nil]];
    _ctrlEdit setVariable [QGVAR(max), _max param [_forEachIndex, nil]];
    _ctrlEdit setVariable [QGVAR(onlyIntegers), _onlyIntegers];

    _ctrlEdit ctrlAddEventHandler ["KeyDown", _fnc_textChanged];
    _ctrlEdit ctrlAddEventHandler ["KeyUp", _fnc_textChanged];
    _ctrlEdit ctrlSetText str _x;

    _controls pushBack _ctrlEdit;
} forEach _defaultValue;

_controlsGroup setVariable [QGVAR(controls), _controls];

_controlsGroup setVariable [QFUNC(value), {
    params ["_controlsGroup"];

    private _controls = _controlsGroup getVariable QGVAR(controls);

    // Return values clipped
    _controls apply {
        private _num = parseNumber ctrlText _x;

        private _min = _x getVariable QGVAR(min);
        
        if (!isNil "_min") then {
            _num = _num max _min;
        };
        
        private _max = _x getVariable QGVAR(max);
        
        if (!isNil "_max") then {
            _num = _num min _max;
        };

        _num
    }
}];
