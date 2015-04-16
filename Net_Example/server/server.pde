import processing.net.*;

Server s;

void setup() {
  size(200, 200);
  s = new Server(this, 9000); // Start a simple server on a port
}

void draw() {
  Client c = s.available();
  if (c != null) {
    String in = c.readString();
    println("Received from client ["+c.ip()+"]: " + in);
  }
}

void keyPressed(){
  s.write(key);
}
