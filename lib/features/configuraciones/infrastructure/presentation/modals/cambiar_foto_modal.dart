import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';

class CambiarFotoModal extends StatefulWidget {
  final Function(String nuevaImagenUrl) onFotoSeleccionada;

  const CambiarFotoModal({
    super.key,
    required this.onFotoSeleccionada,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String nuevaImagenUrl) onFotoSeleccionada,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CambiarFotoModal(onFotoSeleccionada: onFotoSeleccionada),
    );
  }

  @override
  State<CambiarFotoModal> createState() => _CambiarFotoModalState();
}

class _CambiarFotoModalState extends State<CambiarFotoModal> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _seleccionarDeFuente(ImageSource source) async {
    try {
      setState(() => _isProcessing = true);
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 900,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.pop(context);
        widget.onFotoSeleccionada(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? '¡Fotografía capturada exitosamente!'
                  : '¡Imagen cargada desde la galería!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al acceder a la imagen: $e'),
            backgroundColor: AppColors.onErrorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Foto del Vehículo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              if (_isProcessing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Captura o selecciona una foto horizontal de tu vehículo para mostrar en Home',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Opción 1: Cámara
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_camera, color: AppColors.primary),
            ),
            title: const Text(
              'Tomar Foto con la Cámara',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            subtitle: const Text('Captura una fotografía en tiempo real', style: TextStyle(fontSize: 12)),
            onTap: _isProcessing ? null : () => _seleccionarDeFuente(ImageSource.camera),
          ),
          const Divider(),

          // Opción 2: Galería / Archivo
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_library, color: AppColors.primary),
            ),
            title: const Text(
              'Elegir de Galería o Archivos',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            subtitle: const Text('Selecciona una imagen almacenada en tu dispositivo', style: TextStyle(fontSize: 12)),
            onTap: _isProcessing ? null : () => _seleccionarDeFuente(ImageSource.gallery),
          ),
          const Divider(),

          // Opción 3: Restablecer
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.onErrorContainer),
            ),
            title: const Text(
              'Restablecer Foto Predeterminada',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onErrorContainer),
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onFotoSeleccionada(
                'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=800&auto=format&fit=crop',
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
