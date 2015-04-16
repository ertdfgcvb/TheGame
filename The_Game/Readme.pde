/*
The Game


Workflow:
  1. Create a new player by extending the Player Class
     The player must fit in the "max area" (red circle)
  2. Name the Player with your initials and a name
     for example:
     [A]ndreas + [G]ysin + [Moron] = AGMoron
     Respect the UpperCamelCase convention
  3. Create a controller which connects to the game and instantiates the Player in the main game
  4. Define the controls (mouse, keyboard, sliders, etc) inside the controller
  5. Send (custom) messages to your player to test it
  6. Build a team
  7. Play!

Fisica cheatsheet:
  for the detailled docs see:
  http://www.ricardmarxer.com/fisica/reference/index.html

  Rigid bodies (FBox, FCircle, FPoly, FCompound)
    .setRestitution();
    .setDamping();
    .setDensity();
    .setAngularDamping();
    .setPosition() <--- Dont use for kinetics, use for object creation;
    - - - - - - - - - - - - - - - - - - - - -
    .adjustVelocity();
    .adjustAngularVelocity();
    - - - - - - - - - - - - - - - - - - - - -
    .getX();
    .getY();
    .getWidth();  // FBox
    .getHeight();
    .getSize();   // FCircle
    .getRotation();

  FDistanceJoint:
    .setFrequency();
    .setLength();

  FRevoluteJoint:
    .setLowerAngle();
    .setUpperAngle();
    .setMaxMotorTorque();
    .setEnableLimit();
    .setEnableMotor();
    - - - - - - - - - - - - - - - - - - - - -
    .setMotorSpeed();

  FPrismaticJoint:
    .setEnableLimit(true);
    .setLowerTranslation();
    .setUpperTranslation();
    .setAnchor();
    .setAxis();

Origins:
  SpeedBall 2 - Brutal Deluxe
  Play it in your browser (Chrome):
  https://archive.org/details/msdos_Speedball_2_-_Brutal_Deluxe_1992

TCP vs UDP:
  see:
  http://gafferongames.com/networking-for-game-programmers/udp-vs-tcp/


*/
