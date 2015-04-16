import fisica.*;

FWorld world;

void setup() {
  size(400, 400);
  smooth();

  Fisica.init(this);

  world = new FWorld();
  world.setEdges();
  world.setGravity(0, 0);

  FCircle ba = new FCircle(50);
  ba.setPosition(width/3, height/2);  
  world.addBody(ba);

  FCircle bb = new FCircle(25);
  bb.setPosition(width/3*2, height/2);
  world.addBody(bb);

  FDistanceJoint j = new FDistanceJoint(ba, bb);
  //j.setLength(100);
  j.setFrequency(2);
  world.add(j);
}
void draw() {
  background(255);
  world.step();
  world.drawDebug();
}
