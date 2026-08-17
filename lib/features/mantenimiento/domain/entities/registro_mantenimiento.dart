enum CategoriaMantenimiento { gasolina, taller, lavado }

class RegistroMantenimientoEntity {
  final String id;
  final String titulo;
  final DateTime fecha;
  final double costo;
  final int kilometraje;
  final CategoriaMantenimiento categoria;

  const RegistroMantenimientoEntity({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.costo,
    required this.kilometraje,
    required this.categoria,
  });
}
