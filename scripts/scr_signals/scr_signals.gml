/// @description Signal System
///
/// Signals decouple interactables (buttons, levers) from mechanisms (doors, bridges).
/// An interactable emits a signal by channel name; any mechanism listening on that
/// channel reacts. This avoids hardcoded instance references between objects.
///
/// Usage:
///   - Designer sets `signal_channel = "door_A"` on both a button and a door.
///   - When the button is pressed, it calls signal_emit("door_A", true).
///   - The door listens for its channel and opens/closes accordingly.
///
/// This system uses a global ds_map of channels to arrays of listener structs.
///
/// ============================================================================

/// @function signal_system_init()
/// @description Initialize the global signal registry. Call once at game start
///              (e.g., in obj_game_controller Create or a persistent initializer).
function signal_system_init() {
    if (!variable_global_exists("signal_listeners")) {
        global.signal_listeners = ds_map_create();
    }
}


/// @function signal_register(_channel, _instance, _callback_name)
/// @description Register an instance to listen for signals on a channel.
///              The instance must have a method/script matching _callback_name
///              that accepts one argument: the signal value.
/// @param {string} _channel        Channel name (e.g., "door_A").
/// @param {Id.Instance} _instance  The listening instance.
/// @param {string} _callback_name  Name of the method to call on signal (e.g., "on_signal").
function signal_register(_channel, _instance, _callback_name) {
    signal_system_init();
    
    if (!ds_map_exists(global.signal_listeners, _channel)) {
        ds_map_add(global.signal_listeners, _channel, []);
    }
    
    var _list = global.signal_listeners[? _channel];
    array_push(_list, {
        instance: _instance,
        callback: _callback_name
    });
    global.signal_listeners[? _channel] = _list;
}


/// @function signal_emit(_channel, _value)
/// @description Emit a signal on a channel. All registered listeners receive it.
///              Dead instances are automatically cleaned up.
/// @param {string} _channel  Channel name to emit on.
/// @param {any} _value       The signal payload (true/false for toggles, or any data).
function signal_emit(_channel, _value) {
    signal_system_init();
    
    if (!ds_map_exists(global.signal_listeners, _channel)) return;
    
    var _list = global.signal_listeners[? _channel];
    var _clean_list = [];
    
    for (var _i = 0; _i < array_length(_list); _i++) {
        var _listener = _list[_i];
        if (instance_exists(_listener.instance)) {
            // Call the listener's callback method with the signal value
            var _inst = _listener.instance;
            if (variable_instance_exists(_inst, _listener.callback)) {
                var _method = variable_instance_get(_inst, _listener.callback);
                _method(_value);
            }
            array_push(_clean_list, _listener);
        }
        // Dead instances are simply not re-added (garbage collected)
    }
    
    global.signal_listeners[? _channel] = _clean_list;
}


/// @function signal_unregister(_channel, _instance)
/// @description Remove a specific instance from a channel's listener list.
/// @param {string} _channel        Channel to unregister from.
/// @param {Id.Instance} _instance  The instance to remove.
function signal_unregister(_channel, _instance) {
    signal_system_init();
    
    if (!ds_map_exists(global.signal_listeners, _channel)) return;
    
    var _list = global.signal_listeners[? _channel];
    var _clean_list = [];
    
    for (var _i = 0; _i < array_length(_list); _i++) {
        if (_list[_i].instance != _instance) {
            array_push(_clean_list, _list[_i]);
        }
    }
    
    global.signal_listeners[? _channel] = _clean_list;
}
