part of couclient;

class PreferencesWindow extends Modal {
	String id = 'settingsWindow';

	PreferencesWindow() {
		prepare();

		final List<Preference> PREFS = [
			// Graphics
			new BoolPreference('graphicsBlur', 'GraphicsBlur', fallback: true),
			new BoolPreference('weatherEnabled', 'WeatherEffectsEnabled', fallback: true),
			new MultiPreference('weatherIntensity', 'WeatherEffectsIntensityGroup', fallback: 'normal'),

			// Interface
			new BoolPreference('darkUi', 'DarkMode', fallback: false),

			// Sound
			new NumPreference('musicVolume', 'MusicSlider', fallback: 50),
			new NumPreference('sfxVolume', 'EffectSlider', fallback: 50),

			// Chat
			new BoolPreference('joinMessages', 'ShowJoinMessages', fallback: true),
			new BoolPreference('mentionNotify', 'PlayMentionSound', fallback: true),

			// Controls
			new StringPreference('bindLeft1', 'LeftBindingPrimary'),
			new StringPreference('bindLeft2', 'LeftBindingAlt'),

		];
	}

	@override
	void open({bool ignoreKeys: false}) {
		super.open(ignoreKeys: ignoreKeys);


	}
}
