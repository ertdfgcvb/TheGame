import fisica.*;

FWorld world;

void setup() {
  size(400, 400);
  smooth();

  Fisica.init(this);

  world = new FWorld();
  world.setGravity(0, 0);
  world.setEdges();
  world.setEdgesRestitution(0.5);
}

void draw() {
  background(255);
  if (mousePressed){
    float s = random(10, 20);
    FBox b = new FBox(s, s);
    b.setPosition(mouseX,mouseY);
    world.add(b);
  }
  world.step();
  if (keyPressed){
    world.drawDebug();
  } else {
    world.draw();
  }
}
