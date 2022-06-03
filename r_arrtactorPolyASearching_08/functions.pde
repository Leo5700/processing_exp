// Полезные функции

int numUnique(float[] list) {
  // функция для подсчёта числа одинаковых значений в векторе,
  // где-то стырена и доработана напильником :)
  int counter = 0;
  for (int i = 0; i < list.length; i++) {
    boolean unique = true;
    for (int j = i + 1; j < list.length; j++) {
      if (list[i] == list[j]) {
        unique = false;
        break;
      }
    }
    if (unique) counter++;
  }
  return counter;
}
