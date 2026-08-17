class UsuarioEntity {
  final String id;
  final String email;
  final String nombre;
  final String? fotoUrl;

  const UsuarioEntity({
    required this.id,
    required this.email,
    required this.nombre,
    this.fotoUrl,
  });
}
