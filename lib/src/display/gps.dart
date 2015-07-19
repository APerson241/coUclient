part of couclient;

class GpsIndicator {
	Element containerE = querySelector("#gps-container");
	Element closeButtonE = querySelector("#gps-cancel");
	Element nextStreetE = querySelector("#gps-next");
	Element destinationE = querySelector("#gps-destination");
	Element arrowE = querySelector("#gps-direction");
	bool loadingNew, arriveFade = false;

	GpsIndicator() {
		closeButtonE.onClick.listen((_) => this.cancel());
	}

	update() {
		if (!loadingNew) {
			if (GPS.active) {
				containerE.hidden = false;
				nextStreetE.text = GPS.nextStreetName;
				destinationE.text = GPS.destinationName;
				if (GPS.nextStreetName == "You're off the path") {
					GPS.getRoute(currentStreet.label, GPS.destinationName);
				} else if(GPS.nextStreetName == "You have arrived") {
					if(arriveFade || !currentStreet.loaded) {
						return;
					}
					arriveFade = true;
					new Timer(new Duration(seconds:3),(){
						arriveFade = false;
						cancel();
					});
				}else {
					arrowE.style.transform = "rotate(${calculateArrowDirection()}rad)";
				}
			} else {
				cancel();
			}
		} else {
			containerE.hidden = true;
		}
	}

	cancel() {
		GPS.active = false;
		containerE.hidden = true;
		nextStreetE.text = destinationE.text = null;
		arrowE.style.transform = null;
	}

	num calculateArrowDirection() {
		num exitX, exitY;
		num playerX = CurrentPlayer.posX;
		num playerY = CurrentPlayer.posY + CurrentPlayer.height/2;

		for(Map exit in minimap.currentStreetExits) {
			if(exit["streets"].contains(GPS.nextStreetName)) {
				if(exit["streets"].length > 1) {
					// signs on both sides
					exitX = exit["x"] + 100;
				} else {
					exitX = exit["x"];
				}
				exitY = exit["y"] + 115; // center of the height
				break;
				// no point in wasting time, we found the signpost
			}
		};

		if(exitX == null || exitY == null) {
			return 0;
			// error
		}

		num dy = exitY - playerY;
		num dx = exitX - playerX;
		num theta = atan2(dy, dx) - 3*PI/2;
		return theta;
	}
}