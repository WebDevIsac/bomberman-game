import processing.serial.*;

Tile[][] mapa;
float l;
boolean[] p1c, p2c;
ArrayList<P1Bomb> p1bombs;
ArrayList<P2Bomb> p2bombs;
Serial myPort;
String arduinoString;
String valString;
int val;
int player1score = 0;
int player2score = 0;
int p1bomb = 0;
int p2bomb = 0;

Index p1, p2;
void setup() {
  //String portName = Serial.list()[0];
  //myPort = new Serial(this, portName, 115200);
  
  size(800, 600); 
  frameRate(30);
  mapa = new Tile[20][20];
  l = width / float(mapa.length);
  
  p1 = new Index( 1, 1 );
  p2 = new Index( 13, 11 );
  p1c = new boolean[5];
  p2c = new boolean[5];
  
  p1bombs = new ArrayList();
  p2bombs = new ArrayList();
  
  makeMapa();
  
}

void makeMapa() {
  PImage file = loadImage("mapa.png");
  for (int x=0; x<mapa.length ; x++){
   for (int y=0; y<mapa[0].length ; y++){
     int t = 0;
     color c = file.get(x,y);
     if( c == color(0) ) t = 2;
     else if( c == color(127) ) t = 1;
     //else if( c == color(195) ) 
     else if( c == color( 255 ) ){
       if( abs((9-dist( x, y, 7, 6 )) * randomGaussian()) > 1.2 ) t = 1;
     }
     
     mapa[x][y] = new Tile(t);
   }
  }
}

void draw() {
   
  // if (myPort.available() > 0) { 
  //    valString = myPort.readString();
  //    moveChar(valString);
  //    println(valString);
  // }
  
  for (int x=0; x<mapa.length ; x++){
    for (int y=0; y<mapa[0].length ; y++){
      pushMatrix();
      translate(x*l,y*l);
      mapa[x][y].plot();
      popMatrix();
    }
  }
  
  //P1
  if( p1.i >= 0 ){
    if (p1c[0]) {
      if (mapa[p1.i][p1.j-1].atravessavel()) p1.j--; 
    }
    if (p1c[1]) {
      if (mapa[p1.i][p1.j+1].atravessavel()) p1.j++; 
    }
    if (p1c[2]) {
      if (mapa[p1.i-1][p1.j].atravessavel()) p1.i--; 
    }
    if (p1c[3]) {
      if (mapa[p1.i+1][p1.j].atravessavel()) p1.i++; 
    }
    if( p1c[4] && p1bomb == 0 ) {
      p1bombs.add( new P1Bomb( p1 ) );
      p1bomb = 1;
      print(p1bombs);
    }
  }
    
  
  //P2
  if( p2.i >= 0 ){
    if (p2c[0]) {
      if (mapa[p2.i][p2.j-1].atravessavel()) p2.j--; 
    }
    if (p2c[1]) {
      if (mapa[p2.i][p2.j+1].atravessavel()) p2.j++; 
    }
    if (p2c[2]) {
      if (mapa[p2.i-1][p2.j].atravessavel()) p2.i--; 
    }
    if (p2c[3]) {
      if (mapa[p2.i+1][p2.j].atravessavel()) p2.i++; 
    }
    if( p2c[4] && p2bomb == 0){
      p2bombs.add( new P2Bomb( p2 ) );
      p2bomb = 1;
      print(p2bombs);
    }
  }
  
  fill( 0, 0, 255);
  ellipse( (p1.i + 0.5) * l, (p1.j + 0.5) * l, l, l);
  fill(255, 0, 0);
  ellipse( (p2.i + 0.5) * l, (p2.j + 0.5) * l, l, l);
  
  for(int i = p1bombs.size()-1; i >= 0; --i ){
    p1bombs.get(i).plot();
    if( p1bombs.get(i).explodiu() ){
      
      if( p1.i == p1bombs.get(i).pos.i &&
          abs( p1.j - p1bombs.get(i).pos.j ) <= 2 ){
            p1 = new Index( -1, -1 );
            ++player2score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p1 = new Index( 1, 1 );
            makeMapa();
      }
      else if( p1.j == p1bombs.get(i).pos.j &&
          abs( p1.i - p1bombs.get(i).pos.i ) <= 2 ){
            p1 = new Index( -1, -1 );
            ++player2score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p1 = new Index( 1, 1 );
            makeMapa();
      }
      if( p2.i == p1bombs.get(i).pos.i &&
          abs( p2.j - p1bombs.get(i).pos.j ) <= 2 ){
            p2 = new Index( -1, -1 );
            ++player1score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p2 = new Index( 13, 11 );
            makeMapa();
      }
      else if( p2.j == p1bombs.get(i).pos.j &&
          abs( p2.i - p1bombs.get(i).pos.i ) <= 2 ){
            p2 = new Index( -1, -1 );
            ++player1score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p2 = new Index( 13, 11 );
            makeMapa();
      }
      
      for(int x=-2; x <= 2; x++){
        if( x == 0 ) continue;
        int I = p1bombs.get(i).pos.i + x;
        if( I < 0 || I > mapa.length-1 ) continue;
        if( mapa[I][p1bombs.get(i).pos.j].tipo == 1 ){
          mapa[I][p1bombs.get(i).pos.j].tipo = 0;
        }
      }
      for(int y=-2; y <= 2; y++){
        if( y == 0 ) continue;
        int J = p1bombs.get(i).pos.j + y;
        if( J < 0 || J > mapa[0].length-1 ) continue;
        if( mapa[p1bombs.get(i).pos.i][J].tipo == 1 ){
          mapa[p1bombs.get(i).pos.i][J].tipo = 0;
        }
      }
      if(p1bomb == 1){
        p1bombs.remove(i);
        p1bomb = 0;
      } 
      if(p2bomb == 1){
        p2bombs.remove(i);
        p2bomb = 0;
      }

    }
  }

  for(int i = p2bombs.size()-1; i >= 0; --i ){
    p2bombs.get(i).plot();
    if( p2bombs.get(i).explodiu() ){
      
      if( p1.i == p2bombs.get(i).pos.i &&
          abs( p1.j - p2bombs.get(i).pos.j ) <= 2 ){
            p1 = new Index( -1, -1 );
            ++player2score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p1 = new Index( 1, 1 );
            makeMapa();
      }
      else if( p1.j == p2bombs.get(i).pos.j &&
          abs( p1.i - p2bombs.get(i).pos.i ) <= 2 ){
            p1 = new Index( -1, -1 );
            ++player2score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p1 = new Index( 1, 1 );
            makeMapa();
      }
      if( p2.i == p2bombs.get(i).pos.i &&
          abs( p2.j - p2bombs.get(i).pos.j ) <= 2 ){
            p2 = new Index( -1, -1 );
            ++player1score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p2 = new Index( 13, 11 );
            makeMapa();
      }
      else if( p2.j == p2bombs.get(i).pos.j &&
          abs( p2.i - p2bombs.get(i).pos.i ) <= 2 ){
            p2 = new Index( -1, -1 );
            ++player1score;
            println("p1:" + player1score + "-" + "p2:" + player2score);
            p2 = new Index( 13, 11 );
            makeMapa();
      }
      
      for(int x=-2; x <= 2; x++){
        if( x == 0 ) continue;
        int I = p2bombs.get(i).pos.i + x;
        if( I < 0 || I > mapa.length-1 ) continue;
        if( mapa[I][p2bombs.get(i).pos.j].tipo == 1 ){
          mapa[I][p2bombs.get(i).pos.j].tipo = 0;
        }
      }
      for(int y=-2; y <= 2; y++){
        if( y == 0 ) continue;
        int J = p2bombs.get(i).pos.j + y;
        if( J < 0 || J > mapa[0].length-1 ) continue;
        if( mapa[p2bombs.get(i).pos.i][J].tipo == 1 ){
          mapa[p2bombs.get(i).pos.i][J].tipo = 0;
        }
      }
      if(p1bomb == 1){
        p1bombs.remove(i);
        p1bomb = 0;
      } 
      if(p2bomb == 1){
        p2bombs.remove(i);
        p2bomb = 0;
      }

    }
  }
  
  p1c[0] = false;
  p1c[1] = false;
  p1c[2] = false;
  p1c[3] = false;
  p1c[4] = false;
  
  text("Score: Player one: " + player1score + " Score: Player two: " + player2score, 180,30);
  
}