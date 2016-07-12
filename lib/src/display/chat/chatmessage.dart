part of couclient;

class ChatMessage {
	String player, message;

	ChatMessage(this.player, this.message);

	void notify() {
		if (message.toLowerCase().contains(game.username.toLowerCase())
		  && windowManager.settings.playMentionSound
		  && player != game.username) {
			// Popup
			new Notification(
			  player,
			  body: message,
			  icon: "http://childrenofur.com/assets/icon_72.png"
			);

			// Sound effect
			transmit('playSound', 'mention');
		}
	}

	Element toElement() {
		// Verify data
		if (message is! String || player is! String) {
			return null;
		}

		Element element;

		// Notify of any mentions
		notify();

		if (player == null) {
			// System message
			element = new ParagraphElement()
				..text = message
				..classes = ["system"];
		} else if (message.startsWith("/me")) {
			// /me message
			element = new ParagraphElement()
				..classes = ["me"]
				..append(new AnchorElement()
					..classes = ['name'])
				..appendText(message.replaceFirst("/me", ""));
		} else if (message == "LocationChangeEvent" && player == "invalid_user") {
			// Switching streets
			SpanElement messageSpan = new SpanElement()
				..classes = ["message"]
				..text = "${currentStreet.label}";

			element = new ParagraphElement()
				..classes = ["chat-member-change-event"]
				..append(messageSpan);
		} else {
			// Normal message
			element = new ParagraphElement()
				..append(new AnchorElement()
					..classes = ['name'])
				..appendHtml("&#8194;") // en space
				..append(new SpanElement()
					..classes = ["message"]
					..text = message);
		}

		element.dataset['player'] = (player ?? 'invalid_user').toString();

		window.console.log(element);
		AsyncChatMessageParser.parse(element);

		return element;
	}
}

// chat functions

List<String> EMOTICONS;
List<Chat> openConversations = [];
List<Toast> chatToastBuffer = [];

// global functions

Map<String, String> cachedUsernameColors = {};

Future<String> getColorFromUsername(String username) async {
	if (cachedUsernameColors[username] != null) {
		// Already checked the color
		return cachedUsernameColors[username];
	} else {
		// Download color from server
		String color = await HttpRequest.getString(
			"http://${Configs.utilServerAddress}/usernamecolors/get/$username"
		).timeout(new Duration(seconds: 5), onTimeout: () {
			return '#';
		});
		// Cache for later use
		cachedUsernameColors[username] = color;
		// Return for display
		return color;
	}
}

String parseItemLinks(String message) {
	String returnString = "";
	RegExp regex = new RegExp("#(.+?)#");
	(message.splitMapJoin(regex, onMatch: (Match m) {
		String match = m[1];
		if (Item.isItem(itemType: match)) {
			String name = Item.getName(match);
			String iconUrl = Item.getIcon(itemType: match);
			returnString += '<a class="item-chat-link" title="View Item" href="#">'
			  '<span class="item-chat-link-icon" '
			  'style="background-image: url($iconUrl);">'
			  '</span>$name</a>';
		} else {
			returnString += m[0];
		}
	}, onNonMatch: (String s) => returnString += s));

	return returnString;
}
