part of couclient;

UserInterface view;

class UserInterface {
  /////////////////////ELEMENTS//////////////////////////////////////////////
  // you won! element
  Element youWon = querySelector('#youWon');

  // Initial loading screen elements
  Element loadStatus = querySelector("#loading #loadstatus");
  Element loadStatus2 = querySelector("#loading #loadstatus2");
  Element loadingScreen = querySelector('#loading');
  Element loadingSpinner = querySelector('#loading .fa-spin');
  ImageElement streetLoadingImage = querySelector('#StreetLoadingImage');
  Element streetLoadingStatus = querySelector('#StreetLoadingStatus');
  Element nowEntering = querySelector('#NowEntering');
  Element mapLoadingBar = querySelector('#MapLoadingBar');
  Element mapLoadingScreen = querySelector('#MapLoadingScreen');
  Element mapLoadingContent = querySelector('#MapLoadingContent');

  // Time Meter Variables
  Element currDay = querySelector('#currDay');
  Element currTime = querySelector('#currTime');
  Element currDate = querySelector('#currDate');

  // Location and Map elements
  Element currLocation = querySelector('#currLocation');
  Element mapButton = querySelector('#mapButton');

  // Settings Glyph
  Element settingsButton = querySelector('#settingsGlyph');

  // Inventory Management
  Element inventorySearch = querySelector('#inventorySearch');
  Element inventory = querySelector("#inventory");

  // Pause button
  Element pauseButton = querySelector('#thinkButton');
  Element pauseMenu = querySelector('#pauseMenu');

  // settings window elements
  ElementList tabs = querySelectorAll('article .tab');


  // bugreport button
  Element bugButton = querySelector('#bugGlyph');
  Element bugReportMeta = querySelector('#bugWindow article #reportMeta');
  InputElement bugReportEmail = querySelector('#bugWindow article input[type="email"]');
  SelectElement bugReportType = querySelector('#bugWindow article #reportCategory');

  // main Element
  Element mainElement = querySelector('main');

  // world Element
  Element worldElement = querySelector('#world');
  Element playerHolder = querySelector("#playerHolder");
  Element layers = querySelector("#layers");

  // Music Meter Variables
  Element titleElement = querySelector('#trackTitle');
  Element artistElement = querySelector('#trackArtist');
  AnchorElement SClinkElement = querySelector('#SCLink');

  //Location/Map Variables
  Element mapWindow = querySelector('#mapWindow');
  Element mapImg = querySelector('#mapImage');
  Element mapTitle = querySelector('#mapTitle');
  CanvasElement mapCanvas = querySelector('#MapCanvas');

  // Chat panel
  Element panel = querySelector('#panel');
  Element chatTemplate = querySelector('#conversationTemplate');

  Element conversationArchive = querySelector("#conversationArchive");


  //fps meter
  Element fpsDisplay = querySelector('#fps');

  /////////////////////ELEMENTS//////////////////////////////////////////////


  // Declare/Set initial variables here
  /////////////////////VARS//////////////////////////////////////////////////

  String location = 'null';

  bool muted = false;
  String SCsong = '-';
  String SCartist = '-';
  String SClink = '';

  /////////////////////VARS//////////////////////////////////////////////////

  // Object for manipulating meters.
  Meters meters = new Meters();

  VolumeSlider slider = new VolumeSlider();


  loggedIn() {
    loadingScreen.style.opacity = '0';
    new Message(#playSound, 'game_loaded');
    new Timer(new Duration(seconds: 1), () {
      loadingScreen.hidden = true;
    });
  }

  loggedOut(){
      loadingScreen.hidden = false;
      new Timer(new Duration(seconds: 1), () {
        loadingScreen.style.opacity = '1';
      });
  }

  // start listening for events
  UserInterface() {

    //load emoticons
    new Asset("assets/emoticons/emoticons.json").load().then((Asset asset) => EMOTICONS = asset.get()["names"]);

    // Set initial Time
    currDay.text = clock.dayofweek;
    currTime.text = clock.time;
    currDate.text = clock.day + ' of ' + clock.month;



    // The 'you won' splash
    window.onBeforeUnload.listen((_) {
      youWon.hidden = false;
    });


    // Listens for the pause button
    pauseButton.onClick.listen((_) {
      pauseMenu.hidden = false;
    });
    pauseMenu.querySelector('.fa-times.close').onClick.listen((_) => pauseMenu.hidden = true);



    new Service([#timeUpdate], (Message event) {
      currDay.text = clock.dayofweek;
      currTime.text = clock.time;
      currDate.text = clock.day + ' of ' + clock.month;
    });

    new Service([#doneLoading], (Message event) {
      // display 'Play' buttons
      for (Element button in loadingScreen.querySelectorAll('.button')) button.hidden = false;
    });


  }


  // update the userinterface
  update() {

    // Update the location text
    if (location.length >= 20) location = location.substring(0, 17) + '...';
    if (location != currLocation.text) currLocation.text = location;



    // Update all audioElements to the correct volume
    for (AudioElement audio in querySelectorAll('audio')) {
      if (audio.volume != view.slider.volume / 100) audio.volume = view.slider.volume / 100;
    }

    // Update the soundcloud widget
    if (SCsong != titleElement.text) titleElement.text = SCsong;
    if (SCartist != artistElement.text) artistElement.text = SCartist;
    if (SClink != SClinkElement.href) SClinkElement.href = SClink;

    window.requestAnimationFrame((_) => this.update());
  }
}



// This is Robert's touchscroller class for handling
// touchscreen scroll compatability.
/////////////////////TOUCHSCROLLER///////////////////////////////////////
class TouchScroller {
  static int HORIZONTAL = 0,
      VERTICAL = 1,
      BOTH = 2;
  DivElement _scrollDiv;
  int _startX, _startY, _lastX, _lastY, _direction;

  TouchScroller(this._scrollDiv, this._direction) {
    _scrollDiv.onTouchStart.listen((TouchEvent event) {
      event.stopPropagation();
      _startX = event.changedTouches.first.client.x;
      _startY = event.changedTouches.first.client.y;
      _lastX = _startX;
      _lastY = _startY;
    });
    _scrollDiv.onTouchMove.listen((TouchEvent event) {
      event.preventDefault();
      int diffX = _lastX - event.changedTouches.single.client.x;
      int diffY = _lastY - event.changedTouches.single.client.y;
      _lastX = event.changedTouches.single.client.x;
      _lastY = event.changedTouches.single.client.y;
      if (_direction == HORIZONTAL || _direction == BOTH) _scrollDiv.scrollLeft = _scrollDiv.scrollLeft + diffX;
      if (_direction == VERTICAL || _direction == BOTH) _scrollDiv.scrollTop = _scrollDiv.scrollTop + diffY;
    });
  }
}
