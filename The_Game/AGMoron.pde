public class AGMoron extends Player {

  FBody body;
  FDistanceJoint dj;
  FRevoluteJoint rj1, rj2;
  float maxAng;

  public AGMoron() {
    name = "Moron";
    author = "Andreas Gysin";
  }

  // let's build the physics
  void make(float px, float py) {

    float scale = 1;
    float w = 75 * scale;
    float h = 18 * scale;
    float sideW = 85 * scale;
    float sideH = 6 * scale;

    // the first body added becomes the "main body" by default
    body = new FBox(w, h);
    body.setPosition(px, py); // important!
    body.setRestitution(0.6);  
    body.setDamping(10);
    body.setDensity(3.5);
    body.setAngularDamping(8.0);    
    add(body);

    FBox left = new FBox(sideW, sideH);
    left.setPosition(px + sideW/2 + w/2, py-(h/2+sideH/2));
    add(left);

    FBox right = new FBox(sideW, sideH);
    right.setPosition(px + sideW/2 + w/2, py+(h/2+sideH/2));
    add(right);

    rj1 = new FRevoluteJoint(body, left, px + w/2, py-h/2);
    rj1.setLowerAngle(-1.2);
    rj1.setUpperAngle(0);    
    rj1.setMaxMotorTorque(1000);
    rj1.setEnableLimit(true);
    rj1.setEnableMotor(true);
    add(rj1);

    rj2 = new FRevoluteJoint(body, right, px + w/2, py+h/2);
    rj2.setLowerAngle(0);
    rj2.setUpperAngle(1.2);    
    rj2.setMaxMotorTorque(1000);
    rj2.setEnableLimit(true);
    rj2.setEnableMotor(true);
    add(rj2);

    FBox bumper = new FBox(h, h);
    bumper.setPosition(px + w/2, py);
    add(bumper);

    dj = new FDistanceJoint(body, bumper);
    dj.setFrequency(50);
    add(dj);

    FPrismaticJoint pj = new FPrismaticJoint(body, bumper);
    //pj.setEnableLimit(true);
    pj.setLowerTranslation(0);
    pj.setUpperTranslation(100); 
    pj.setAnchor(px, py);
    pj.setAxis(1, 0);
    add(pj);
  }

  // void onMessage(String msg) {
  //   String[] m = split(msg, SEPARATOR);
  //   if (m.length > 0) {
  //     String label = m[0];
  //     if (label.equals("bumper_length")){
  //       float v = float(m[1]);
  //     }
  //   }
  // }

  void loop() {
    if (buttons.get("btn_up")) {
      float a = body.getRotation();
      float fx = cos(a) * 85;
      float fy = sin(a) * 85;
      body.adjustVelocity(fx, fy);
    }
    if (buttons.get("btn_left")) {
      body.adjustAngularVelocity(-1);
    }
    if (buttons.get("btn_right")) {
      body.adjustAngularVelocity(1);
    }
    if (buttons.get("btn_down")) {
      float a = body.getRotation();
      float fx = -cos(a) * 85;
      float fy = -sin(a) * 85;
      body.adjustVelocity(fx, fy);
    }
  }

  void onButtonDown(String which) {
    if (which.equals("btn_one")) {
      dj.setLength(100);
    } else if (which.equals("btn_two")) {
      rj1.setMotorSpeed(-100);
      rj2.setMotorSpeed( 100);
    }
  }

  void onButtonUp(String which) {
    if (which.equals("btn_one")) {      
      dj.setLength(45);
    } else if (which.equals("btn_two")) {
      rj1.setMotorSpeed( 100);
      rj2.setMotorSpeed(-100);
    }
  }
}
