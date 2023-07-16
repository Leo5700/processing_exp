

import processing.sound.*;


class Root {

  // исходные параметры
  ArrayList<PVector> params = new ArrayList<PVector>(); 
  // преобразование в координаты для отрисовки
  ArrayList<PVector> coords = new ArrayList<PVector>();
  // преобразование в парметры осциллятора (.freq .amp .pan) 
  ArrayList<PVector> fap = new ArrayList<PVector>(); 
  int len = 100; // число элементов семпла

  // опорные размеры для отрисовки
  float basemin;
  float basemax;


  float mtek; 

  float duration = 2000; // длительность 
  //семпла, ms (стартовое значение, при 
  //переинициализации поменяется)
  float dt; // длительность одного 
  //элемена сэмпла, ms
  int it = 0;  // номер текущего 
  //элемента семпла
  int n; // номер объекта - номер 
  //дорожки-семпла

  float sh0 = 0; // начальное значение 
  //шума Перлина
  float dsh; // шаг шума Перлина

  int noct = 4; // число октав шума 
  //Перлина, определяет его разнообразие, 
  //(1..10) умолчанию 4

  SawOsc saw;
  SinOsc sino;


  void init(int n_) {
    dt = duration/len;

    noiseDetail(noct, .5); // https://processing.org/reference/noiseDetail_.html

    // нарезка псевдослучайной 
    //последовательности шума Перлина 
    //на элементы, преобразование их в 
    //координаты и параметры звука 

    n = n_;

    noiseSeed((long)random(42000000));

    dsh = 0.01;
    basemin = min(width, height);
    basemax = max(width, height);

    float coct = 1; // подгоночный 
    //коэффициент, если брать одну 
    //октаву, шум не превышает 0.5
    if (noct == 1)
      coct = 2;
    if (noct == 2 || noct == 3)
      coct = 1.333;

    for (int i=0; i < len; i++) {
      float x = coct*noise(sh0 + i * dsh);
      float y = coct*noise(sh0 + i * dsh + 100);
      float z = coct*noise(sh0 + i * dsh + 200);

      params.add(new PVector(x, y, z));

      coords.add(new PVector(
        map(x, 0, 1, -width/n*.6, width/n*.6), 
        map(y, 0, 1, -height*.5, height*.5), 
        map(z, 0, 1, -basemin*.4, basemin*.4)));

      fap.add(new PVector(
        // диапазон частот freq (будет 
        //отображен по вертикали)
        map(y, 0, 1, 40, 140), 
        // amp (будет размером квадрата)
        map(x, 0, 1, 0.1, 0.75), 
        // pan (не визуализируется)
        map(z, 0, 1, -0.5, 0.5))); 
    } 

    mtek = millis();
  }


  void display() {
    pushStyle();

    stroke(255);
    strokeWeight(basemin*0.025); 

    if (millis()-mtek > dt) { // если 
      //элемент должен быть воспроизведен
      mtek = millis();

      PVector c = coords.get(it);
      PVector p = params.get(it);

      // выводим квадрат (большую 
      //квадратную точку, потребляет минимум ресурсов)
      strokeWeight(basemax*0.025*map(p.x, 0, 1, 0, 9.2));
      if (!saw.isPlaying())
        strokeWeight(basemax*0.025*0.1);
      strokeCap(PROJECT);
      point(c.x*0, -c.y); //// по горизонтали перемещение обнулено

      // воспроизводим нужный звук 
      PVector f = fap.get(it);
      
      //saw.freq(roundTone(f.x); // округление к равномерно темперированному строю (сейчас не используется).
      saw.freq(f.x);
      saw.amp(f.y*.7); // громкость (0..1)
      saw.pan(f.z);

      sino.freq(f.x*.5); // дополнительная синусоидальная волна на октаву ниже
      sino.amp(f.y*.95); // громкость (0..1)
      sino.pan(f.z);


      float fdi = len/(duration*.001) / frameRate;
      fdi = constrain(fdi, 1, len);
      int di = int(fdi);

      it += di;
      if (it >= len)
        it = 0;
    }

    popStyle();
  }
}


///////////////////////////////////////////

// Функции для округления частот к равномерно темперированному строю



float roundTone(float freq_raw) {
  // получает произвольную частоту, выдаёт ближайшую "равномерно темперированную" частоту
  float freq_rnd = -1;
  for (int i=10; i<250; i++) {
    if (midiFreqs[i] <= freq_raw &&
      midiFreqs[i+1] > freq_raw) {
      freq_rnd = midiFreqs[i];
      break;
    }
  }
  return freq_rnd;
}

float getMidiNoteFreq(int n) {
  // получим частоту по миди номеру n
  // https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
  float f0 = 440; // A4 это 69я миди-нота
  float fn = f0 * pow(2, (n-69)/12.);
  return fn;
}

float[] midiFreqs = new float[500]; // 500 миди-нот, с запасом
void fillMidiFreqs() {
  // наполняет список частот, запустить однократно в setup()
  for (int i=0; i<midiFreqs.length; i++) {
    midiFreqs[i] = getMidiNoteFreq(i);
  }
}
