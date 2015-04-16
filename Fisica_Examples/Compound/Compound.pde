
import fisica.*;

FWorld world;

void setup() {
  size(400, 400);
  smooth();

  Fisica.init(this);

  world = new FWorld();
  world.setEdges();
  
  FBox ba = new FBox(50, 50);
  ba.setPosition(width/2, height/2);

  FBox bb = new FBox(20, 20);
  bb.setPosition(width/2 + 35, height/2);

  
  FCompound c = new FCompound();
  c.addBody(ba);
  c.addBody(bb);
  
  world.addBody(c);
  
}

void draw() {
  background(255);

  world.step();
  world.drawDebug();
}
