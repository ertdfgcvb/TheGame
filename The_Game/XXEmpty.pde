public class XXEmpty extends Player {

  FBox body;
  public XXEmpty() {
    name = "Empty";
    author = "Andreas Gysin";
  }

  // it is mandatory to implement this (asbtract) method
  // and to use the values passed to px and py 
  // to correctly position the player
  void make(float px, float py) {
    // the first body added becomes the "main body" by default
    body = new FBox(50, 50);
    // it is important to call setPosition method to allow the main program
    // to position the player:
    body.setPosition(px, py); 
    add(body);
  }

  void loop() {
    if (buttons.get("btn_up")) {
      body.adjustVelocity(0, -10);
    }
  }

  void onButtonDown(String which) {
    if (which.equals("btn_one")) {      
      //btn_one actions here...
    } //etc.
  }

  void onButtonUp(String which) {
    if (which.equals("btn_one")) {
      //btn_one actions here...
    } //etc.
  }

  // your customized messages here:
  // void onMessage(String msg) {
  //   String[] m = split(msg, SEPARATOR);
  //   if (m.length > 0) {
  //     String label = m[0];
  //     if (label.equals("custom_label")){
  //       float v = float(m[1]);
  //     }
  //   }
  // }
}
