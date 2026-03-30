class CustomUils {
  static String fechaActual() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  static String formatearFecha(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  static String formatDateToString(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')}";
  }

  static String getFirstDateOfMonth(DateTime dateTime) {
    final firstDate = DateTime(dateTime.year, dateTime.month, 1);
    return "${firstDate.year.toString().padLeft(4, '0')}-"
        "${firstDate.month.toString().padLeft(2, '0')}-"
        "${firstDate.day.toString().padLeft(2, '0')}";
  }

  static String getLastDateOfMonth(DateTime dateTime) {
    final lastDate = DateTime(dateTime.year, dateTime.month + 1, 0);
    return "${lastDate.year.toString().padLeft(4, '0')}-"
        "${lastDate.month.toString().padLeft(2, '0')}-"
        "${lastDate.day.toString().padLeft(2, '0')}";
  }
}
