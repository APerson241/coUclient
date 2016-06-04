part of couclient;

abstract class PreferencesManager {
	static final String LS_KEY = 'cou_client_prefs';

	static String get _json => localStorage[LS_KEY];

	static set _json(String newJson) => localStorage[LS_KEY] = newJson;

	static Map<String, dynamic> get _preferences {
		return JSON.decode(_json);
	}

	static set _preferences(Map<String, dynamic> newPreferences) {
		_json = JSON.encode(newPreferences);
	}

	static void setPref(Preference pref) {
		Map<String, dynamic> load = new Map.from(_preferences);
		load[pref.id] = pref.value;
		_preferences = load;
	}

	static dynamic getPref(String id) {
		return _preferences[id];
	}
}

class PreferenceChangeEvent {
	dynamic newValue;
	Event uiEvent;

	PreferenceChangeEvent(this.newValue, this.uiEvent);
}

abstract class Preference {
	String id;
	dynamic value;
	dynamic fallback;
	Element element;
	StreamController<PreferenceChangeEvent> onChange;

	Preference(this.id, dynamic element, {this.value, this.fallback}) {
		if (value == null) {
			value = fallback;
		}

		if (element is Element) {
			this.element = element;
		} else if (element is String) {
			this.element = querySelector('#$element');
		} else {
			throw new ArgumentError(
				'Invalid reference to pref element: ${element.runtimeType}');
		}

		onChange = new StreamController();
	}
}

/// Changed with mouse
abstract class ClickPreference extends Preference {
	ClickPreference(dynamic id, dynamic input, {dynamic value, dynamic fallback})
	: super(id, input, value: value, fallback: fallback) {
		this.element.onClick.listen((MouseEvent event) {
			// Get new value
			dynamic newValue = ...;

			// Add to stream
			PreferenceChangeEvent change = new PreferenceChangeEvent(
				newValue, event);
			onChange.add(change);
		});
	}
}

/// Checkbox and toggle switch
class BoolPreference extends ClickPreference {
	BoolPreference(String id, dynamic toggle, {bool value, bool fallback: false})
	: super(id, toggle, value: value, fallback: fallback);
}

/// Slider and number
class NumPreference extends Preference {
	NumPreference(String id, dynamic input, {num value, num fallback: 0})
	: super(id, input, value: value, fallback: fallback);
}

/// Text box
class StringPreference extends Preference {
	StringPreference(String id, dynamic input, {String value, String fallback: ''})
	: super(id, input, value: value, fallback: fallback);
}

/// Radio group
class MultiPreference extends StringPreference {
	MultiPreference(String id, dynamic group, {String value, String fallback})
	: super(id, group, value: value, fallback: fallback) {
		fallback = element.children.first.attributes['name'];
	}
}

/// Keyboard control
class KeyboardPreference extends Preference {
	KeyboardPreference(String key, String col, String kbd, {
		String keyCodeValue, String keyCodeFallback
	}) : super('kbd${capitalizeFirstLetter(key)}${capitalizeFirstLetter(col)}',
		kbd, value: keyCodeValue, fallback: keyCodeFallback
	) {
		element.onClick.listen((_) {

		});
	}
}
