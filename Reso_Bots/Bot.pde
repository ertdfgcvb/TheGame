import java.lang.reflect.*;

PApplet parent = this;

class Bot {

  ArrayList<Element> el;
  int s = 20;
  PVector pos;
  PVector rot;
  float colH;

  Bot(int px, int py, float colH) {    
    pos = new PVector(px * s, py * s);
    rot = new PVector();
    if (random(1) < 0.12) {
      rot.z = PI / 3;
    }
    this.colH = colH;
    generate2();
  }

  void generate2() {    

    int numLegs = 0;
    while (numLegs < 2) {

      numLegs = 0;

      int min_x = 4;
      int max_x = 9;

      int min_y = 1;
      int max_y = 4;

      int min_h = 1;
      int max_h = 6;

      int fh = (int)random(1, 4); // height from floor;

      int nx = (int)random(min_x, max_x+1);
      int ny = (int)random(min_y, max_y+1);
      int nh = (int)random(min_h, max_h+1);

      float ox = -nx * s / 2;

      Grid g = new Grid(nx, ny, nh);

      el = new ArrayList<Element>();
      float ns = random(0.02, 0.03);

      //color col = color(random(255), random(255), random(255));
      randomPalette();
      color col = randomColor();

      for (int z = 0; z<nh; z++) {
        for (int y = 0; y<ny; y++) {
          col = lerpColor(col, randomColor(), random(0.8,1));
          for (int x = 0; x<nx; x++) {          

            if (random(1) < 0.2){
                col = lerpColor(col, randomColor(), random(0.2,0.6));
            }
            
            PVector pos = new PVector(x * s + ox, y * s, z * s + fh * s);
            pos.add(new PVector(s/2, s/2, s/2));
            PVector ang = new PVector(0, 0, 0);
            PVector dim = new PVector(s, s, s);  

            if (noise((pos.x + x)*ns, (pos.y + y)*ns, (pos.z + z)*ns) > 0.45) {
              g.set(col, x, y, z);
              Element e = new Box(pos, ang, dim, col);
              //if (random(1) < 0.1) e.dim.mult(0.5);
              el.add(e);
            }
          }
        }
      } 

      // ns = 0.003;
      // float val = noise((pos.x)*ns, (pos.y+10)*ns);
      // val = map(cos(pos.x * 0.01) * cos(pos.y * 0.01),-2,2,0,1);
      // val = map(sin(((pos.x+10) * (pos.x+10) + pos.y * pos.y)*0.000005), -1, 1, 0, 1);
      // colH = (int) (val * 100) / 10;
      //colH = abs(pos.x + 10 + pos.y) / GRID / 10;


      int legOffs = (int)random(nx/2);
      int leg_h   = (int)random(nh/2);
      int legSkip = (int)random(2, 5);

      for (int leg_x = legOffs; leg_x<nx; leg_x += legSkip) {
        int leg_y = g.drillY(leg_x, leg_h);     
        if (leg_y != 0 && leg_y != -1) {
          PVector pos = new PVector(leg_x * s + ox, (leg_y+1) * s, leg_h * s + fh * s);
          pos.add(new PVector(s/2, s/2, s/2));
          PVector ang = new PVector(0, 0, 0);
          PVector dim = new PVector(s, s, s);
          color leg_col = lerpColor(g.get(leg_x, leg_y, leg_h), color(0), 0.5);
          Element e = new Leg(pos, ang, dim, leg_col);
          el.add(e);
          numLegs++;
        }
      }
    }

    mirror();
  }



  void mirror() {
    ArrayList<Element> mirrored = new ArrayList<Element>();
    for (Element e : el) {
      Element c = e.clone(e);
      c.pos.y *= -1;      
      mirrored.add(c);
    }
    for (Element e : mirrored) el.add(e);
  }

  void draw(PGraphics g) {
    g.pushMatrix();
    g.translate(pos.x, pos.y, pos.z);
    g.fill(BG_COL);
    //g.stroke(lerpColor(BG_COL, color(0), 0.02));
    g.translate(0, 0, colH*s/2);
    g.box(GRID*s, GRID*s, colH*s);
    g.translate(0, 0, colH*s/2+0.3);
    g.rotateZ(rot.z);
    //drawAxis(g, 50);
    g.noStroke();
    for (Element e : el) {
      e.pre(g);      
      e.draw(g);      
      e.post(g);
      e.drawShadow(g);
    }
    g.popMatrix();
  }

  void drawAxis(PGraphics g, float l) {    
    g.stroke(255, 0, 0);
    g.line(0, 0, 0, l, 0, 0);
    g.stroke(0, 255, 0);
    g.line(0, 0, 0, 0, l, 0);
    g.stroke(0, 0, 255);
    g.line(0, 0, 0, 0, 0, l);
  }
}

class Leg extends Element {
  Leg(Leg b) {
    super(b.pos, b.ang, b.dim, b.col);
  }

  Leg(PVector pos, PVector ang, PVector dim, int col) {
    super(pos, ang, dim, col);
  }

  void draw(PGraphics g) {
    g.noStroke();
    g.fill(col);
    g.box(dim.x, dim.y, dim.z);
    g.fill(0, 0, 0);
    g.translate(0, 0, -pos.z);
    g.sphere(dim.x/3);
    g.stroke(0);
    g.noFill();
    g.line(0, 0, 0, 0, 0, pos.z);
  }

  void drawShadow(PGraphics g) {
    g.noStroke();
    g.fill(SHADOW_COL);
    g.rectMode(CENTER);
    g.rect(pos.x, pos.y, dim.x, dim.y);
  }
}

class Box extends Element {

  Box(Box b) {
    super(b.pos, b.ang, b.dim, b.col);
  }

  Box(PVector pos, PVector ang, PVector dim, int col) {
    super(pos, ang, dim, col);
  }

  void draw(PGraphics g) {
    //g.stroke(lerpColor(col, color(0, 0, 0), 0.2));
    g.fill(col);
    g.box(dim.x, dim.y, dim.z);
  }

  void drawShadow(PGraphics g) {
    g.noStroke();
    g.fill(SHADOW_COL);
    g.rectMode(CENTER);
    g.rect(pos.x, pos.y, dim.x, dim.y);
  }
}

abstract class Element {
  PVector pos, ang;
  PVector dim;
  int col;

  Element clone(Object obj) {
    Element object = null;
    try {
      Class c = obj.getClass();
      Constructor[] ctor = c.getDeclaredConstructors();
      object = (Element) ctor[0].newInstance(new Object[] { 
        parent, obj
      } 
      );
    } 
    catch (InvocationTargetException e) {
      System.out.println(e);
    } 
    catch (InstantiationException e) {
      System.out.println(e);
    } 
    catch (IllegalAccessException e) {
      System.out.println(e);
    } 
    return (Element) object;
  }

  Element(PVector pos, PVector ang, PVector dim, int col) {
    this.pos = pos.copy();
    this.ang = ang.copy();
    this.dim = dim.copy();
    this.col = col;
  }
  void pre(PGraphics g) {
    //g.noStroke();
    g.pushMatrix();
    g.translate(pos.x, pos.y, pos.z);
    g.rotateX(ang.x);
    g.rotateY(ang.y);
    g.rotateZ(ang.z);
  }
  void post(PGraphics g) {
    g.popMatrix();
  }
  abstract void draw(PGraphics g);
  abstract void drawShadow(PGraphics g);
}


class Grid {
  int[][][]grid;
  int dx, dy, dz;


  Grid(int x, int y, int z) {
    dx = x;
    dy = y;
    dz = z;
    grid=new int[z][y][x];
  }

  void set(int v, int x, int y, int z) {
    grid[z][y][x] = v;
  } 

  int get(int x, int y, int z) {
    return grid[z][y][x];
  }

  int drillY(int x, int z) {
    for (int y=dy-1; y>=0; y--) {
      if (get(x, y, z) != 0) return y;
    }
    return -1;
  }

  int count() {
    int c = 0;
    for (int z=0; z<dz; z++) {
      for (int y=0; y<dy; y++) {
        for (int x=0; x<dx; x++) {
          if (grid[z][y][x] != 0) c++;
        }
      }
    }
    return c;
  }
}
