/*
Поиск странных аттракторов в двумерном
 пространстве по уравнениям cubic map
 attractor с 20ю коэффициентами.
 
 По двойному клику/тапу/ или любой 
 клавише инициализируется поиск 
 нового решения.
 
 Выделение рамкой сначала зумит, 
 потом анзумит обратно.
 
 
 В левом верхнем углу отображается 
 экспонента Ляпунова для x и y
 (вернее, её аналог для одной итерации, 
 условно названный "локальное 
 расстояние Ляпунова").
 */

float xn, yn;
float x, y;
float xnp, ynp, xp, yp;
float xnmin, xnmax, ynmin, ynmax;

float a_min = -1.3;
float a_max = 1.3;
float ld_tr = -1e8; //

float[] c;
float dx_curr, dx_prev, dy_curr, dy_prev;
float ld_x, ld_y;

int zoom_mode_switch = 1;


void coefsInit() {
  for (int i=0; i<c.length; i++) {
    c[i] = random(a_min, a_max);
  }
}


void setup() {
  //size(600, 600);
  fullScreen();
  background(0);
  c = new float[20];
  coefsInit();

  mouse_setup();
  rectMode(CORNERS);
}


void draw() {
  mouse_update();

  if (mouse_undragged_event) {
    background(0);
    zoom_mode_switch *= -1;
  }


  if (xn!=xn || yn!=yn || 
    double_click || keyPressed || 
    ld_x < ld_tr || ld_y < ld_tr ||
    ld_x == 0 || ld_y == 0) {
    coefsInit();
    text("init", random(0, width), 100);
    x = random(-1, 1);
    y = random(-1, 1);
    xnmin=0; 
    xnmax=0; 
    ynmin=0; 
    ynmax=0;
    dx_curr=0; 
    dx_prev=0; 
    dy_curr=0; 
    dy_prev=0;
    background(0);

    mouse_setup();
    zoom_mode_switch = -1;
  }

  // полином cubic map

  xn = c[0] + c[1]*x + c[2]*x*x + 
    c[3]*x*x*x + c[4]*x*x*y + c[5]*x*y 
    + c[6]*x*y*y + c[7]*y + c[8]*y*y + 
    c[9]*y*y*y; 

  yn = c[10] + c[11]*x + c[12]*x*x + 
    c[13]*x*x*x + c[14]*x*x*y + c[15]*x*y + 
    c[16]*x*y*y + c[17]*y + c[18]*y*y + 
    c[19]*y*y*y; 

  dx_curr = abs(xn-x);
  dy_curr = abs(yn-y);

  ld_x = log(dx_curr/dx_prev); // "лок����льное" расстояние Ляпунова
  ld_y = log(dy_curr/dy_prev); 

  if (xn==xn && yn==yn) {

    if (xn<xnmin) xnmin=xn;
    if (xn>xnmax) xnmax=xn;
    if (yn<ynmin) ynmin=yn;
    if (yn>ynmax) ynmax=yn;

    float x_lt_raw, y_lt_raw, x_rb_raw, y_rb_raw;

    if (zoom_mode_switch == 1) {
      x_lt_raw = map(m_frame_x_lt, 0, width, xnmin, xnmax);
      y_lt_raw = map(m_frame_y_lt, 0, height, ynmin, ynmax);
      x_rb_raw = map(m_frame_x_rb, 0, width, xnmin, xnmax);
      y_rb_raw = map(m_frame_y_rb, 0, height, ynmin, ynmax);

      xnp = map(xn, x_lt_raw, x_rb_raw, 0, width);
      ynp = map(yn, y_lt_raw, y_rb_raw, 0, height);
      xp = map(x, x_lt_raw, x_rb_raw, 0, width);
      yp = map(y, y_lt_raw, y_rb_raw, 0, height);
    } else {
      xnp = map(xn, xnmin, xnmax, 0, width);
      ynp = map(yn, ynmin, ynmax, 0, height);
      xp = map(x, xnmin, xnmax, 0, width);
      yp = map(y, ynmin, ynmax, 0, height);
    }


    strokeWeight(1);
    stroke(255, 60);
    line(xp, yp, xnp, ynp);

    noStroke();
    fill(0);
    rect(2, 2, 50, 30);

    fill(200);
    text(ld_x, 10, 20);
    text(ld_y, 10, 30);
  }

  x = xn;
  y = yn;
  dx_prev = dx_curr;
  dy_prev = dy_curr;
}


// ====================================
// мышиные дела, их лучше 
// вынести отдельным табом


boolean mouse_dragged, mouse_released, mouse_pressed;
boolean mouse_undragged_event = false;

int dc_millis = 220;
long click_time;
long double_click_fc;
boolean double_click = false;

float drag_frame_x_beg, drag_frame_y_beg, drag_frame_x_end, drag_frame_y_end;
float m_frame_x_lt, m_frame_y_lt, m_frame_x_rb, m_frame_y_rb;

boolean long_press = false;
long pressing_duration = 0;
long pressing_starts;


void mouse_setup() {
  m_frame_x_lt = 0;
  m_frame_y_lt = 0;
  m_frame_x_rb = width;
  m_frame_y_rb = height;
}


void mouse_update() {
  if (mouse_dragged && mouse_released && mouse_pressed) {
    mouse_undragged_event = true;
    mouse_dragged = false;
    mouse_released = false;
    mouse_pressed = false;
  } else {
    mouse_undragged_event = false;
    mouse_released = false; // =) без этого не ку
  }
  if (frameCount > double_click_fc + 1) {
    double_click = false;
  }
  if (mouse_dragged) {

    if (zoom_mode_switch == -1) { //// это ай-ай-ай тащить сюда переменн����������������ю из другого таба! но приходится.)
      noStroke();
      fill(255, 4);
    }
     else {
      noFill();
      stroke(255, 200);
    }
    rect(drag_frame_x_beg, drag_frame_y_beg, drag_frame_x_end, drag_frame_y_end);
  }
  if (mouse_undragged_event) {
    m_frame_x_lt = min(drag_frame_x_beg, drag_frame_x_end);
    m_frame_y_lt = min(drag_frame_y_beg, drag_frame_y_end);
    m_frame_x_rb = max(drag_frame_x_beg, drag_frame_x_end);
    m_frame_y_rb = max(drag_frame_y_beg, drag_frame_y_end);
  }
}


void mouseDragged() {
  if (!mouse_dragged) {
    drag_frame_x_beg = mouseX;
    drag_frame_y_beg = mouseY;
    mouse_dragged = true;
  }
  drag_frame_x_end = mouseX;
  drag_frame_y_end = mouseY;

  pressing_duration = 0;
  long_press = false;
}


void mouseReleased() {
  mouse_released = true;

  pressing_duration = 0;
  long_press = false;
}


void mousePressed() {
  mouse_pressed = true;
  if (millis() - click_time > 10) { // от дребезга
    if (millis() - click_time < dc_millis) {
      double_click = true;
      double_click_fc = frameCount;
    } else {
      double_click = false;
    }
    click_time = millis();
  }

  if (pressing_duration == 0)
    pressing_starts = millis();
  if (pressing_starts != millis()) {
    pressing_duration = millis() - pressing_starts;
  }
  if (pressing_duration > 2000) { //
    long_press = true;
  } else {
    long_press = false;
  }
}
