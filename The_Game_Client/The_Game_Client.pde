//import controlP5.*;
import processing.net.*;

final static int    PORT         = 8000;
final static String IP           = "localhost";
final static String PLAYER_CLASS = "AGMoron";

//ControlP5 cp5;
Client client;
float bumperLength;

void setup() {
  System.setProperty("java.net.preferIPv4Stack", "true");
  size(400, 400);
  textFont(loadFont("f-16.vlw"));
  
  //  cp5 = new ControlP5(this);  
  //  cp5.setAutoDraw(true);
  //  cp5.setColorActive(color(255, 0, 0));
  //  cp5.setColorBackground(color(0, 30));
  //  cp5.setColorForeground(color(160));
  //  cp5.setColorCaptionLabel(0);
  //  cp5.setColorValueLabel(255);
  //  cp5.addSlider("bumperLength").setWidth(255).setHeight(18).setRange(10, 200).linebreak();
  
  connect();
}



void draw() {
  clientLoop();

  background(255);
  fill(0);
  String str = "";
  str += "ip:\n" + IP + "\n\n";
  str += "class:\n" + PLAYER_CLASS + "\n\n";
  str += "keys:\n";
  str += "[c]onnect\n";
  str += "[d]isconnect\n";
  text(str, 10, 30);
}

//void controlEvent(ControlEvent theEvent) {
//  String name = theEvent.getController().getName();
//  if (name.equals("bumperLength")) {
//    send("bumper_length", str(bumperLength));
//  }
//}

void onMessage(String msg, String value) {
  println("Server said: \n" + msg + "\n" + value);
}

void keyPressed() {
  if      (keyCode == DOWN)  send("button", "btn_down 1");
  else if (keyCode == UP)    send("button", "btn_up 1");
  else if (keyCode == LEFT)  send("button", "btn_left 1");
  else if (keyCode == RIGHT) send("button", "btn_right 1");
  else if (key == '1')       send("button", "btn_one 1");
  else if (key == '2')       send("button", "btn_two 1");
  else if (key == '3')       send("button", "btn_three 1");
  else if (key == '4')       send("button", "btn_four 1");
}

void keyReleased() {
  if      (keyCode == DOWN)  send("button", "btn_down 0");
  else if (keyCode == UP)    send("button", "btn_up 0");
  else if (keyCode == LEFT)  send("button", "btn_left 0");
  else if (keyCode == RIGHT) send("button", "btn_right 0");
  else if (key == '1')       send("button", "btn_one 0");
  else if (key == '2')       send("button", "btn_two 0");
  else if (key == '3')       send("button", "btn_three 0");
  else if (key == '4')       send("button", "btn_four 0");

  // defaults:
  else if (key == 'c') connect();
  else if (key == 'd') disconnect();
}

// -----------------------------------------------------------
// This two chars are part of the common message protocol
// - a terminator to end a message
// - a separator to separate the label from the content of the message
// those values are more or less arbitrary but must be consistent among all players
final static char TERMINATOR     = '\n';
final static char SEPARATOR      = ' ';

void send(String msg, String value) {
  if (client == null) return;
  String out = msg + SEPARATOR + value + TERMINATOR;
  client.write(out);
}

void send(String msg) {
  if (client == null) return;
  client.write(msg + TERMINATOR);
}

void connect() {
  client = new Client(this, IP, PORT);
  send("init_class", PLAYER_CLASS);
}

void clientLoop() {
  if (client == null) return;
  while (client.available ()>0) {    
    String msg = "";
    while (msg != null) {    
      msg = client.readStringUntil(TERMINATOR);
      if (msg != null) {
        String[] data = split(msg, SEPARATOR);
        String label = data[0];
        String value = null;
        if (data.length > 1) {
          value = data[1];
        }
        onMessage(label, value);
      }
    }
  } 
}

void disconnect() {
  if (client != null) {
    client.stop();
    client = null;
  }
}

public void exit() {
  disconnect();
  super.exit();
}

public void stop() {
  disconnect();
  super.stop();
}
