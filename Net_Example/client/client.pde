import processing.net.*;

Client c;

void setup() {
  size(200, 200);
  c = new Client(this, "localhost", 9000);  
}

void draw() {
  if (c.available() > 0) {
    String in = c.readString();
    println("Received from server: " + in);
  }
}

void keyPressed(){
  c.write(key);
}
