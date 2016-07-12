part of couclient;

/// Parses sent messages for links/etc, so they are faster to appear in the panel.
/// Sort of like lazy loading for chat messages.
class AsyncChatMessageParser {
	/*
		(https?:\/\/)?                    : the http or https schemes (optional)
		[\w-]+(\.[\w-]+)+\.?              : domain name with at least two components;
											allows a trailing dot
		(:\d+)?                           : the port (optional)
		(\/\S*)?                          : the path (optional)
	*/
	static final String URL_REGEX = r'((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)';

	static Future parse(Element message) async {
		if (message.dataset['parsed'] != null && message.dataset['parsed'] == 'true') {
			// Skip already parsed messages
			return;
		}

		// Parse links FIRST to prevent redoing item/location links
		print('parsing links');
		_parseLinks(message);

		// Link & color username
		print('styling username');
		await _styleUsername(message);

		// Auto-link street names to the map
		print('parsing streets');
		_parseStreetNames(message);

		// Auto-link hub names to the map
		print('parsing hubs');
		_parseHubNames(message);

		// Mark message as parsed
		print('done parsing');
		message.dataset['parsed'] = 'true';
	}

	static void parseEmoji(Element message) {
		if (message == null) {
			return;
		}

		String html = message.innerHtml;

		html.splitMapJoin(new RegExp(r'::(.+?)::'), onMatch: (Match m) {
			String match = m[1];
			if (EMOTICONS.contains(match)) {
				html += '<i class="emoticon emoticon-sm $match" title="$match"></i>';
			} else {
				html += m[0];
			}
		}, onNonMatch: (String s) => html += s);

		message.setInnerHtml(html);
	}

	static void _parseLinks(Element message) {
		if (message == null) {
			return;
		}

		String newHtml = '';

		message.innerHtml.splitMapJoin(new RegExp(URL_REGEX), onMatch: (Match m) {
			String url = m[0];

			// Make sure URLs contain the protocol
			if (!url.contains('http')) {
				url = 'http://' + url;
			}

			newHtml += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
		}, onNonMatch: (String s) => newHtml += s);

		message.setInnerHtml(newHtml);
	}

	static Future _styleUsername(Element message) async {
		if (message == null || message.querySelector('.name') == null) {
			return;
		}

		String player = message.dataset['player'];

		AnchorElement oldPlayerLink = message.querySelector('.name');
		AnchorElement playerLink = oldPlayerLink.clone(true);
		playerLink
			..href = 'http://childrenofur.com/profile?username=${Uri.encodeComponent(player)}'
			..target = "_blank"
			..title = "Open Profile Page"
			..style.color = (await getColorFromUsername(player))
			..classes = ['noUnderline']
			..text = player;

		if (player != 'invalid_user') {
			if (player == game.username) {
				// Current player
				playerLink.classes.add('you');

				if (!message.classes.contains('me')) {
					// /me messages
					playerLink.text = 'You';
				}
			}

			// Dev/Guide labels
			String elevation = await game.getElevation(player);
			if (elevation != '') {
				playerLink.classes.add(elevation);
			}
		}

		oldPlayerLink.insertAdjacentHtml(
			'afterEnd', playerLink.outerHtml, validator: Chat.VALIDATOR);
		oldPlayerLink.remove();
	}

	static void _parseStreetNames(Element message) {
		if (message == null) {
			return;
		}

		mapData.streetData.forEach((String streetName, Map<String, dynamic> streetData) {
			if (streetData['map_hidden'] != null && streetData['map_hidden']) {
				// Don't link streets that aren't on the map
				return;
			}

			message.setInnerHtml(message.innerHtml.replaceAll(streetName,
				'<a class="location-chat-link street-chat-link" title="View Street" href="#">$streetName</a>'));
		});
	}

	static void _parseHubNames(Element message) {
		if (message == null) {
			return;
		}

		mapData.hubData.forEach((String hubName, Map<String, dynamic> hubData) {
			if (hubData['map_hidden'] != null && hubData['map_hidden']) {
				// Don't link hubs that aren't on the map
				return;
			}

			message.setInnerHtml(message.innerHtml.replaceAll(hubName,
				'<a class="location-chat-link hub-chat-link" title="View Hub" href="#">$hubName</a>'));
		});
	}
}
