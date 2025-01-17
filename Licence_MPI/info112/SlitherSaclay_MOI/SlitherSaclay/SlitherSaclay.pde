// Questions :
/*

 Q1 : dessiner joli segment rond pour serpent (check)
 Q2 : dessiner visage serpent (yeux, langue, etc.) (check)
 Q3 : materialiser bordure de scroll (carre) (check)
 Q4 : dessiner joli "noisette" ou "gland" pour nourriture (check)
 Q5 : dessiner un terrain selon perlin (check)
 --------------------------------------
 Note de projet No1 pour le 4 ou 5 decembre
 
 Q6 : dessiner serpent "lumineux" quand "acceleration" avec la touche espace (check) 
 Q7 : animation a la mort (mieux que le game-over qui rapetisse) (check)
 Q8 : animation au repas (check)
 Q9 : dessiner l'ombre d'un quadricoptere au centre du plateau de jeu (check)
 Q10 : tableau des vainqueurs (check)
 --------------------------------------
 Note de projet No2 pour la soutenance finale debut janvier
 */

// variables globales
PImage img1, img2;
boolean merge = false;
Snake snakes[];
int TerrX     = 40;
int TerrY     = 40;

int gaussR = 11;
float gauss[][];
int panX = 0;
int panY = 0;

int state = 1;

int BORDER_SIZE = 200;
String names[]={"Fred", "Nicolas", "Yacine", "Olivia", "Medhi", "Christian", "Laura"};

ArrayList foods; 

// on regroupe les variables d'un serpent dans une structure
class Snake {
  ArrayList pos;
  int size = 16;
  int weight = 160;
  float dirX = 10;
  float dirY = 0;
  float speed = 10;
  float r, g, b;
  String name;
  Snake(String name0, int size0, int x0, int y0, int r0, int g0, int b0, float dirX0, float dirY0) {
    r=r0;
    g=g0; 
    b=b0;

    name = name0;
    dirX = dirX0;
    dirY = dirY0;

    size = size0;
    pos = new ArrayList();
    for (int i = size; i>=0; i--) {
      Point s = new Point(x0+i*dirX, y0+i*dirY);
      pos.add(s);
    }
    setWeight(size*10);
  }

  void setWeight(int weight1) {
    weight = weight1;
    for (int i = size; i>=0; i--) {
      Point s = (Point)pos.get(i);
      s.r = 10+sqrt((weight-39))/4.0;
      if (i==1) s.r-=2;
      if (i==2) s.r--;
    }

    int acc = 8;
    for (int i = pos.size()-1; i>=3; i--) {
      Point s  = (Point)pos.get(i);
      if (acc<s.r)
        s.r = acc;
      acc+=1;
    }
  }
}


// une autre structure pour representer les segments de serpent ou les boules de nourriture 
class Point {
  float x; 
  float y;
  float r;
  Point (float x0, float y0) {
    x = x0;
    y = y0;
    r = 10;
  }
}


Point newFood() {
  float a = random(0, 10000)*PI/5000;
  float d = random(0, 5000);

  Point p = new Point(d*cos(a), d*sin(a));
  p.r = random(1, 5);
  return p;
}

void setup() {  // this is run once.       
  size(1024, 768); 
  snakes = new Snake[6]; 
  for (int k=1; k<snakes.length; k++) {
    snakes[k] = new Snake(names[k], 4+10*(k-1), width/2+(int)(300*cos(k*PI/3)), height/2+(int)(300*sin(k*PI/3)), 128+64*(k%3), 255*(k%2), 0, 10*cos((k+2)*PI/3), 10*sin((k+2)*PI/3));
  }

  foods = new ArrayList();
  for (int k=0; k<1000; k++) {
    foods.add(newFood());
  }

  gauss = new float[gaussR][gaussR];
  for (int k=0; k<gaussR; k++)
    for (int l=0; l<gaussR; l++)
      gauss[k][l] = exp(-1.0/gaussR/gaussR*((k-gaussR/2)*(k-gaussR/2)+(l-gaussR/2)*(l-gaussR/2)));

  // 2 images
  img1 = createImage(64, 64, ARGB);
  img2 = createImage(64+gaussR, 64+gaussR, ARGB);

  // Q1 un dessin de cercle dans la premiere image
  for (int j=0; j < img1.height; j++) {
    for (int i=0; i < img1.width; i++) {
      float d0 = dist(i, j, img1.width/2, img1.height/2);
      if (d0<img1.width/2-1) {
        img1.pixels[i+j*img1.width] = color(255-d0*5.5);
      }
    }
  }

  // l'ombre du cercle dans la 2ieme image
  for (int j=0; j < img1.height; j++) {
    for (int i=0; i < img1.width; i++) {
      float c = alpha(img1.pixels[i+j*img1.width]);
      for (int k=0; k<gaussR; k++) {
        for (int l=0; l<gaussR; l++) {
          img2.pixels[i+l+(j+k)*img2.width] += c*gauss[k][l];
        }
      }
    }
  }
  int ma = img2.pixels[img2.width/2+img2.height/2*img2.width];
  for (int j=0; j < img2.height; j++) {
    for (int i=0; i < img2.width; i++) {
      int value= img2.pixels[i+j*img2.width];
      img2.pixels[i+j*img2.width] = color(0, 128*value/ma);
    }
  }

  img1.updatePixels();    
  img2.updatePixels();

  frameRate(25);
} 


void moveSnake(Snake s, float objx, float objy) {
  Point p0 = (Point) s.pos.get(0);
  Point pn = (Point) s.pos.get(s.pos.size()-1);

  float dd = dist(p0.x, p0.y, objx, objy);
  float tx = objx;
  float ty = objy;
  if (dd>s.speed) {
    tx = p0.x+(objx-p0.x)/dd*s.speed;
    ty = p0.y+(objy-p0.y)/dd*s.speed;
  }
  if (dd>0) {
    s.dirX = (objx-p0.x)/dd*s.speed;
    s.dirY = (objy-p0.y)/dd*s.speed;
  }

  // si on va "vite" on seme de la nourriture derriere soi et on perd du poids
  if (s.speed>10) {
    s.setWeight(s.weight -2);
    Point f = new Point(pn.x, pn.y);
    f.r = 1;
    foods.add(f);

    if (s.weight<10*s.size) {
      s.size--;
      s.pos.remove(s.pos.size()-1);
    }
    if (s.weight<42) {
      s.speed=10;
    }
  }

  // deplace chaque segment du serpent
  float tlen = 0;
  for (int i = 0; i<s.pos.size(); i++) {
    Point p = (Point) s.pos.get(i);
    float len = dist(p.x, p.y, tx, ty);
    if (len > tlen) {
      p.x = tx-(tx-p.x)*tlen/len;
      p.y = ty-(ty-p.y)*tlen/len;
    }
    tx = p.x;
    ty = p.y;
    tlen = 10;
  }
}

boolean testCollision(Snake s) {
  Point p0 = (Point)s.pos.get(0);
  Point pn = (Point)s.pos.get(s.pos.size()-1);

  for (int i=0; i<snakes.length; i++) {
    Snake other = snakes[i];
    if (other!=null && other!=s) {
      for (int k=0; k<other.pos.size(); k++) {
        Point p = (Point)other.pos.get(k);
        float dd = dist(p.x, p.y, p0.x, p0.y);
        if (dd<p0.r+p.r) {
          return true;
        }
      }
    }
  }

  for (int k=foods.size()-1; k>=0; k--) {
    Point f = (Point)foods.get(k);
    float dd = dist(p0.x, p0.y, f.x, f.y);
    if (dd < p0.r+f.r) { 
      s.setWeight(s.weight +(int)f.r);
      if (s.weight>10*s.size) { 
        s.size++;
        Point p = new Point(pn.x, pn.y);
        p.r= 8;
        s.pos.add(p);
      }

      foods.remove(k);
    }
  }
  return false;
}

void drawSnake(Snake s) {
  for (int i = s.pos.size()-1; i >= 0; i--) {
    Point p = (Point) s.pos.get(i);
    pushMatrix();
    translate( p.x-panX, p.y-panY);
    if (i==0) {
      rotate(atan2(s.dirY, s.dirX));
      stroke(0);
      strokeWeight(0.8);
      //Q2 dessin dessous
      fill(255, 0, 100);
      ellipse(7, 0, 40, 5);
      pushMatrix();
      scale(2.2*p.r/img1.width, 2.0*p.r/img1.width);
    } else 
    scale(2.0*p.r/img1.width);

    if (i%2==0) {
      if (s.speed>10) { //Q6
        tint(255, 229, 81, 200);
        image(img1, 0, 0);
        noTint();
      } else {
        //image(img2, 0,0);
        tint(s.r/2, s.g/2, s.b/2);
        image(img1, 0, 0);
        noTint();
      }
    } else {
      if (s.speed>10) {
        //image(img3, 0,0);
        tint(255, 216, 0, 200);
        image(img1, 0, 0);
        noTint();
      } else {
        //image(img2, 0,0);
        tint(s.r, s.g, s.b);
        image(img1, 0, 0);
        noTint();
      }
    }

    if (i==0) {
      //Q2 dessin dessus
      fill(50, 50, 0);
      ellipse(img1.width/6, -img1.height/6, 25, 25);
      ellipse(img1.width/6, img1.height/6, 25, 25);
      fill(255, 255, 0);
      ellipse(img1.width/6, -img1.height/6, 6, 6);
      ellipse(img1.width/6, img1.height/6, 6, 6);
      popMatrix();
      strokeWeight(1);
    }
    popMatrix();
  }


  Point p = (Point) s.pos.get(0);  
  fill(255);
  textSize(14);
  text(s.name+" "+(s.weight-30), p.x-panX, p.y-panY);
  fill(255);
  text(s.name+" "+(s.weight-30), p.x-panX-1, p.y-panY-1);
    fill(255); //Q10
    textSize(20);
        if(s.name=="Nicolas"){

     text(s.name+" "+(s.weight-30), width-50, 120);
     }
     if(s.name=="Fred"){
       text(s.name+" "+(s.weight-30), width-50, 220);
     }
     if(s.name=="Olivia"){
       text(s.name+" "+(s.weight-30), width-50, 320);
     }
     if(s.name=="Yacine"){
       text(s.name+" "+(s.weight-30), width-50, 420);
     }
     if(s.name=="Christian"){
       text(s.name+" "+(s.weight-30), width-50, 520);
     }
     if(s.name=="Medhi"){
       text(s.name+" "+(s.weight-30), width-50, 620);
     }
}

// Q5
void drawBg() {
  background(255, 192, 128);
  noStroke();
  for (int j=-panY%20-20; j<=height; j+=20) {
    for (int i=-panX%20-20; i<=width; i+=20) {
      float n = noise((i+panX)/15.0, (j+panY)/15.0);
      fill(0, n*255, n*255);
      rect(((((j+panY)/2)%4)*10+i),j, 60, 60);
    }
  }
}

boolean testCollisionFood(Snake s){

  Point p0 = (Point)s.pos.get(0);

   for (int k=foods.size()-1; k>=0; k--){
    Point f = (Point)foods.get(k);
    float dd = dist(p0.x, p0.y, f.x, f.y);
    if (dd < p0.r+f.r) {
      return true;
    }
   }
     return false; 
  
}

void draw() {  // this is run repeatedly. 
  drawBg();
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  if (state==1) {
    fill(0);
    textSize(20);
    text("Appuyer sur une touche pour commencer", width/2, height/2);
    return;
  } else if (state>1) {
    drawBg();
    fill(128, 0, 0);
    background(0);
    textSize(20+state*2);
    line(width/2, height/2, 5, 30);
    if(second()%2==0){
      PImage img4;
      img4 = loadImage("battery2.png");
      image(img4, width/2, height/2);
    }
  } else {
    moveSnake(snakes[0], mouseX+panX, mouseY+panY);
    // si la position du serpent s'approche du bord, on prefere scoller le jeu plutot que de laisser
    // le serpent s'approcher du bord
    Point p = (Point)snakes[0].pos.get(0);
    if (p.x-panX>width-BORDER_SIZE)
      panX = round(p.x-width+BORDER_SIZE);
    if (p.x-panX<BORDER_SIZE)
      panX = round(p.x-BORDER_SIZE);
    if (p.y-panY>height-BORDER_SIZE)
      panY = round(p.y-height+BORDER_SIZE);
    if (p.y-panY<BORDER_SIZE)
      panY = round(p.y-BORDER_SIZE);
  }
  //Q8
   if(snakes[0]!=null && testCollisionFood(snakes[0])==true) {
    Point p0d = (Point)snakes[0].pos.get(0);
    float x = p0d.x-panX + 40;
    float y = p0d.y-panY - 50;
    fill(0);
    text("Je grandis !", x, y);
    fill(255, 255, 0, 200);
    ellipse(x-40, y+50, 50, 50);
  }
  
  if (snakes[0]!=null && testCollision(snakes[0])) {
    for (int i=0; i<snakes[0].pos.size(); i++) {
      Point m = (Point)snakes[0].pos.get(i);
      m.r = 10;
      if (i%2==0) foods.add(m);
    }
    snakes[0] = null;
    state = 20;
  }

  // deplace les autres serpents de maniere aleatoire
  for (int k=1; k<snakes.length; k++)
    if (snakes[k]!=null) {
      float dx = snakes[k].dirX;
      float dy = snakes[k].dirY;
      float x = ((Point)snakes[k].pos.get(0)).x;
      float y = ((Point)snakes[k].pos.get(0)).y;
      float dd = dist(0, 0, x, y);

      float ndx = random(10.0, 15)*dx + random(-8, 8)*dy; 
      float ndy = random(10.0, 15)*dy - random(-8, 8)*dx; 
      if (dd>1000) {
        ndx += -x*(dd-1000)/dd;
        ndy += -y*(dd-1000)/dd;
      }

      moveSnake(snakes[k], x+ndx, y+ndy);
      if (testCollision(snakes[k])) {
        for (int i=0; i<snakes[k].pos.size(); i++) {
          Point m = (Point)snakes[k].pos.get(i);
          m.r = 10;
          if (i%2==0) foods.add(m);
        }
        snakes[k] = new Snake(names[k], 4, (int)random(1000), (int)random(1000), 128+64*(k%3), 255*(k%2), 0, 10*cos(k*PI/3), 10*sin(k*PI/3));
      }
    }



  for (int k=0; k<foods.size(); k++) {
    Point f = (Point)foods.get(k);
    pushMatrix();
    translate(f.x-panX, f.y-panY);
    scale(0.1+sqrt(f.r)/5.0);
    //Q4
    fill(0);
    ellipse(0, 0, 35, 20);
    fill(255);
    ellipse(-10, 0, -5, -5);
    fill(255);
    ellipse(-10, -10, 10, 10);
    fill(255);
    bezier(5, 5, 80, 20, 0, 0, 0, 0);
    popMatrix();
  }

  for (int k=0; k<snakes.length; k++) {
    if (snakes[k]!=null)
      drawSnake(snakes[k]);
  }

  noFill();
  stroke(0, 128);
  //Q3 

  strokeWeight(4);
  line(BORDER_SIZE, BORDER_SIZE, BORDER_SIZE+50, BORDER_SIZE);
  line(BORDER_SIZE, BORDER_SIZE, BORDER_SIZE, BORDER_SIZE+50);

  line(width-BORDER_SIZE, BORDER_SIZE, width-BORDER_SIZE-50, BORDER_SIZE);
  line(width-BORDER_SIZE, BORDER_SIZE, width-BORDER_SIZE, BORDER_SIZE+50);

  line(BORDER_SIZE, height-BORDER_SIZE, BORDER_SIZE, height-BORDER_SIZE-50);
  line(BORDER_SIZE, height-BORDER_SIZE, BORDER_SIZE+50, height-BORDER_SIZE);

  line(width-BORDER_SIZE, height-BORDER_SIZE, width-BORDER_SIZE, height-BORDER_SIZE-50);
  line(width-BORDER_SIZE, height-BORDER_SIZE, width-BORDER_SIZE-50, height-BORDER_SIZE);

  fill(255);
  textSize(25);
  text("REC", width-BORDER_SIZE-50, BORDER_SIZE+50);

  strokeWeight(0);
  if(second()%2 == 0){
  fill(255, 25, 25);
}
else{
  fill(255);
}
  ellipse(width-BORDER_SIZE-100, BORDER_SIZE+50, 20, 20);
  strokeWeight(3);
  fill(255);
  rect(BORDER_SIZE+25, BORDER_SIZE+25, 50, 25, 3);
    strokeWeight(1);
  rect(BORDER_SIZE+25, BORDER_SIZE+(50+6/2)/2, 50/4, 25, 4);
  rect(BORDER_SIZE+55, BORDER_SIZE+25, 50/4, 25/2);


  // Q9 quadricoptere
  pushMatrix();
  fill(0);
  ellipse(width/2,height/2, 120, 60);
  fill(25, 25, 25);
  rectMode(CENTER);
  translate(width/2, height/2);
  rotate(frameCount);
  rect(0, 0, 200, 10);
  rect(0, 0, 10, 200);
  popMatrix();
}

void keyPressed() {
  if (state>0) {
    snakes[0] = new Snake(names[0], 4, width/2, height/2, 0, 255, 0, 10, 0); 
    state = 0;
  } else if (key==' ' && snakes[0].weight>42)
    snakes[0].speed =20;
}
void keyReleased() {
  if (snakes[0]!=null && key==' ')
    snakes[0].speed =10;
}
