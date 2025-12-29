import 'package:flutter/material.dart';
import '../../data/models/partner_model.dart';
import 'eco_components.dart';
import 'eco_dialog.dart';
import 'eco_form_dialog.dart';

Future<PartnerModel?> showPartnerEditorDialog(
  BuildContext context, {
  required String type,
  PartnerModel? initial,
}) {
  final nameController = TextEditingController(text: initial?.name ?? '');
  final locationController = TextEditingController(text: initial?.location ?? '');
  final tagController = TextEditingController(text: initial?.tag ?? '');
  final subtitleController =
      TextEditingController(text: initial?.subtitle ?? '');
  final areaController = TextEditingController(text: initial?.area ?? '');
  final detailController = TextEditingController(text: initial?.detail ?? '');

  final isPengrajin = type == 'pengrajin';
  final title = initial == null
      ? (isPengrajin ? 'Tambah Mitra Pengrajin' : 'Tambah Agen Grosir')
      : (isPengrajin ? 'Edit Mitra Pengrajin' : 'Edit Agen Grosir');

  return showDialog<PartnerModel>(
    context: context,
    builder: (ctx) {
      bool busy = false;

      Future<void> save() async {
        if (busy) return;
        final name = nameController.text.trim();
        if (name.isEmpty) {
          await showEcoDialog(
            ctx,
            title: 'Data belum lengkap',
            message: 'Nama wajib diisi.',
            type: EcoDialogType.warning,
          );
          return;
        }

        if (isPengrajin) {
          final tag = tagController.text.trim();
          final location = locationController.text.trim();
          if (location.isEmpty || tag.isEmpty) {
            await showEcoDialog(
              ctx,
              title: 'Data belum lengkap',
              message: 'Lokasi dan Tag wajib diisi.',
              type: EcoDialogType.warning,
            );
            return;
          }
        } else {
          final subtitle = subtitleController.text.trim();
          final area = areaController.text.trim();
          final detail = detailController.text.trim();
          if (subtitle.isEmpty || area.isEmpty || detail.isEmpty) {
            await showEcoDialog(
              ctx,
              title: 'Data belum lengkap',
              message: 'Subtitle, Area, dan Detail wajib diisi.',
              type: EcoDialogType.warning,
            );
            return;
          }
        }

        busy = true;
        final model = PartnerModel(
          id: initial?.id,
          type: type,
          name: name,
          location: isPengrajin ? locationController.text.trim() : null,
          tag: isPengrajin ? tagController.text.trim() : null,
          subtitle: isPengrajin ? null : subtitleController.text.trim(),
          area: isPengrajin ? null : areaController.text.trim(),
          detail: isPengrajin ? null : detailController.text.trim(),
          isActive: initial?.isActive ?? true,
          createdAt: initial?.createdAt,
          updatedAt: initial?.updatedAt,
        );

        if (ctx.mounted) {
          Navigator.of(ctx).pop(model);
        }
      }

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> guardedSave() async {
            if (busy) return;
            await save();
            if (!context.mounted) return;
            setState(() {
              busy = false;
            });
          }

          return EcoFormDialog(
            title: title,
            primaryLabel: 'Simpan',
            primaryColor: isPengrajin
                ? const Color(0xFF16A34A)
                : const Color(0xFF2563EB),
            busy: busy,
            onPrimaryPressed: () async {
              setState(() {
                busy = true;
              });
              await guardedSave();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EcoInputField(
                  controller: nameController,
                  hint: isPengrajin ? 'Nama Mitra' : 'Nama Toko',
                  fillColor: const Color(0xFFF5F5F5),
                  borderColor: Colors.transparent,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                const SizedBox(height: 10),
                if (isPengrajin) ...[
                  EcoInputField(
                    controller: locationController,
                    hint: 'Lokasi',
                    fillColor: const Color(0xFFF5F5F5),
                    borderColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  const SizedBox(height: 10),
                  EcoInputField(
                    controller: tagController,
                    hint: 'Tag (contoh: Paving Block & Bata)',
                    fillColor: const Color(0xFFF5F5F5),
                    borderColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ] else ...[
                  EcoInputField(
                    controller: subtitleController,
                    hint: 'Subtitle (contoh: Agen Sembako Grosir)',
                    fillColor: const Color(0xFFF5F5F5),
                    borderColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: EcoInputField(
                          controller: areaController,
                          hint: 'Area (contoh: Ps. Minggu)',
                          fillColor: const Color(0xFFF5F5F5),
                          borderColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: EcoInputField(
                          controller: detailController,
                          hint: 'Detail (contoh: Los B-10)',
                          fillColor: const Color(0xFFF5F5F5),
                          borderColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}
