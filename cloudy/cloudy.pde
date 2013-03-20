//TODO
//ILLUSTRATOR make clouds transparent. make clouds smaller
//INSTALLATION Test sound levels. Add a control that resets base sound levels.
//Can I change the acceleration to respond to something like the amplitude instead of just an ON/OFF? People do shrieks also
//Generate x location based on cloud width. //Vertical variation
//Different clouds


String[] cloudNames = {
  "simpsons", "mario", "peanuts", "toystory", "icloud"
};
//The types of clouds in each set
float[][] setDetails = { {1,2,1},
                         {1,1,1},
                         {1,1.5,0.8},
                         {1,1.5,1},
                         {1} };

ArrayList<Cloud> clouds;
PVector wind = new PVector(0, 0);
PImage grad;
PImage gradl;
float threshold = 0.4;
Boolean flag = false; //To avoid adding to the list while iterating, this flag is set to true and false which then adds a new cloud to the mix
int counter; //Keeps track of the clouds in each set
int vrange = 200;

//Intervals for cloud generation. //Change in case if sound exists - or divide by current velocity?
int lastTime;
int interval = 4000;

// The cloudset being added
int activeSet;

import ddf.minim.*;

Minim minim;
AudioInput in;

void setup() {
  frame.setBackground(new java.awt.Color(0, 0, 0)); //Background for full screen view
  size(800, 600);
  smooth();

  //Initialize the first cloud set
  activeSet = 0;
  clouds = new ArrayList();

  counter = setDetails[activeSet].length;
  //Add the initial cloud types
  for(int i=0; i<counter; i++){
      clouds.add(new Cloud(-200*i, random(vrange), cloudNames[activeSet], setDetails[activeSet][i]));  
  }
  
  //Adds black gradient strips on either sides
  grad = loadImage("grad.png");
  gradl = loadImage("gradl.png");
  grad.resize(grad.width, height);
  gradl.resize(gradl.width, height);
  
  //Initialize Minim for sound stuff
  minim = new Minim(this);
  in = minim.getLineIn( Minim.MONO, 512 );
  lastTime = millis();
}

void draw() {
  background(0);
  if(flag){
    for(int i=0; i<counter; i++){
        clouds.add(new Cloud(-200*i, random(vrange), cloudNames[activeSet], setDetails[activeSet][i]));  
    }
  }
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

  flag = false;
  Iterator<Cloud> itl = clouds.iterator();
  while (itl.hasNext ()) {
    Cloud c = itl.next();

    PVector f = c.calcForce();
    c.applyForce(wind);
    //bring speed back to base velocity
    if (wind.mag()==0) {
      c.applyForce(f);
    } 
    c.run();

    if (c.location.x > width) {
      itl.remove();
      counter--;
      updateCloudStyle();      
    }
  }

  image(gradl, 0, 0);
  image(grad, width-grad.width, 0);
  //Shape and gradient are way slow! Image works.

  //Add clouds every interval
  /*if (millis()>lastTime+interval) {
    lastTime = millis();
    addCloud();
  }*/
}

void mousePressed(){
  //change the cloud set being added
  addCloud();
}

void updateCloudStyle(){
    if(counter==0){
      if(activeSet < cloudNames.length-1){
        activeSet++;
      } else {
        activeSet = 0;
      }
      flag = true;        
      counter = setDetails[activeSet].length;    
    } 
}

void cycleType(){

}

void addCloud() {
  //int index = int(random(cloudNames.length));
  //Make sure the new cloud is not the same as the old cloud
  /*while (index == lastIndex) {
    index = int(random(cloudNames.length));
  }
  lastIndex = index;*/
  float vLoc = random(vrange); //vertical location
  //lastVLoc = vLoc;

  clouds.add(new Cloud(-200, vLoc, cloudNames[activeSet], 1));
}
