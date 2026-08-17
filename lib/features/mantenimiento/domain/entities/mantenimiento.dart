class MantenimientoEntity {
  final String id;
  final String titulo;
  final String descripcion;
  final int kilometrosRestantes;
  final String nivelPrioridad; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final int? kilometrajeObjetivo;
  final double? costo;

  const MantenimientoEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.kilometrosRestantes,
    required this.nivelPrioridad,
    this.kilometrajeObjetivo,
    this.costo,
  });
}
