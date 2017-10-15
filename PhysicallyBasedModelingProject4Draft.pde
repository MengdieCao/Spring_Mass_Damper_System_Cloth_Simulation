Cloth cloth;
PVector nozzle;
float ballTime = 0;
float startX=100;
float startY=100;
PVector wind=new PVector(0.0002, 0.0002, 0.0000001);
PVector gravity=new PVector(0, 0.01, 0);
ArrayList<Ball> balls;
float cr=0.4;
float cf=0.3;
boolean hasSphere = false;
boolean hasParticles = false;
PVector ballPos;

//PVector vertex = new PVector(450, 350, 0);
//Ball ball = new Ball(new PVector(393,577,30),new PVector(0,-0.01,-0.01));
void setup() {
  size(1080, 720, P3D);
  //colorMode(HSB,360,100,100);
  cloth=new Cloth(600, 360, 20, 12);
  nozzle=new PVector(450, 250, 400);
  balls = new ArrayList<Ball>();
}

void draw() {
  background(0);
  //rotateY(PI/3);
  rotateY(map(mouseX, 0, width, 0, -PI));
  ballTime++;
  if (hasParticles) {
    for (int i = 0; i < balls.size(); i++) {
      balls.get(i).update();
      balls.get(i).display();
    }
    for (int i=balls.size()-1; i>=0; i--) {
      if (balls.get(i).isDead()) {
        balls.remove(i);
      }
    }


    for (int i=0; i<1; i++) {
      balls.add(new Ball(nozzle, new PVector(random(-0.5, 0.5), random(-0.5, 0.5), -3)));
      //balls.add(new Ball(nozzle, new PVector(0,0,-3)));
    }
  }
  //pushMatrix();

  //noStroke();
  lights();


  stroke(126);
  strokeWeight(1);
  cloth.update();
  cloth.display();

  translate(450, 350, cos(ballTime/70)*90);
  if (hasSphere) {
    ballPos=new PVector(450, 350, cos(ballTime/70)*90);
    cloth.ballClothCollision(new PVector(450, 350, cos(ballTime/70)*90), (float)60);
    sphere(60);
  }
  //rotateY(0.5);
  //rotateX(0.5);
  //box(40);
  
if (cloth.edgeCollide){
  //strokeWeight(3);
  stroke(255,0,0);
}
  //stroke(126);
  
  line(700-450, 400-350, 300-cos(ballTime/70)*90, 700-450, 400-350, -300-cos(ballTime/70)*90);


  if (mousePressed && mouseButton == LEFT) {
    cloth.flickCloth(new PVector(mouseX, mouseY, 0));
  }

  //popMatrix();

  //ellipse(mouseX,mouseY,10,10);
  //cloth.vertexFace(new PVector(mouseX, mouseY, random(-5,5)));
  //cloth.flickCloth(new PVector(mouseX,mouseY,0));




  //fill(255);
  //PVector p=cloth.particles[1].getPos();
  //ellipse(p.x,p.y,30,30);
  //println(p.x,p.y);
}