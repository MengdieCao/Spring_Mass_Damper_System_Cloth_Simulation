class Cloth { //<>// //<>//
  boolean isEuler = false;
  int numWidth;
  int numHeight;
  Particle[] particles;
  ArrayList<Spring> springs = new ArrayList<Spring>();
  ArrayList<Polygon> polygons = new ArrayList<Polygon>();
  //Ball ball = new Ball(new PVector(393,577,30),new PVector(0,0,-10));
  boolean edgeCollide = false;
  Particle getParticle(int i, int j) {
    return particles[j*numWidth+i];
  }

  void makeConstraint(Particle p1, Particle p2) {
    springs.add(new Spring(p1, p2));
  }

  PVector calcTriNorm(Particle p1, Particle p2, Particle p3) {
    PVector pos1 = p1.getPos().copy();
    PVector pos2 = p2.getPos().copy();
    PVector pos3 = p3.getPos().copy();
    PVector v1 = pos2.sub(pos1);
    PVector v2 = pos3.sub(pos1);
    return v1.cross(v2);
  }



  void applyWindForce(Particle p1, Particle p2, Particle p3, PVector direction) {
    PVector norm = calcTriNorm(p1, p2, p3);
    PVector d = norm.copy().normalize();
    PVector force = norm.mult(d.dot(direction));
    PVector pos1 = p1.getPos().copy();
    PVector pos2 = p2.getPos().copy();
    PVector pos3 = p3.getPos().copy();
    float a213 = PVector.angleBetween(pos2.copy().sub(pos1), pos3.copy().sub(pos1));
    float a123 = PVector.angleBetween(pos1.copy().sub(pos2), pos3.copy().sub(pos2));
    p1.addForce(force.copy().mult(degrees(a213)/180));
    p2.addForce(force.copy().mult(degrees(a123)/180));
    p3.addForce(force.copy().mult((180-degrees(a213)-degrees(a123))/180));
  }

  Cloth(float cWidth, float cHeight, int numWidth, int numHeight) {
    this.numWidth = numWidth;
    this.numHeight = numHeight;
    particles = new Particle[numWidth*numHeight];

    for (int x = 0; x < numWidth; x++) {
      for (int y = 0; y < numHeight; y++) {
        PVector pos = new PVector(cWidth * (x/(float)(numWidth-1))+startX, 
          cHeight * (y/(float)(numHeight-1))+startY, 
          random(-0.1, 0.1));
        particles[y*numWidth+x] = new Particle(pos);
      }
    }

    //connecting immediate neighbor particles with springs
    for (int x = 0; x < numWidth; x++) {
      for (int y = 0; y < numHeight; y++) {
        if (x<numWidth-1) makeConstraint(getParticle(x, y), getParticle(x+1, y));
        if (y<numHeight-1) makeConstraint(getParticle(x, y), getParticle(x, y+1));
        if (x<numWidth-1 && y<numHeight-1) makeConstraint(getParticle(x, y), getParticle(x+1, y+1));
        if (x<numWidth-1 && y<numHeight-1) makeConstraint(getParticle(x+1, y), getParticle(x, y+1));
      }
    }

    //connecting secondary neighbors with springs
    for (int x = 0; x < numWidth; x++) {
      for (int y = 0; y < numHeight; y++) {
        if (x<numWidth-2) makeConstraint(getParticle(x, y), getParticle(x+2, y));
        if (y<numHeight-2) makeConstraint(getParticle(x, y), getParticle(x, y+2));
        if (x<numWidth-2 && y<numHeight-2) makeConstraint(getParticle(x, y), getParticle(x+2, y+2));
        if (x<numWidth-2 && y<numHeight-2) makeConstraint(getParticle(x+2, y), getParticle(x, y+2));
      }
    }
    
    addPolygon();
    //pin the upper corners (unmovable)
    for (int i = 0; i < 3; i++) {
      getParticle(0+i, 0).offsetPos(new PVector(0.5, 0, 0));
      getParticle(0+i, i).makeUnmovable();
      getParticle(numWidth-1-i, 0).offsetPos(new PVector(-0.5, 0, 0));
      getParticle(numWidth-1-i, 0).makeUnmovable();
    }
  }

  void integration() {
    //cloth.ballClothCollision(new PVector(450,350,cos(ballTime/90)*70),60);
    //vertexFace(new PVector(450,350,10));
    getNewAcce();//50,400,300,50,400,-100
    updatePrevM();
    if (isEuler) {
      for (int i = 0; i < particles.length; i++) {
        particles[i].euler();
      }
    } else {
      applyRK4();
    }
    updateNewM();
    checkEdgeEdge();
    //cloth.ballClothCollision(new PVector(450,350,cos(ballTime/90)*70),60);
    //vertexFace(new PVector(450,350,10));
  }

  void getNewAcce() {
    for (int i = 0; i < springs.size(); i++) {
      springs.get(i).springDamping();
    }
  }

  void updatePrevM() {
    for (int i = 0; i < springs.size(); i++) {
      springs.get(i).prevM = springs.get(i).calculateM(new PVector(700, 400, 300), new PVector(700, 400, -300));
    }
  }

  void updateNewM() {
    for (int i = 0; i < springs.size(); i++) {
      springs.get(i).newM = springs.get(i).calculateM(new PVector(700, 400, 300), new PVector(700, 400, -300));
    }
  }

  void checkEdgeEdge() {
    edgeCollide = false;
    for (int i = 0; i < springs.size(); i++) {
      if (springs.get(i).prevM.copy()!=null && springs.get(i).newM.copy()!=null) {
        if (springs.get(i).prevM.copy().dot(springs.get(i).newM.copy())<0) {
          edgeCollide = true;
          springs.get(i).edgeEdgeResponse();
        }
      }
    }
  }

  void applyRK4() {
    for (int i = 0; i < particles.length; i++) {
      particles[i].RKPass1();
      if (particles[i].movable) {
        //println(i+"th: "+ "pos(" + particles[i].pos.x+","+particles[i].pos.y+")");
      }
    }
    windForce(wind);
    cloth.addForce(gravity);
    getNewAcce();

    for (int i = 0; i < particles.length; i++) {
      particles[i].RKPass2();
    }
    windForce(wind);
    cloth.addForce(gravity);
    getNewAcce();
    //println(particles[15].acce.x+","+particles[15].acce.y);
    for (int i = 0; i < particles.length; i++) {
      particles[i].RKPass3();
    }
    windForce(wind);
    cloth.addForce(gravity);
    getNewAcce();
    for (int i = 0; i < particles.length; i++) {
      particles[i].RKPass4();
    }
  }

 

  //add gravity or any other external forces
  void addForce(PVector direction) {
    for (int i = 0; i < particles.length; i++) {
      particles[i].addForce(direction);
    }
  }
  //add wind force
  void windForce(PVector direction) {
    for (int x = 0; x < numWidth-1; x++) {
      for (int y = 0; y < numHeight-1; y++) {
        applyWindForce(getParticle(x+1, y), getParticle(x, y), getParticle(x, y+1), direction);
        
        applyWindForce(getParticle(x+1, y+1), getParticle(x+1, y), getParticle(x, y+1), direction);
        
      }
    }
  }
  
  void addPolygon(){
    for (int x = 0; x < numWidth-1; x++){
      for (int y = 0; y < numHeight-1; y++){
        polygons.add(new Polygon(getParticle(x+1, y), getParticle(x, y), getParticle(x, y+1)));
        polygons.add(new Polygon(getParticle(x+1, y+1), getParticle(x+1, y), getParticle(x, y+1)));
      }
    }
    
  }

  //void vertexFace(PVector vertex){
  //  for (int i = 0; i < polygons.size(); i++){
  //    Polygon currPoly = polygons.get(i);
  //    if (detectCollision(currPoly,vertex)) {
  //      bounce(currPoly);
  //    }
  //  }
  //}

//boolean detectCollision(Polygon currPoly, PVector vertex) {
//   if (currPoly.hitPlane(vertex)) {
//      //println(spd);
//      PVector hittingPoint=currPoly.hittingPoint(vertex);
//      PVector projCoord=currPoly.getProjectionCoord(hittingPoint);
//      if (currPoly.insidePolygon(projCoord)) {

//        return true;
//      }
//    }
//    return false;
//  }
  
//  void bounce(Polygon currPoly) {
//    currPoly.p1.vel = currPoly.relativeVel.copy();
//    currPoly.p2.vel = currPoly.relativeVel.copy();
//    currPoly.p3.vel = currPoly.relativeVel.copy();
//    Particle p1 = currPoly.p1;
//    Particle p2 = currPoly.p2;
//    Particle p3 = currPoly.p3;
//    //float distToPlane = vertex.copy().sub(p1.pos).dot(calcTriNorm(p1, p2, p3));
//    p1.pos.copy().add(p1.vel);
//    p2.pos.copy().add(p2.vel);
//    p3.pos.copy().add(p3.vel);
//    //p2.offsetPos(p1.pos.copy().sub(vertex));
//   //p3.offsetPos(p1.pos.copy().sub(vertex));
//  }

  void flickCloth(PVector vertex) {
    for (int x = 0; x < numWidth-1; x++) {
      for (int y = 0; y < numHeight-1; y++) {
        Particle p1 = getParticle(x+1, y);
        Particle p2 = getParticle(x, y);
        Particle p3 = getParticle(x, y+1);
        //Particle p4 = getParticle(x+1,y+1);
        float distToPlane = vertex.copy().sub(p1.pos).dot(calcTriNorm(p1, p2, p3));
        if (distToPlane < 0) {
           

            p1.offsetPos(p1.pos.copy().sub(vertex).normalize().mult(-1));
            p2.offsetPos(p1.pos.copy().sub(vertex).normalize().mult(-1));
            p3.offsetPos(p1.pos.copy().sub(vertex).normalize().mult(-1));
           
        }
      }
    }
  }

  



  void ballClothCollision(PVector vertex, float r) {
    for (int i = 0; i < particles.length; i++) {
      PVector distV = particles[i].pos.copy().sub(vertex);
      if (distV.magSq()<pow(r,2)) {
        particles[i].offsetPos(distV.copy().normalize().mult(r-distV.mag()));
        particles[i].vel.set(0,0,0);
      }
    }
    //println(particles[200].pos.x+","+particles[200].pos.y);
  }


  void update() {
    windForce(wind);
    cloth.addForce(gravity);
    //ball.update();
    //cloth.ballClothCollision(new PVector(450,350,cos(ballTime/90)*70),60);
    integration();
  }

  void display() {
    for (int x = 0; x < numWidth-1; x++) {
      beginShape(TRIANGLE_STRIP);
      for (int y = 0; y < numHeight; y++) {

        PVector p1=getParticle(x+1, y).getPos();
        PVector p2=getParticle(x, y).getPos();
        fill(200, 20, 20);
        vertex(p1.x, p1.y, p1.z);
        fill(230, 230, 230);
        vertex(p2.x, p2.y, p2.z);
        //PVector p3=getParticle(x,y+1).getPos();
        //triangle(p1.x,p1.y,p1.z,p2.x,p2.y,p2.z,p3.x,p3.y,p3.z);
      }
      endShape();
    }
    //ball.display();

    //println(frameCount);
  }
}