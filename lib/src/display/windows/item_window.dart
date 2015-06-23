part of couclient;

class ItemWindow extends Modal {
  String id = 'itemWindow';

  Element titleE = querySelector("#iw-title");
  Element imageE = querySelector("#iw-image");
  Element descE = querySelector("#iw-desc");
  Element priceE = querySelector("#iw-currants");
  Element slotE = querySelector("#iw-slot");
  Element imgnumE = querySelector("#iw-imgnum");
  Element discoverE = querySelector("#iw-newItem");

  ItemWindow() {
    prepare();
  }

  displayItem(itemName) async {
    String response = await HttpRequest.requestCrossOrigin('http://' + Configs.utilServerAddress + '/getItems?name=' + itemName);
    Map<String, String> json = JSON.decode(response)[0];

    String title = json['name'];
    String image = json['iconUrl'];
    String desc = json['description'];
    int price = (json['price'] as int);
    int slot = (json['stacksTo'] as int);
    int newImg = 0;

    titleE.text = title;
    imageE.setAttribute('src', image);
    descE.text = desc;

    if (price != -1) {
      priceE.setInnerHtml('This item sells for about <b>' + price.toString() + '</b> currants');
    } else {
      priceE.text = 'Vendors will not buy this item';
    }

    slotE.setInnerHtml('Fits up to <b>' + slot.toString() + '</b> in a backpack slot');

    if (newImg > 0) {
      discoverE.style.display = 'block';
      imgnumE.text = '+' + newImg.toString();
    } else {
      discoverE.style.display = 'none';
    }

    this.open();
  }
}