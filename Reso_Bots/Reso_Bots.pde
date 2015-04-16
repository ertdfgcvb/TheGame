PGraphics buf;
ArrayList<Bot>bots;

color BG_COL = color(100, 100, 250);
color SHADOW_COL;
int   GRID = 15;

PImage[] pal;
PImage currentPalette;
void setup() {
  size(800, 800, P3D);   
  buf = createGraphics(2400, 2400, P3D);
  bots = new ArrayList<Bot>();
  pal = new PImage[13];
  for (int i=0; i<pal.length; i++) {
    pal[i] = loadImage("pal/p_"+i+".png");
  }
  gen();  
  ranBG();
  render(buf);
}
void randomPalette() {
  int id = (int)random(pal.length);
  currentPalette = pal[id];
}

int randomColor() {
  currentPalette.loadPixels();
  int id = (int)random(currentPalette.pixels.length);
  return currentPalette.pixels[id];
}

void keyPressed() {
  if (key == ' ') {
    gen();
    render(buf);
  } else if (key == 'c') {
    ranBG();
    render(buf);
  } else if (key == 's') {
    buf.save("bots/" + System.currentTimeMillis() + ".png");
  }
}

void ranBG() {
  BG_COL = color(random(120, 220), random(120, 220), random(120, 220));
  //BG_COL = color(185,180,180);
  SHADOW_COL =  lerpColor(BG_COL, color(0, 0, 0), 0.2);
}

void gen() {
  noiseSeed((int)random(10000000));
  bots.clear();
  int num_x = 20;
  int num_y = 20;
  int ox = -(num_x * GRID)/2;
  int oy = -(num_y * GRID)/2;

  for (int y = 0; y<num_x; y++) { 
    for (int x = 0; x<num_y; x++) {
      if (noise(x*0.1, y*0.1)<0.5) {
        float h = abs(num_x - x - 1 + y);
        bots.add(new Bot(x * GRID + ox, y * GRID + oy, h));
      }
    }
  }
}

void render(PGraphics g) {
  g.beginDraw();
  g.smooth(8);
  g.background(BG_COL);
  g.ortho(0, g.width, 0, g.height, -10000, 10000);
  g.translate(g.width/2, g.height/2);
  g.rotateX(PI / 3);
  g.rotateZ(PI / 4 * 3);
  //g.lights();
  g.ambientLight(230, 230, 230);
  g.directionalLight(180, 180, 180, -20, 0, -10);
  g.lightSpecular(30, 30, 30);
  // g.specular(200);
  // g.shininess(200);
  // g.pointLight(50,50,50,1000,1000,1000);
  // g.lightFalloff(0,0,0);
  for (Bot b : bots) b.draw(g);
  g.endDraw();
}

void draw() {  
  image(buf, 0, 0, width, height);
}
