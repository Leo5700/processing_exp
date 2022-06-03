// Аттрактор Polynomial A из Chaoscope
// http://chaoscope.org/doc/attractors.htm#polynomial_a
// уравнения генерируют точки, на точках строятся линии
// цвет выбирается в зависимости от квазискорости приращения 
// координат точек, по клику рандомятся параметры уравнений
// по клавише "r" рандомится colormap,
// по клавише "i" colormap сбрасывается к исходному.

// * отмечены параметры которые прикольно покрутить


int iterations = 3000; // число точек
int f_rate = 14; // максимальный fps
float ac = 1000; // * геометрические размеры всего этого дела


float x, y, z; // точки
float tx, ty, tz; // текущие точки
float p0, p1, p2; // параметры в системе уравнений аттрактора

float min_p0 = 0.0; // границы рандома параметров
float min_p1 = 0.0;
float min_p2 = 0.0;
float max_p0 = 2.0;
float max_p1 = 2.0;
float max_p2 = 2.0;

float[] pointsX = new float[iterations]; // вектора для хранения точек
float[] pointsY = new float[iterations];
float[] pointsZ = new float[iterations];
float[] pointsV = new float[iterations]; // квазискорость (на неё мапится цвет)

boolean bad_seed = false; // триггер нехороших сочетаний параметров

Colormap c = new Colormap(); // это объект-colormap

void setup() {
  noCursor();
  background(0);
  fullScreen(P3D);
  //size(600, 600, P3D);
  frameRate(f_rate);
  c.init(); // инициализация colormap
  c.calculate();
}

void draw() {

  if (mousePressed || bad_seed) { // если решения так себе или клик мыши, 
    p0 = random(min_p0, max_p0); // рандомятся параметры
    p1 = random(min_p1, max_p1);
    p2 = random(min_p2, max_p2);
    bad_seed = false;
  }

  if (keyPressed) { 
    if (key == 'r') { // рандом colormap
      c.randomize();
      c.calculate();
    }
    if (key == 'i') { // сброс colormap к нач. настройкам
      c.c1 = 0.05;
      c.c2 = 0.04;
      c.c3 = 0.03;
      c.s1 = 0;
      c.s2 = 0;
      c.s3 = 0;
      c.calculate();
    }
  }

  // расчёт

  x = 0; 
  y = 0; 
  z = 0;

  float sh = frameCount/100.; // * скорость изменения параметров по шуму Перлина
  float lim1 = 5e-3; // изменчивость (1e-10..5e-1)
  float sh0 = map(noise(sh), 0, 1, -lim1, lim1);
  float sh1 = map(noise(sh+100), 0, 1, -lim1, lim1); // +100 и +200 это отступ вправо по шуму перлина, чтоб шум был независимым для каждого параметра
  float sh2 = map(noise(sh+200), 0, 1, -lim1, lim1);

  p0 += sh0;
  p1 += sh1;
  p2 += sh2;

  // c.display(); // отрисовка colormap, если интересно

  translate(width/2, height/2);
  rotateY(frameCount/50.); // * скорость вращения всей фигуры

  for ( int i = 0; i < iterations; i++ ) {

    // формулы аттрактора polynomial type A
    tx = p0 + y - z * y;
    ty = p1 + z - x * z;
    tz = p2 + x - y * x;
    x = tx;
    y = ty;
    z = tz;

    float lim = 1e37; // всякие бесконечности выкидываем
    if (abs(x) > lim || abs(y) > lim || abs(z) > lim) {
      bad_seed = true;
      break;
    }

    pointsX[i] = x;
    pointsY[i] = y;
    pointsZ[i] = z;

    float v = sqrt(tx*tx + ty*ty + tz*tz); // квазискорость
    pointsV[i] = v;
  }

  // проверка на неразнообразие точек
  float limUnicPoints = iterations * 0.1; // порог уникальности
  if (numUnique(pointsX) < limUnicPoints) {
    bad_seed = true;
  }


  // отрисовка

  float min_x = min(pointsX);
  float max_x = max(pointsX);
  float min_y = min(pointsY);
  float max_y = max(pointsY);
  float min_z = min(pointsZ);
  float max_z = max(pointsZ);
  float min_v = min(pointsV);
  float max_v = max(pointsV);

  for (int i = 0; i < iterations; i++) {
    float xp = map(pointsX[i], min_x, max_x, -ac/2, ac/2); // подгонка под размер
    float yp = map(pointsY[i], min_y, max_y, -ac/2, ac/2);
    float zp = map(pointsZ[i], min_z, max_z, -ac/2, ac/2);

    float vp = map(pointsV[i], min_v, max_v, 0, 1);
    int icm = (int) map(vp, 0, 1, 0, c.gradations-1); // мапинг квазискорости на colormap
    float transp = 220;
    stroke(c.cmr[icm], c.cmg[icm], c.cmb[icm], transp);

    strokeWeight(8); // * размер точек
    point(xp, yp, zp); // * отрисовка точек

    if (i != 0) {
      float xp_prev = map(pointsX[i-1], min_x, max_x, -ac/2, ac/2);
      float yp_prev = map(pointsY[i-1], min_y, max_y, -ac/2, ac/2);
      float zp_prev = map(pointsZ[i-1], min_z, max_z, -ac/2, ac/2);
      strokeWeight(1.2); // * толщина линий
      line(xp, yp, zp, xp_prev, yp_prev, zp_prev); // * отрисовка линий
    }
  }
}
