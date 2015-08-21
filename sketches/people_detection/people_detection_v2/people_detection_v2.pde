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
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.CvType;
import org.opencv.core.MatOfRect;
import org.opencv.core.MatOfDouble;
import org.opencv.core.MatOfInt;
import org.opencv.imgproc.Imgproc;
import org.opencv.objdetect.HOGDescriptor;
import org.opencv.objdetect.CascadeClassifier;
import org.opencv.objdetect.Objdetect;

import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;
import java.awt.image.Raster;


//Instance Variables
Capture video;
OpenCV opencv;

HOGDescriptor hog;

MatOfRect rect;
MatOfDouble weights;

ArrayList<Rect> people;
ArrayList<Rect> falseRects;
ArrayList<Point> falsePoints;

int pixCnt;
PImage img;
BufferedImage bm;


void setup() {
  size(1024,576);
  

  video = new Capture(this, width, height,   30);
  
//  //Prints a list of all webcams and their appropriate resolutions 
//
//  String[] cameras = video.list();
//  for (int i = 0; i < cameras.length; i++) {
//      println(cameras[i]);
//    }

  opencv = new OpenCV(this, width, height); 
  hog = new HOGDescriptor();
  rect = new MatOfRect();
  people = new ArrayList<Rect>();
  falseRects = new ArrayList<Rect>();
  falsePoints = new ArrayList<Point>();
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

 
  bm.flush();
  m2.release();
  m1.release();
}

//Updates the list of 'people' which contains rectangles that encompass a unique individual. This Keeps the rectangle on screen and does not show multiple rectangles per person.
void overlapping(){
  
  int midx = 0;
  int midy = 0;
  boolean found = false;
  Point midP;
  
  for(Rect r: falseRects){
       if(people.contains(r)){
         people.remove(r); 
        }
     }
     
  for (Rect rec: rect.toArray()){
    //rect(rec.x, rec.y, rec.width, rec.height);
    //text("(" + rec.x + "," + rec.y + ")", rec.x, rec.y);
    midx = rec.x + (rec.width/2);
    midy = rec.y + (rec.height/2);
    midP = new Point(midx,midy);
    
//As is, this false points doesn't work   
//     for(Rect r: people){
//      for(Point pi: falsePoints){
//         if(r.contains(pi)){
//          falseRects.add(r); 
//         }
//      } 
//     }
     
   
    for(Rect r: people){
      
      if(!found){
        if(r.contains(midP) && rec.x < r.x + r.width && rec.x + rec.width > r.x && r.y < rec.y + rec.height && r.y + r.height > rec.y){  //r.contains(midP) -- Overlapping
         found = true;
         r.x = rec.x;
         r.y = rec.y;
         r.width = rec.width;
         r.height = rec.height; 
        }
      }
    }
    
    if(!found){
    people.add(rec);}
    
  }
  found = false;
  
}

//Draws all rectangles for the people in the list of people
void drawRects(){
  
    int c = 0;
    for (Rect rec: people){
      rect(rec.x, rec.y, rec.width, rec.height);
      fill(0,255,50);
      text(c + ": (" + rec.x + "," + rec.y + ")", rec.x, rec.y);
      noFill();
      c++;
  }
}


void draw() {

  opencv.loadImage(video);
  set(0,0,video);
  //image(video, 0, 0, width, height);
  
  convert(video);

  noFill();
  stroke(150, 255, 0);
  strokeWeight(2);
  
  overlapping();
  drawRects();
  text(people.size() + " Person(s) Detected", 50,50);
  
//Save frame to image  
//  if(people.total() > 1){
//   saveFrame("shot-####.png"); 
//  }
  
}

void captureEvent(Capture c) {
  c.read();
}

void mouseClicked(){
  Point p = new Point ((int)mouseX, (int)mouseY);
  
  if(mouseButton == LEFT){
    println("mouse clicked! Removing (" + p.x + "," + p.y + ")");
    for(Rect rec: people){
     if(rec.contains(p)){
        falseRects.add(rec);
     } 
    }
    
    println("List of False Positives");
    for(Rect r: falseRects){
     println(r); 
    }
  }
  else if(mouseButton == RIGHT){
    
    
  }
}

