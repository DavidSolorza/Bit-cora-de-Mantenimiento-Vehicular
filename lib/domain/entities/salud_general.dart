class ComponenteSaludEntity {
  final String id;
  final String nombre; // 'BATTERY', 'BRAKES', 'ENGINE', 'TIRES', 'FLUIDS'
  final String etiquetaCorta; // 'Bat', 'Fre', 'Mot', 'Lla', 'Liq'
  final int porcentaje; // 0..100
  final bool esDestacado;

  const ComponenteSaludEntity({
    required this.id,
    required this.nombre,
    required this.etiquetaCorta,
    required this.porcentaje,
    this.esDestacado = false,
  });
}
