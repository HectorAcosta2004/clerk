// Modelo para la tabla 'anios'
class Anio {
  final int id;
  final String nombre;

  Anio({required this.id, required this.nombre});

  factory Anio.fromJson(Map<String, dynamic> json) =>
      Anio(id: json['id'], nombre: json['nombre']);
}

// Modelo para la tabla 'salones'
class Salon {
  final int id;
  final String nombre;
  final int anioId;

  Salon({required this.id, required this.nombre, required this.anioId});

  factory Salon.fromJson(Map<String, dynamic> json) =>
      Salon(id: json['id'], nombre: json['nombre'], anioId: json['anio_id']);
}

// Modelo para la tabla 'alumnos'
class Alumno {
  final int id;
  final String matricula;
  final String nombre;
  final int? salonId;

  Alumno({
    required this.id,
    required this.matricula,
    required this.nombre,
    this.salonId,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) => Alumno(
    id: json['id'],
    matricula: json['matricula'],
    nombre: json['nombre'],
    salonId: json['salon_id'],
  );
}
