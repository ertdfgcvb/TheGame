class Game {
  final static int NO_TEAM = -1;
  final static int TEAM_A  = 0;
  final static int TEAM_B  = 1;
  final static int IDLE    = 0;
  final static int PAUSED  = 1;
  final static int PLAYING = 2;

  private Server server;
  private ArrayList<Class> classes;
  private ArrayList<Player> players;
  private String log;
  private StringBuffer fullLog;
  private PFont consoleFont, scoreFont;
  private boolean showInfo = true;
  private boolean showAxis = false;
  private PApplet parent;
  private FWorld physics;
  private Palette palette;
  private Overlay overlay;  

  private FCircle ball;
  private FBody areaBig;
  private FBody goalA, goalB;

  private int gameMode;
  private int[] score = new int[2];

  private float fieldW;
  private float fieldH;
  
  float scale = 1.0/6.0*4;  

  Game(PApplet parent, Server server) {
    this.parent = parent;
    this.server = server; // just to display some stuff (IP)

    fieldW = 1920/6*4;
    fieldH = 1080/6*4;

    players = new ArrayList();

    palette = new Palette("palette.png");   

    consoleFont = loadFont("f-16.vlw");    
    scoreFont = loadFont("f-32.vlw");
    overlay = new Overlay(loadFont("f-220.vlw"));

    gameMode = IDLE;

    log = new String();
    fullLog = new StringBuffer();
    classes = scanClasses(parent, "Player");

    // physics:
    Fisica.init(parent);

    physics = new FWorld();
    physics.setGravity(0, 0);
    physics.setEdges(-6, -6, fieldW+6, fieldH+6);
    physics.setEdgesRestitution(0.8);

    float goalW = 4.0;
    float goalH = 200;
    float poleX = 20;
    float poleD = 10;

    goalA = new FBox(goalW, goalH - poleX);
    goalA.setPosition(goalW/2, fieldH/2);
    goalA.setSensor(true);
    goalA.setGrabbable(false);
    goalA.setDrawable(false);
    physics.addBody(goalA);

    FCircle poleA1 = new FCircle(poleD);
    poleA1.setPosition(poleX, fieldH/2 - goalH / 2);
    poleA1.setStatic(true);
    poleA1.setFillColor(palette.TEAM_A);
    physics.addBody(poleA1);

    FCircle poleA2 = new FCircle(poleD);
    poleA2.setPosition(poleX, fieldH/2 + goalH / 2);
    poleA2.setStatic(true);
    poleA2.setFillColor(palette.TEAM_A);
    physics.addBody(poleA2);    

    goalB = new FBox(goalW, goalH - poleX);
    goalB.setPosition(fieldW - goalW/2, fieldH/2);
    goalB.setSensor(true);
    goalB.setGrabbable(false);
    goalB.setNoFill();
    goalB.setNoStroke();
    goalB.setDrawable(false);
    physics.addBody(goalB);

    FCircle poleB1 = new FCircle(poleD);
    poleB1.setPosition(fieldW - poleX, fieldH/2 - goalH / 2);
    poleB1.setStatic(true);
    poleB1.setFillColor(palette.TEAM_B);
    physics.addBody(poleB1);

    FCircle poleB2 = new FCircle(poleD);
    poleB2.setPosition(fieldW - poleX, fieldH/2 + goalH / 2);
    poleB2.setStatic(true);
    poleB2.setFillColor(palette.TEAM_B);
    physics.addBody(poleB2);    

    areaBig = new FCircle(240);
    areaBig.setPosition(fieldW/2, fieldH/2);
    areaBig.setSensor(true);
    areaBig.setGrabbable(false);
    areaBig.setFillColor(color(255, 255, 255));
    areaBig.setStrokeColor(palette.FIELD_LINES);
    physics.addBody(areaBig);

    ball = new FCircle(20);
    ball.setPosition(fieldW / 2, fieldH / 2);
    ball.setBullet(true);
    physics.addBody(ball);
  }

  Player addPlayer(Player player, Client client) {
    player.init(this, client, physics);  
    player.make(fieldW/2, fieldH/2);
    constrainPlayerPhysics(player);
    player.setTeam(NO_TEAM);
    players.add(player);
    return player;
  }

  Player getPlayer(Client c) {
    for (Player p : players) {
      if (c == p.client) return p;
    }
    return null;
  }

  void removePlayer(Player p) {
    //removePlayer(p.getClient());
    p.kill();
  }    

  void removePlayer(Client c) {        
    Player p = getPlayer(c);
    if (p != null) p.kill();
  }

  void loop() {  

    // 1. step  
    // remove dead players:    
    for (int i = players.size () - 1; i>0; i--) {
      Player p = players.get(i);
      if (!p.isAlive()) {
        log(p.getName() + " left the game");        
        p.getClient().stop(); // stop the client  
        p.removeFromWorld();  // stop the physics
        players.remove(p);    // remove from list
      }
    }

    // 2. step
    // apply player forces, etc.
    for (Player p : players) {           
      p.loop();
    }

    // 3. step:
    // physics simulation step
    physics.step();

    // 4. step:
    // simple game logic, overlays, scores, etc.    
    if (gameMode == PLAYING) {
      ArrayList<FContact> contacts = ball.getContacts();
      for (FContact c : contacts) {
        if (c.getBody1() == goalA || c.getBody2() == goalA) {
          log("GOAL!");
          overlay.show("GOAL!", palette.TEAM_B);          
          score[TEAM_B]++;
          gameMode = PAUSED;
          break;
        } else if (c.getBody1() == goalB || c.getBody2() == goalB) {
          log("GOAL!");
          overlay.show("GOAL!", palette.TEAM_A);
          score[TEAM_A]++;
          gameMode = PAUSED;
          break;
        }
      }
    } else if (gameMode == PAUSED) {
      PVector d = new PVector(fieldW/2 - ball.getX(), fieldH/2 - ball.getY());
      d.limit(5);      
      ball.addImpulse(d.x, d.y);
      if ( isGameReady() ) {
        gameMode = PLAYING;
        overlay.show("READY!");
      }
    }
  }

  void draw(PGraphics g) {  
    g.background(255);
    
    g.scale(1);

    // draw the field
    g.stroke(palette.FIELD_LINES);
    g.strokeWeight(1);
    g.line(fieldW/2, 0, fieldW/2, fieldH);

    // 1. Fisica draw method
    physics.draw(g);

    // 2. ... or a custom draw
    // this is here as a demonstration purpose and will only draw circles and rects:
    /*
    for (Player p : players) {
     for (FBody b : p.getBodies ()) {
     g.pushMatrix();
     g.translate(b.getX(), b.getY());
     g.rotate(b.getRotation());
     if (b instanceof FBox) {          
     g.rectMode(CENTER);
     g.rect(0, 0, ((FBox)b).getWidth(), ((FBox)b).getHeight());
     } else if (b instanceof FCircle) {        
     g.ellipse(0, 0, ((FCircle)b).getSize(), ((FCircle)b).getSize());
     } else if (b instanceof FCircle) {        
     g.ellipse(0, 0, ((FCircle)b).getSize(), ((FCircle)b).getSize());
     }
     g.popMatrix();
     }
     }
     
     // ball
     g.pushMatrix();
     g.translate(ball.getX(), ball.getY());
     g.rotate(ball.getRotation());
     g.ellipse(0, 0, ball.getSize(), ball.getSize());
     g.popMatrix();    
     */

    // player axes
    if (showAxis) {
      for (Player p : players) {
        g.stroke(palette.OVERLAY);
        p.drawAxis(g);
      }
    }

    if (gameMode == PAUSED || gameMode == PLAYING) {
      g.fill(palette.OVERLAY);
      g.noStroke();
      g.textFont(scoreFont);
      g.textAlign(RIGHT, TOP);
      g.text(score[TEAM_A], fieldW/2 - 10, 10); 
      g.textAlign(LEFT, TOP);
      //g.fill(palette.TEAM_B);
      g.text(score[TEAM_B], fieldW/2 + 10, 10);
    }    

    if (showInfo) {
      g.fill(palette.OVERLAY);
      showInfo(g);
    }

    // arrows
    if (gameMode == PAUSED) {
      for (Player p : players) {

        float x = p.getBody().getX();
        float y = p.getBody().getY();
        float d = fieldW / 2 - x;
        float arrowHead = 10;
        g.strokeWeight(3);
        if (p.getTeam() == TEAM_A) {
          if (d < 0) {
            d = max(d, -100);
            arrowHead = min(abs(d), arrowHead);
            g.stroke(palette.OVERLAY);
            g.line(x, y, x + d, y);
            g.line(x + d, y, x + d + arrowHead, y + arrowHead);
            g.line(x + d, y, x + d + arrowHead, y - arrowHead);
          }
        } else if (p.getTeam() == TEAM_B) {
          if (d > 0) {
            d = min(d, 100);
            arrowHead = min(d, arrowHead);
            g.stroke(palette.OVERLAY);
            g.line(x, y, x + d, y);
            g.line(x + d, y, x + d - arrowHead, y + arrowHead);
            g.line(x + d, y, x + d - arrowHead, y - arrowHead);
          }
        }
      }
    }
    overlay.draw(g);
  }

  protected boolean toggleAxis() {
    showAxis = !showAxis;
    return showAxis;
  }

  protected boolean toggleInfo() {
    showInfo = !showInfo;
    return showInfo;
  }


  // Connect, disconnect and message events in the game:
  // -----------------------------------------------------------
  void message(Client c, String message) {
    String[] data = split(message, SEPARATOR);
    String label = data[0];
    // game related messages:
    if (c == null) {
      if (label.equals("make_teams")) {   
        makeTeams();
        // } else if (message.equals("ping")) {        
        //   Player p = getPlayer(c);
        //   if (p != null) p.ping();
      } else if (label.equals("reset_teams")) {        
        resetTeams();
      } else if (label.equals("toggle_info")) {
        log("info " + (toggleInfo() ? "enabled" : "disabled"));
      } else if (label.equals("toggle_axis")) {
        log("axes " + (toggleAxis() ? "enabled" : "disabled"));
      }
    } else {
      if (label.equals("init_class")) {  
        // we add e new Player tied to a Client object:
        // a few conditions must be true: 
        // 1. class must exist
        // 2. the client already exists... we remove the 
        // 3. we can't have multiple clients from the same IP
        String value = data[1];              
        Player p = getInstance(value);
        if (p == null) {
          log("Class [" + value + "] not found: player not initialized.");        
          return;
        } 

        if (getPlayer(c) != null) {
          log("Not initializing [" + value + "]: client already exists.");   
          return;
        }

        for (Player pl : players) {
          // we check against null because the player might be testPlayer (eg. has no client associated)
          if (pl.getClient() != null && pl.getClient().ip().equals(c.ip())) {          
            pl.kill();
          }
        }
        addPlayer(p, c);
        log("new player added: " + value);
      } else {
        // if it's not a game related message the message is forwarded to the player:
        Player p = getPlayer(c);
        if (p != null) p.message(message);
      }
    }
  }

  public void newClientEvent(Client c) {
    // A new client connected.
    // We can send some info, for example a list of found classes:
    // the client could eventually do some checking and see if the class it's trying 
    // to instantiate actually exists...
    String classNames = "";
    for (int i=0; i<classes.size (); i++) {
      classNames += classes.get(i).getSimpleName();
      if (i<classes.size()-1) {
        classNames += ',';
      }
    }
    c.write("class_names" + SEPARATOR + classNames + TERMINATOR);
  }

  public void disconnectEvent(Client c) {
    removePlayer(c);
  }


  // Private game methods
  // -----------------------------------------------------------
  private void makeTeams() {
    gameMode = PAUSED;
    int left = 0;
    int right = 0;
    score[TEAM_A] = 0;
    score[TEAM_B] = 0;
    for (Player p : players) {
      if (p.getBody().getX() < fieldW / 2) {
        p.setFillColor(palette.TEAM_A);
        p.setTeam(TEAM_A);
        p.setStrokeColor(color(0, 0, 0));        
        left++;
      } else {
        p.setFillColor(palette.TEAM_B);
        p.setTeam(TEAM_B);
        p.setStrokeColor(color(0, 0, 0));
        right++;
      }
    }   
    log("teams: " + left + " vs. " + right);
    overlay.show("NEW TEAMS\n" + left + " vs. " + right);
  }

  private void resetTeams() {
    overlay.show("FREE PLAY");
    gameMode = IDLE;
    for (Player p : players) {
      p.setFillColor(color(255, 255, 255));
      p.setStrokeColor(color(0, 0, 0));
    }
  }  

  // check if we can start a new game
  // with three conditions:
  private boolean isGameReady() {    
    // ball must be in center  
    float d = dist(areaBig.getX(), areaBig.getY(), ball.getX(), ball.getY());
    if (d > 20) return false;

    // 1. ball must stand still
    float vx = ball.getVelocityX();
    float vy = ball.getVelocityY();
    float v = dist(vx, vy, 0, 0);
    if (v > 10) return false;

    // 2. all the players must be in their own field
    for (Player p : players) {
      float x = p.getBody().getX();
      if (p.getTeam() == TEAM_A && x >= fieldW / 2) return false;
      else if (p.getTeam() == TEAM_B && x <= fieldW / 2) return false;
    }

    // 3. all the players must be outside the circle
    for (Player p : players) {
      ArrayList<FContact> contacts = p.getBody().getContacts();
      for (FContact c : contacts) {
        if (c.getBody1() == areaBig || c.getBody2() == areaBig) return false;
      }
    }
    return true;
  }

  // to avoid cheating we constrain the physics a bit
  private void constrainPlayerPhysics(Player p) {
    physics.processActions();     
    for (FBody b : p.bodies) {
      b.setDensity(constrain(b.getDensity(), 0.1, 5));
      if (!(b instanceof FBlob)) b.getBox2dBody().allowSleeping(false);
      //       b.setFriction(1);
      //       b.setDamping(1);    
      //       b.setRestitution(0.5);      
      //       b.setAngularDamping(10);
    }
  } 

  private void showInfo(PGraphics g) {
    String dots = new String();
    for (int i=0; i<24; i++) dots += "· ";
    dots += "\n";    
    String out = "";
    out += dots;
    try {
      out += "ip: " + server.ip() + "\n";
    } 
    catch (Exception e) {
      out += "ip: DISCONNECTED \n";
    }
    out += dots;

    out += "port: " + PORT + "\n";
    out += dots;
    out += "fps: " + round(frameRate) + "\n";
    out += dots;
    out += "num players: " + players.size() + "\n";
    out += dots;
    out += log;
    g.pushStyle();
    g.textAlign(LEFT, TOP);
    g.textFont(consoleFont);
    g.textLeading(14);
    g.text(out, 20, 30);    
    g.popStyle();
  }

  private void log(String a) {   
    //println(a); 
    fullLog.append(a + '\n');    
    String[] l = split(trim(fullLog.toString()), '\n');
    int from = max(0, l.length - 1);
    int to = max(0, from - 10); 
    log = "";
    for (int i=from; i>= to; i--) {
      log += i + " > " + l[i] + "\n";
    }
  }  

  // Private java reflection functions
  // -----------------------------------------------------------
  private ArrayList<Class> scanClasses(PApplet parent, String superClassName) {
    ArrayList<Class> classes = new ArrayList<Class>();  
    println("------------------------------------------------------");
    println("Classes which extend " + superClassName + ":");  
    String infoText = "";
    Class[] c = parent.getClass().getDeclaredClasses();
    for (int i=0; i<c.length; i++) {
      if (c[i].getSuperclass() != null && (c[i].getSuperclass().getSimpleName().equals(superClassName) )) {
        classes.add(c[i]);
        int n = classes.size()-1;
        String numb = str(n);
        if (n < 10) numb = " " + n;
        infoText += numb + "     " + c[i].getSimpleName() + "\n";
      }
    }
    println(infoText);
    return classes;
  }

  private Player getInstance(String className) {
    Player p = (Player)createInstance(className);
    return p;
  }

  private Object createInstance(int i) {
    if (i < 0 || i >= classes.size()) return null;

    Player p = null;
    try {
      Class c = classes.get(i);
      Constructor[] constructors = c.getConstructors();
      p = (Player) constructors[0].newInstance(parent);
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
    return p;
  }

  private Object createInstance(String className) {
    int index = -1;
    for (int i=0; i<classes.size (); i++) {  
      if (classes.get(i).getSimpleName().equals(className)) {
        index = i;
        break;
      }
    }

    if (index >= 0) return createInstance(index);
    return null;
  }

  // Mini sub classes
  // -----------------------------------------------------------
  class Palette {
    int OVERLAY;
    int TEAM_A, TEAM_A_LIGHT;
    int TEAM_B, TEAM_B_LIGHT;
    int FIELD_LINES;
    Palette(String bmp) {
      int[] pal = loadImage(bmp).pixels;
      OVERLAY      = pal[0];
      TEAM_A       = pal[1];
      TEAM_A_LIGHT = pal[2];
      TEAM_B       = pal[3];
      TEAM_B_LIGHT = pal[4];
      FIELD_LINES  = pal[5];
    }
  }

  class Overlay {
    int col;
    int counter = 0;
    String str;
    PFont font;
    final static int DURATION = 100; // frames

    Overlay(PFont f) {
      str = new String();
      font = f;
    }

    void show(String s) {
      show(s, palette.OVERLAY);
    }

    void show(String s, int col) {
      counter = DURATION;
      str = s;
      this.col = col;
    }

    void draw(PGraphics g) {
      if (counter > 0) {
        counter--;
        float a = map(min(counter, 50), 0, 50, 0, 255);
        g.pushStyle();
        g.noStroke();
        g.textAlign(CENTER, CENTER);        
        g.textFont(font);
        g.textLeading(180);
        g.fill(col, a);
        g.text(str, parent.width/2, parent.height/2);
        g.popStyle();
      }
    }
  }
}
