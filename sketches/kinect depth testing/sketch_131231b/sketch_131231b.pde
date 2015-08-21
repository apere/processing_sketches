

//Adam Pere 
// Simple program to test the kinects depth tracking
//****Not sure if working****

import org.openkinect.*;
import org.openkinect.processing.*;

Kinect kinect;
KinectTracker tracker;

void setup(){
  size(640,480);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
 
}

void draw(){
  background(255);

  tracker.track();
  tracker.display();
 
  PVector v1 = tracker.getPos();
  fill(50,100,250,200);
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);
  
  PVector v2 = tracker.getLerpedPos();
  fill(100,250,50,200); 
  noStroke(); 
  ellipse(v2.x,v2.y,20,20);  
}

void stop(){
  tracker.quit();
  super.stop(); 
  
}
