import fisica.*;

FWorld world;

void setup() {

  size(400, 400);
  smooth();

  Fisica.init(this);

  world = new FWorld();
  world.setGravity(0, 0);
  world.setEdges();

  FBox ba = new FBox(50, 50);
  ba.setPosition(width/3, height/2);  
  world.addBody(ba);

  FBox bb = new FBox(40, 40);
  bb.setPosition(width/3*2, height/2);
  world.addBody(bb);

  FPrismaticJoint j = new FPrismaticJoint(ba, bb);
  j.setAxis(1, 0);
  j.setEnableLimit(true);
  j.setUpperTranslation(100);
  j.setLowerTranslation(0);
  world.add(j);
  
}

void draw() {
  background(255);
  world.step();
  world.drawDebug();
}
