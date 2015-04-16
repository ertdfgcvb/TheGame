import fisica.*;

FWorld world;

void setup() {

  size(400, 400);
  smooth();

  Fisica.init(this);

  world = new FWorld();
  world.setGravity(0, 0);
  world.setEdges();

  FBox ba = new FBox(60, 40);
  ba.setPosition(width/3, height/2);  
  world.addBody(ba);

  FBox bb = new FBox(60, 40);
  bb.setPosition(width/3*2, height/2);
  world.addBody(bb);

  FRevoluteJoint j = new FRevoluteJoint(ba, bb);
  world.add(j);
  
}

void draw() {
  background(255);
  world.step();
  world.drawDebug();
}
