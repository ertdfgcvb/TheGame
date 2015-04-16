import processing.net.*;
import java.lang.reflect.*;
import java.util.Iterator;
import fisica.*;

Game game;
Server server;
Player testPlayer;

int PORT = 8000;
char TERMINATOR = '\n';
char SEPARATOR = ' ';

void setup() {
  System.setProperty("java.net.preferIPv4Stack", "true");
  size(1920/6*4, 1080/6*4, P2D);
  smooth(8);
  server = new Server(this, PORT);
  game = new Game(this, server);
  //testPlayer = game.addPlayer(new XXEmpty(), null);
}

void keyPressed() {
  // testPlayer keys... just to test the testPlayer
  // if (testPlayer != null) {
  //   if      (keyCode == DOWN)  testPlayer.message("button btn_down 1");
  //   else if (keyCode == UP)    testPlayer.message("button btn_up 1");
  //   else if (keyCode == LEFT)  testPlayer.message("button btn_left 1");
  //   else if (keyCode == RIGHT) testPlayer.message("button btn_right 1");
  //   else if (key == '1')       testPlayer.message("button btn_one 1");
  //   else if (key == '2')       testPlayer.message("button btn_two 1");
  //   else if (key == '3')       testPlayer.message("button btn_three 1");
  //   else if (key == '4')       testPlayer.message("button btn_four 1");
  // }
}

void keyReleased() {
  if      (key == 'a') game.message(null, "toggle_axis");
  else if (key == 'i') game.message(null, "toggle_info");
  else if (key == 't') game.message(null, "make_teams");
  else if (key == 'r') game.message(null, "reset_teams");

  // testPlayer keys... just to test the testPlayer  
  // if (testPlayer != null) {
  //   if      (keyCode == DOWN)  testPlayer.message("button btn_down 0");
  //   else if (keyCode == UP)    testPlayer.message("button btn_up 0");
  //   else if (keyCode == LEFT)  testPlayer.message("button btn_left 0");
  //   else if (keyCode == RIGHT) testPlayer.message("button btn_right 0");
  //   else if (key == '1')       testPlayer.message("button btn_one 0");
  //   else if (key == '2')       testPlayer.message("button btn_two 0");
  //   else if (key == '3')       testPlayer.message("button btn_three 0");
  //   else if (key == '4')       testPlayer.message("button btn_four 0");
  // }
}

void draw() {
  serverLoop();  
  game.loop();
  game.draw(g);
}

void serverLoop() {  
  int count = 200; 
  // the loop will break in case a message will not contain a TERMINATOR char 
  // this should never happen, but in case...  
  Client c = server.available();
  while (c != null && count-- > 0) {
    String message = "";
    while (message != null) {    
      message = c.readStringUntil(TERMINATOR);
      // the message and the client are forwarded to the game 
      // (don't forget to 'trim' the message as there are still separators and terminators in the raw message)           
      if (message != null) game.message(c, trim(message));
    }
    c = server.available();
  }
}

// a new client connects, we just forward it to the game: 
void serverEvent(Server s, Client c) {
  println("A new client connected: " + c.ip());
  game.newClientEvent(c);
}

// a client disconnected:
void disconnectEvent(Client c) {
  println("A client disconnected: " + c.ip());
  game.disconnectEvent(c);
}
