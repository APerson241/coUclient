part of couclient;

class Toast {
	/// In-game toasts panel
	static final Element toastContainer = querySelector("#toastHolder");

	/// Icon URL for system notifications
	static const notifIconUrl = "http://childrenofur.com/assets/icon_72.png";

	/// Predefined click functions (pass as onClick)
	static final Map<String, Function> _clickActions = {
		"imgmenu": (_) => imgMenu.open()
	};

	/**
	 * Creates and displays a Toast.
	 * [message]: What to say in the toast, chat message, and notification.
	 * [skipChat]: `true` to disable display in local chat, `false` (default) to act normally and display.
	 * [notify]: `true` to send a browser notification, `false` (default) to keep inside the client window.
	 * [onClick]: A clickActions identifier or function, which will be passed the click MouseEvent.
	 */
	Toast(this.message, {this.skipChat, this.notify, dynamic onClick}) {
		if (skipChat == null) skipChat = false;
		if (notify == null) notify = false;

		// Display in toasts panel
		_sendToPanel();

		// Attach click listener in panel (if onClick is passed)
		_setupClickHandler(onClick);

		// Display in chat panel (or queue) if not disabled
		// Adds its own click listener based on that of the toast
		_sendToChat();

		// Display in system notification tray (if enabled)
		_sendNotification();
	}

	/// Handle click events on the toast in the panel
	void _setupClickHandler(dynamic onClick) {
		if (onClick != null) {
			if (onClick is Function) {
				clickHandler = onClick;
			} else if (onClick is String) {
				clickHandler = _clickActions[onClick];
			} else {
				throw new ArgumentError("onClick must be a string identifier or function, but it is of type ${onClick.runtimeType}");
			}

			toastElement
				..onClick.listen((MouseEvent event) => clickHandler(event))
				..style.cursor = "pointer";
		}
	}

	/// Display in toasts panel
	void _sendToPanel() {
		// Create node
		toastElement = new DivElement()
			..classes.add('toast')
			..style.opacity = '0.5'
			..text = message;

		// How long to display it (1s + 100ms per character, max 30s)
		int textTime = (1000 + (message.length * 100)).clamp(1000, 30000);

		// Animate closing it
		Duration timeOpacity = new Duration(milliseconds: textTime);
		Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);
		new Timer(timeOpacity, () => toastElement.style.opacity = '0');
		new Timer(timeHide, () => toastElement.remove());

		_toastContainer.append(toastElement);
	}

	/// Display in chat, if not disabled
	void _sendToChat() {
		if (Chat.localChat != null && skipChat != null && !skipChat) {
			Chat.localChat.addAlert(this);
		} else if (!skipChat) {
			chatToastBuffer.add(this);
		}
	}

	/// Send system notification, if enabled
	void _sendNotification() {
		if (notify) {
			new Notification(
				"Game Alert",
				body: message,
				icon: notifIconUrl
			);
		}
	}

	String message;
	bool skipChat;
	bool notify;
	Function clickHandler;
	Element toastElement;
	Element chatElement;

	@override
	String toString() => message;
}