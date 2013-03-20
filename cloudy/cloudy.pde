//TODO
//ILLUSTRATOR make clouds transparent. make clouds smaller
//INSTALLATION Try Andrew's wide throw projector. Test sound levels. Add a control that resets base sound levels.
//How does the velocity relate to weight?
//When the effect takes a few cycles, it is much better - or maybe have the initial velocity reset? Or maybe change the interval?
//Make sure the new random is not the same as the last random.
//Can I change the acceleration to respond to something like the amplitude instead of just an ON/OFF?
//Parallax style movement. Generate x location based on cloud width.
//How to model speed of clouds
//Clouds need to be in sets?

String[] cloudNames = {
  "simpsons", "simpsons", "simpsons", "simpsons", "simpsons"
};                       

/*String[] cloudNames = {
  "simpsons", "simpsons", "simpsons", "simpsons", "simpsons"
};*/                       

//float[] cloudTypes = new float[cloudNames.length];
float[] cloudTypes = {1,2,1,2,1};
float[] cloudWidths = new float[cloudNames.length];
ArrayList<Cloud> clouds;
PVector wind = new PVector(0, 0);
PImage grad;
PImage gradl;
float threshold = 0.4;

//Intervals for cloud generation. //Change in case if sound exists - or divide by current velocity?
int lastTime;
int interval = 4000;

int lastIndex; //To make sure the same cloud is not repeated.

import ddf.minim.*;

Minim minim;
AudioInput in;

void setup() {
  //cloudTypes = generateWeights(cloudNames);  
  size(800, 600);
  //translate(0,0,-100); Need to add P3D to size for this to work.
  frame.setBackground(new java.awt.Color(0, 0, 0)); //Background for full screen view
  smooth();
  clouds = new ArrayList();
  int index = int(random(cloudNames.length));
  clouds.add(new Cloud(-200, random(300), cloudNames[index], cloudTypes[index]));
  grad = loadImage("grad.png");
  gradl = loadImage("gradl.png");
  grad.resize(grad.width, height);
  gradl.resize(gradl.width, height);

  minim = new Minim(this);
  in = minim.getLineIn( Minim.MONO, 512 );
  lastTime = millis();
}

void draw() {
  background(0);

  float m = 0;
  for (int i = 0; i < in.bufferSize() - 1; i++) {
    if ( abs(in.mix.get(i)) > m ) {
      m = abs(in.mix.get(i));
    }
  }
  if (m > threshold) {
    wind = new PVector(m, 0);
  } 
  else {
    wind.mult(0);
  }


  Iterator<Cloud> itl = clouds.iterator();
  while (itl.hasNext ()) {
    Cloud c = itl.next();

    PVector f = c.calcForce();
    //println(f);    
    c.applyForce(wind);
    if (wind.mag()==0) {
      c.applyForce(f);
    } 
    c.run();

    if (c.location.x > width) {
      //c.location.x = 0;
      itl.remove();
    }
  }

  image(gradl, 0, 0);
  image(grad, width-grad.width, 0);
  //Shape and gradient are way slow! Image works.

  //Add clouds every interval
  if (millis()>lastTime+interval) {
    lastTime = millis();
    addCloud();
  }
}

void mousePressed(){
  addCloud();
}

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


void addCloud() {
  int index = int(random(cloudNames.length));
  //Make sure the new cloud is not the same as the old cloud
  /*while (index == lastIndex) {
    index = int(random(cloudNames.length));
  }
  lastIndex = index;*/
  float vLoc = random(300); //vertical location
  //lastVLoc = vLoc;

  clouds.add(new Cloud(-200, vLoc, cloudNames[index], cloudTypes[index]));
}

//shape(grad,width-grad.width,0,grad.width,height);
//setGradient(width-100, 0, 100, height, c2, c1);
void setGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();
  for (int i = x; i <= x+w; i++) {
    float inter = map(i, x, x+w, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(i, y, i, y+h);
  }
}

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
    velocity = new PVector(0.8*(1/d), 0); //Should velocity be *(1/m)
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

