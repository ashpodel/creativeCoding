//CLOUD CLASS

class Cloud {
  PVector location;
  PVector velocity;
  PVector base; //base velocity
  PVector acceleration;
  String type;
  float w;
  PShape s;
  float topspeed;
  float maxforce;
  float d; //distance (from the viewing point)
  String t; //kind of cloud
  float m; //mass, not relevant here


  Cloud(float x, float y, String type, float dis) {
    d = dis;
    location = new PVector(x, y);
    velocity = new PVector(1*(1/d), 0); //Should velocity be *(1/m)
    base = velocity.get();
    acceleration = new PVector(0, 0);
    s = loadShape(type+".svg");
    w = s.width;
    s.scale(1/d);//You fool, if you do it in the update function, the shape is so shrunk by the time it arrives, that you don't see it.
    topspeed = 100;
    maxforce = 0.1;
    t = type;
    m = 1;
  }

  void run() {
    update();
    display();
  }

  //Bring speed back to base velocity
  PVector calcForce() {
    PVector steer = base.get();
    steer.sub(velocity);
    steer.normalize();    
    return steer;
  }

  void update() {
    acceleration.limit(maxforce);    
    velocity.add(acceleration);
    velocity.limit(topspeed);    
    location.add(velocity);
    acceleration.mult(0);
  }

  void applyForce(PVector force) {
    PVector f = force.get();
    f.div(m);
    acceleration.add(f);
  }  

  void display() {
    //loadCloud(t);
    //w = s.width;
    //s.disableStyle();
    //fill(255,220);
    //noStroke();
  
    shape(s, location.x, location.y);
    //s.scale(.9);  
  }
}

//EXTRAS (CONSIDER DELETING)
float[] generateWeights(String[] names) {
  float[] rawWeights = new float[names.length];  
  for (int i=0; i<names.length;i++) {
    PShape sh = loadShape(names[i]+".svg");
    float mul = sh.width*sh.height;
    rawWeights[i] = mul;
    println(names[i]+":"+mul);
  }
  float maxWeight = sort(rawWeights)[rawWeights.length-1];
  float minWeight = sort(rawWeights)[0];
  println(maxWeight);
  println(minWeight);  
  for (int i=0; i<rawWeights.length;i++) {
    rawWeights[i] = map(rawWeights[i], minWeight, maxWeight, 0.5, 1);
  }
  println(rawWeights);
  return rawWeights;
}


