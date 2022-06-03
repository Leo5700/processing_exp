// Colormap в виде объекта


class Colormap {

  int gradations = 180; // число оттенков
  float[] cmr;
  float[] cmg;
  float[] cmb;

  float c1 = 0.05;
  float c2 = 0.04;
  float c3 = 0.03;
  float s1 = 0;
  float s2 = 0;
  float s3 = 0;

  void init() {
    cmr = new float[gradations];
    cmg = new float[gradations];
    cmb = new float[gradations];
  }

  void randomize() {
    c1 = random(0.01, 0.03);
    c2 = random(0.02, 0.04);
    c3 = random(0.03, 0.05);
    s1 = random(0, 100);
    s2 = random(0, 100);
    s3 = random(0, 100);
  }
  
  void calculate(){
    for ( int i = 0; i < gradations; i++ ) {
      // colormap генерируется как сочетание трёх смещённых синусоид,
      // каждая для своего цвета
      float cr = sin(i*c1+s1);
      float cg = sin(i*c2+s2);
      float cb = sin(i*c3+s3); 
      cmr[i] = map(cr, -1, 1, 0, 255);
      cmg[i] = map(cg, -1, 1, 0, 255);
      cmb[i] = map(cb, -1, 1, 0, 255);
    }
  }

  void display() { 
    // функция для отрисовки colormap короткими вертикальными линиями
    // TODO отработать на большом и малом числе оттенков 
    int cmlen = 200; //
    for ( int i = 0; i < cmlen; i++ ) {
      // мапим colormap на число линий отрисовки
      int icm = (int) map(i, 0, cmlen, 0, gradations-1);
      pushStyle();
      stroke(cmr[icm], cmg[icm], cmb[icm]);
      strokeWeight(1);
      line(i, 0, i, 42); //
      popStyle();
    }
  }
}
