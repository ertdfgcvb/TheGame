public abstract class Player {

  protected ArrayList<FBody> bodies;
  protected ArrayList<FJoint> joints;
  protected FBody mainBody;
  protected FWorld physics;
  protected Game game;
  protected Client client;  
  protected int myTeam;

  private boolean alive;

  String author;
  String name;
  HashMap<String, Boolean> buttons; // just a list

  public Player() {
    alive = true;
    buttons = new HashMap();
    // we provide some default buttons:
    // up, down, left, right
    // and
    // one, two, three, four    
    buttons.put("btn_one", false);
    buttons.put("btn_two", false);
    buttons.put("btn_three", false);
    buttons.put("btn_four", false);
    buttons.put("btn_up", false);
    buttons.put("btn_down", false);
    buttons.put("btn_left", false);
    buttons.put("btn_right", false);

    bodies = new ArrayList();
    joints = new ArrayList();
    name = "Poor Bastard";
    author = "Anonimous";
  }

  // ---------------------------------------------------------
  // abstract & overridable methods
  abstract void make(float px, float py);
  
  void onMessage(String message) {
    println("Received a custom message: " + message);
  }
  void loop() {
    // a multipurpose loop
  }
  void onButtonDown(String button) {
    println("buttonDown: " + button);
  }
  void onButtonUp(String button) {
    println("buttonUp: " + button);
  }

  public final void kill() {
    alive = false;
  }

  public final boolean isAlive() {
    return alive;
  }

  public final ArrayList<FBody> getBodies() {
    return bodies;
  }
  
  public final ArrayList<FJoint> getJoints() {
    return joints;
  }  

  public final FBody getBody() {
    return mainBody;
  }
  public final int getTeam() {
    return myTeam;
  }
  public final String getName() {
    return name;
  }

  public final Client getClient() {
    return client;
  }

  public final void setTeam(int t) {
    myTeam = t;
  }

  public final void init(Game game, Client client, FWorld physics) {
    this.physics = physics;
    this.client = client;
    this.game = game;
  }

  public final void add(FBody body) {
    if (bodies.size() == 0) setMainBody(body);
    bodies.add(body);
    physics.addBody(body);
  }

  public final void add(FJoint joint) {
    joints.add(joint);
    physics.addJoint(joint);
  }

  public final void remove(FBody body) {
    if (bodies.remove(body)) {
      physics.removeBody(body);
    }
  } 

  public final void setFillColor(color col) {
    for (FBody b : bodies) {
      b.setFillColor(col);
      b.setDrawable(true);
    }
    for (FJoint j : joints) {
      j.setFillColor(col);
      j.setDrawable(true);
    }
  }

  public final void setStrokeColor(color col) {
    for (FBody b : bodies) {
      b.setStrokeColor(col);
      b.setStrokeWeight(1);
    }
    for (FJoint j : joints) {
      j.setStrokeColor(col);
      j.setStrokeWeight(1);
    }
  }

  public final void setNoStroke() {
    for (FBody b : bodies) {
      b.setNoStroke();
    }
    for (FJoint j : joints) {
      j.setNoStroke();
    }
  }



  public final void setMainBody(FBody body) {
    mainBody = body;
  }

  public final void message(String message) {
    message = trim(message);
    String[] m = split(message, SEPARATOR);
    if (m.length > 0) {
      String label = m[0];

      if (label.equals("button")) {
        String button = m[1];
        if (buttons.containsKey(button)) {
          int status = int(m[2]);
          if (status != 0) {          
            if (!buttons.get(button)) {
              onButtonDown(button);
              buttons.put(button, true);
            }
          } else {
            if (buttons.get(button)) {
              onButtonUp(button);
              buttons.put(button, false);
            }
          }
        } else {
          println("Warning: button " + button + " is not defined");
        }
      } else if (label.equals("reset")) {
        //TO DO: do some reset here...
      } else {
        onMessage(message);
      }
    }
  }

  public final void removeFromWorld() {
    for (FJoint j : joints) physics.removeJoint(j);
    for (FBody b : bodies) physics.removeBody(b);
  }

  public final void drawAxis(PGraphics g) {
    float x = mainBody.getX();
    float y = mainBody.getY();
    float a = mainBody.getRotation();
    float r = 120;
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(a);
    g.noFill();
    g.ellipse(0, 0, r*2, r*2);
    g.line(0, 0, r*1.2, 0);
    g.line(r*1.2, 0, r*1.2 - 10, 10);
    g.line(r*1.2, 0, r*1.2 - 10, -10); 
    g.line(0, 0, 0, r);
    g.ellipse(0, 0, 8, 8);    
    g.popMatrix();
  }
}
