

/*

 Любая кнопка перезапускает генерацию.
 Кнопка мыши очищает экран.
 
 */


float k_main = 2; // масштаб всего и сразу, 
// для подгонки изображения к размеру экрана


ArrayList<PVector> a = new ArrayList<PVector>();
int n = 60000; // число точек

float seed_dist;
float scale;
float radius;


void init() {
  /*
  регенерация поля и точек со случайными параметрами
   */
  seed_dist = random(0.5, 1.5) * k_main;
  scale = random(0.08, 0.9) * k_main;
  radius = random(0.5, 1.5) * k_main;

  float dr = 450 * seed_dist; // размер исходного "квадрата" случайных точек
  a.clear();
  for (int i=0; i < n; i++) {
    PVector at = new PVector(width*.5+random(-dr, dr), 
      height*.5+random(-dr, dr));
    a.add(at);
  }
  background(0);
}


void setup() {
  //size(800, 600);
  fullScreen(P2D); // P2D рендерится быстро
  strokeCap(PROJECT); // квадратные точки расходуют минимум ресурсов
  frameRate(30);
  background(0);
  noCursor();
  init();
}


void draw() {

  if (keyPressed) {
    init();
  }
  if (mousePressed) {
    background(0);
  }

  float dc = 1; // "бесконечно малое" приращение координат, одного пикселя хватит
  float v = 85; // скорость движения точек под действием ускорения от поля

  // "пульсирующее" поле перемещается как стоячая двумерная волна в зависимости
  // от "цента масс" всей совокупности точек, посчитаем среднее по всем точкам
  PVector sd = new PVector();
  for (int i=0; i < n; i++) {
    PVector at = a.get(i);
    sd.add(at);
  }
  sd.div(n);

  // посчитаем ускорение каждой точки по каждой из двух осей
  // для этого найдём производную поля в координатах каждой точки,
  // используя функцию поля f (она ниже)
  for (int i=0; i < n; i++) {
    PVector at = a.get(i);
    float dx = f(at.x, at.y, sd) - f(at.x+dc, at.y, sd);
    float dy = f(at.x, at.y, sd) - f(at.x, at.y+dc, sd);
    at.x += dx*v;
    at.y += dy*v;
  }

  // отрисовка поля, полезно для понимания
  // поле выгладит как коробка для яиц, умноженная на параболоид вращения,
  // после нормировки обрезанный нулём и единицей для создания "сингулярности"
  // материальные точки как бы "скатываются" с вершин неоднородного поля.
  // Под "сингулярностью" понимаем следующее:
  //   Что означает
  //   Что происходит
  //   Когда прекращают работать законы
  //   Земного тяготения
  //   Когда исчезает земное притяжение
  //   Отказывает
  //   Не действует
  //   Забывается
  //   Земля не держит
  //   Пинает изгоняет прочь
  //   Толкает тебя вон
  //   Посылает на х*й
  //   Куда летят все знаки препинания
  //   Приливы крови отливы мочи
  //   И тому подобная эквилибристика
  //   Когда земля матушка
  //   Велит тебе ласково и душисто
  //   Пи**уй, родной !!
  //   Он сказал "поехали"
  //   И махнул рукой.
  //     1993 И. Летов

  //for (int j=0; j<height; j+=10) {
  //  for (int i=0; i<width; i+=10) {
  //    float x = float(i);
  //    float y = float(j); 
  //    float c = map(f(x, y, sd), 0, 1, 0, 255);
  //    stroke(c);
  //    strokeWeight(4.5);
  //    point(x, y); //
  //  }
  //}

  // отрисовка всех материальных точек
  stroke(255, 4);
  strokeWeight(1); //
  for (int i=0; i < n; i++) {
    PVector at = a.get(i);
    point(at.x, at.y);
  }
}


float f(float x, float y, PVector d) {
  /*
  функция гравитации, определяющая параметры пространства
   */
  float res = 0;
  float res_m;

  float k = 1.92e-2 / scale; 
  float a = width*.5;
  float b = height*.5;
  float k1 = 4.2e-5 / radius; 
  // результирующее поле складывается из двух частей:
  // параболоид из центра экрана
  res += 8-((x-a)*(x-a)*k1 + (y-b)*(y-b)*k1);
  // гармоническая функция двух координат 
  res += 2*(sin(x*k-d.x) + sin(y*k-d.y));
  // нормировка функции 
  res_m = map(res, 0, 10, 0, 1);
  // ограничение функции для создания "сингулярности"
  res_m = constrain(res_m, 0, 1);

  return res_m;
}