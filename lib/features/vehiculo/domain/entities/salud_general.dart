class ComponenteSaludEntity {
  final String id;
  final String nombre;
  final String etiquetaCorta;
  final int porcentaje;
  final bool esDestacado;

  const ComponenteSaludEntity({
    required this.id,
    required this.nombre,
    required this.etiquetaCorta,
    required this.porcentaje,
    this.esDestacado = false,
  });
}
