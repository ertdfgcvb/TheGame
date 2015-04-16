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

  FPoly p = new FPoly();
  p.setDensity(10);
  p.setRestitution(0.5);
  int num = 64;  
  for (int i=0; i<num; i++){
    float a = TWO_PI * i / num;
    float l = cos(a * 9) * 5 + 30;
    float x = cos(a) * l;
    float y = sin(a) * l;    
    p.vertex(x, y);
  }
  p.setPosition(width/2, height/2);
  world.add(p);
}

void draw() {
  background(255);
  world.step();
  world.drawDebug();  
}
