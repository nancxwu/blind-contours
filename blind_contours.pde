import geomerative.*;
import processing.sound.*;

int numHands =17;
int numPoints = 1603;
RShape[] hands = new RShape[numHands];
RShape first;

RPoint[] cur;
RPoint[] target;
float shiftCurX;
float shiftCurY;
float shiftNextX;
float shiftNextY;
int handInd = 0;
int strokeA = 255;
float ampLevel=1;
color[] strokeHex = new color[3];
color strokeColor = #ADFFC9;

float movement = 0.5;
float maxDist = 30.0;

int startRecord = 0;
int interval = 1500;
int duration = 12000;

boolean start = true;
int songStart;
int intStart;

int numSounds=9;
int soundInd = 1;
SoundFile song;
SoundFile[] files = new SoundFile[numSounds];

void setup(){
  //size(1920, 1080, P2D);
  fullScreen(P2D);
  background(0);
  noCursor();
  
  RG.init(this);
  
  for (int i=0;i<numHands;i++){
    hands[i] = RG.loadShape("hands_"+(i+1)+".svg");
  }
  
  RG.setPolygonizer(RG.ADAPTATIVE);
  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(0);
  
  cur = hands[handInd].getPoints();
  target = hands[handInd+1].getPoints();
  
  first = hands[int(random(0,hands.length))];
  first = RG.centerIn(first, g, 100);
  first.scale(0.72);
  
  strokeHex[0] = #C2FFD6;
  strokeHex[1] = #D6FFE4;
  strokeHex[2] = #EBFFF2;
  
  for (int i = 0; i < files.length; i++) {
    files[i] = new SoundFile(this, "noise" + (i+1) + ".mp3");
  }
  song = new SoundFile(this, "song.mp3");
  song.play();
  songStart = millis();
  
  
}

void draw(){
  /*
  if (start){
    blendMode(SUBTRACT);
    fill(5.5);
    rect(0, 0, width, height);
    translate(width/2, height/2);
    blendMode(NORMAL);
    first.setFillAlpha(1);
    first.setStroke(#F2DCDC);
    first.skewX(0.0001);
    if (millis() <58999+songStart){
      float splitPos = map(millis(), 7565+songStart, 59000+songStart, 0, 1);
      
      RShape[] splitShapes = RG.split(first, splitPos);
     
      RG.shape(splitShapes[0]);
    }
    else {
      if (millis() > 59875+songStart) {
        start = false;
        files[soundInd].play();
        startRecord = millis();
        intStart= millis();
      }
      RG.shape(first);
    }
  }
  else {
    */
    blendMode(SUBTRACT);
    fill(5.5);
    rect(0, 0, width, height);
    blendMode(NORMAL);
    displayCur();
    moveShape();
    checkTime();
  //}
  //saveFrame("recording-#########.png");
}

float calcAngle(RPoint[] cur, RPoint[] target, int index){
  float diffx = target[index].x - cur[index].x;
  float diffy = target[index].y - cur[index].y;
  float angle = atan2(diffy, diffx);
  return angle;
}

void movePoint(RPoint[] cur, RPoint[] target, int index){
  float angle = calcAngle(cur, target, index);
  if (cur[index].dist(target[index])>1){
    angle += random(-0.8, 0.8);
    cur[index].translate(cos(angle)*movement, sin(angle)*movement);
  }
  else {
    cur[index].translate(random(-.5,.5), random(-.5,.5));
  }
}

void moveShape(){
  for(int i=0; i<numPoints;i++){
    movePoint(cur,target,i);
  }
}

void displayCur(){
  strokeWeight(.5);
  noFill();
  beginShape();
  scale(1.75);
  stroke(strokeColor,strokeA);
  for (int i=0; i<numPoints; i++){
    curveVertex(cur[i].x, cur[i].y);
    if (dist(cur[i+1].x, cur[i+1].y, cur[i].x, cur[i].y)>maxDist && i<numPoints-1){
      endShape();
      beginShape();
    }
  }
  endShape();
}

void checkTime(){
  if (millis()>316961+songStart){
    strokeA-=0.05;
    if (duration <5000){
      duration = 5000;
      movement = 0.75;
      transitionNextHand();
      transitionNextSound();
      strokeColor = #F2DCDC;
    }
    else if((millis()-startRecord)> duration){
      startRecord = millis();
      transitionNextHand();
      transitionNextSound();
      ampLevel -=0.34;
      song.amp(ampLevel);
      if (ampLevel<0){
        song.stop();
      }
    }
  }
  else if((millis()-startRecord)> duration){
    startRecord = millis();
    int newInterval = round(map(millis(),intStart,317000+songStart,1500,1249));
    int multiplier = round(map(millis(),intStart, 317000+songStart, 9,2)/2);
    duration = multiplier*2*newInterval;
    movement = map(millis(),intStart, 317000+songStart, 0.3,2.5);
    //println(newInterval+" - "+duration+" - "+millis());
    transitionNextHand();
    transitionNextSound();
    if (multiplier !=4){
      strokeColor = strokeHex[multiplier-1];
    }
  }
}

void transitionNextSound(){
  files[soundInd].stop();
  soundInd = int(random(1,numSounds+1))-1;
  float jumpInd = random(0, files[soundInd].duration()-10); //returns in seconds
  files[soundInd].jump(jumpInd);
  //println(soundInd+" : "+jumpInd+" : " + files[soundInd].duration());
  //println();
}

void transitionNextHand(){
  handInd = int(random(1,numHands+1))-1;
  target = hands[handInd].getPoints();
  println(handInd+" : "+target.length);
}
