bool validateCPF(String cpf) {
  final cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleanCPF.length != 11) return false;

  if (RegExp(r'^(\d)\1+$').hasMatch(cleanCPF)) return false;

  List<int> digits = cleanCPF.split('').map((d) => int.parse(d)).toList();

  // Validate 1st digit
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += digits[i] * (10 - i);
  }
  int res = (sum * 10) % 11;
  if (res == 10) res = 0;
  if (res != digits[9]) return false;

  // Validate 2nd digit
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += digits[i] * (11 - i);
  }
  res = (sum * 10) % 11;
  if (res == 10) res = 0;
  if (res != digits[10]) return false;

  return true;
}
