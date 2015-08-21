//  Adam M. Pere - Dec 18th 2013
//  Involution Studios
//
//  This program successfully detects human bodies (standing) in a room and draws a box around each body and the
//  (x,y) pixel coordinates of the bounding box.
//
//Things to do:
//
//  - Be able to track individual people (i.e. knowing that this bounding box is the 'same' bounding box as one in the last frame)

import java.awt.*;
import gab.opencv.*;
import processing.video.*;

import org.opencv.core.Mat;
import org.opencv.core.Core;
import org.opencv.core.Rect;
import org.opencv.core.Size;
import org.opencv.core.CvType;
import org.opencv.core.MatOfRect;
import org.opencv.core.MatOfDouble;
import org.opencv.imgproc.Imgproc;
import org.opencv.objdetect.HOGDescriptor;
import org.opencv.objdetect.CascadeClassifier;

import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;
import java.awt.image.Raster;


//Instance Variables
Capture video;
OpenCV opencv;

HOGDescriptor hog;

Mat m1;
MatOfRect rect;
MatOfDouble weights;

int pixCnt;
PImage img;
BufferedImage bm;

void setup() {
  size(1024, 576);
  

  video = new Capture(this, width, height);
  
//  Prints a list of all webcams and their appropriate resolutions 
//
//  String[] cameras = video.list();
//  for (int i = 0; i < cameras.length; i++) {
//      println(cameras[i]);
//    }


  opencv = new OpenCV(this, width, height); 
  hog = new HOGDescriptor();
  rect = new MatOfRect();
  weights = new MatOfDouble();
  
  bm = new BufferedImage(width, height, BufferedImage.TYPE_4BYTE_ABGR);
  img = createImage(width, height, ARGB);
  pixCnt = width*height*4;
  
  //Set the svmDetector for humans using the pre-trained database
  hog.setSVMDetector(hog.getDefaultPeopleDetector());
  
  
  video.start();
}

void convert(PImage _i) {
//Converts the image of type PImage to openCV's type matIMage  
  bm.setRGB(0, 0, _i.width, _i.height, _i.pixels, 0, _i.width);
  Raster rr = bm.getRaster();
  byte [] b1 = new byte[pixCnt];
  rr.getDataElements(0, 0, _i.width, _i.height, b1);
  Mat m1 = new Mat(_i.height, _i.width, CvType.CV_8UC4);
  m1.put(0, 0, b1);
 
  Mat m2 = new Mat(_i.height, _i.width, CvType.CV_8UC1);
  Imgproc.cvtColor(m1, m2, Imgproc.COLOR_BGRA2GRAY);   
 
//Detects and makes rectangles for every human in the viewing area. The data is placed in the passed in matRect object
  hog.detectMultiScale(m2, rect, weights,(double)0.0, new Size(8,8), new Size(0,0), (double)1.05, (double)2, false); //play around with parameters

//Description of parameters
// m2 = the image in type Mat
// rect = an array of rectangles where a pedestrian was found
// weights = ?? not totally sure, it isn't in the documentation
// (double)0.0 = hit threshold = The Threshold for the distance between features and SVM classifying plane. This is usually 0 and should be specified in the detector coefficients (as the last free coefficient)... if that s omitted you can manually specify here.
// new Size(8,8) = window stride. It must be a multiple of block stride.
// new Size(0,0) = padding. This is just an artifact... should be 0's
// (double) 1.05 = scale = Coefficient of the detection window increase
// (double)2 = final threshold/group threshold = coefficient to regulate the similarity threshold. 
// use mean shift grouping =  ?? I'm not yet sure
 
  bm.flush();
  m2.release();
  m1.release();
}


void draw() {

  opencv.loadImage(video);
  set(0,0,video);
  //image(video, 0, 0, width, height);
  
  convert(video);

  noFill();
  stroke(0, 255, 0);
  strokeWeight(2);
  
  //draw all the rectangles around pedestrians
  for (Rect rec: rect.toArray()){
    rect(rec.x, rec.y, rec.width, rec.height);
    text("(" + rec.x + "," + rec.y + ")", rec.x, rec.y);
  }
  
 
}

void captureEvent(Capture c) {
  c.read();
}

