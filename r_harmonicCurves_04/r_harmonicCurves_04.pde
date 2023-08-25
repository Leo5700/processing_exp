

float base;
float sh, x, y, cx, cy, xv, yv;


void setup() {
  fullScreen();
  background(0);
  base = min(width, height) / 2;
  noCursor();
}


void draw() {
  //background(0);
  translate(width*.5, height*.5);

  noFill();
  stroke(255);
  strokeWeight(1); //
  sh = frameCount*.005;

  for (int j=0; j<7; j++) {
    float d = j*.5;
    beginShape();

    float xmin = 1e37;
    float xmax = -1e37;

    for (int i=0; i<100; i++) { //
      cx = d + sh+i*.02;
      cy = d + sh+100+i*.04;

      float dc = 0;

      x = dc+sin(cx)+cos(cx/8)*sin(cy);
      y = dc+sin(cy*.75)-cos(cy/6)*sin(cy+cx);

      if (x<xmin)
        xmin = x;
      if (x>xmax)
        xmax = x;

      xv = map(x, -2, 2, -base*.5, base*.5);
      yv = map(y, -2, 2, -base*.5, base*.5);

      float ypol = sin(y) * x;
      float xpol = cos(y) * x;

      float k = .57;
      float ypolp = map(ypol, -1, 1, -base*k, base*k);
      float xpolp = map(xpol, -1, 1, -base*k, base*k);

      stroke(map(cos(x-y), cos(xmin), cos(xmax), 0, 255));

      vertex(xpolp, ypolp);
    }
    endShape();
  }
}
