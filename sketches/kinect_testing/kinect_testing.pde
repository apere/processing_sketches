//Adam Pere 
// Simple program to test the kinect and display the input
//****Not sure if working****

import librarytests.*;
import org.openkinect.*;
import org.openkinect.processing.*;

Kinect kinect;

void setup(){
  size(640,480);
  kinect = new Kinect(this);
  kinect.start();
  
  kinect.enableDepth(true);
  
  //kinect.processDepthImage(false); //If you want raw depth data
  
  //kinect.enableRGB(true); //If you want to get image from rgb webcam
  
  //kinect.enableIR(true) //If you want the image from the IR webcam
  
}

void draw(){
  
 PImage img = kinect.getDepthImage();
 image(img,0,0);
 
 int[] depth = kinect.getRawDepth();
 
 //If you want to get image from the current webcam
   //PImage img = kinect.getVideoImage();
   //image(img,0,0);
  
  
}
