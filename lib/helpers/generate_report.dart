import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventory/global.dart';
import 'package:inventory/helpers/db_helper.dart';
import 'dart:io';
import 'package:inventory/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class Report {
  final dbhelper = DbHelper();

  // Report By File
  Future<void> byFile(FileModel file) async {
    final rooms = await dbhelper.getRooms(file.id);

    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final imageBytes = pw.MemoryImage(base64Decode(file.fileImage));
          return pw.Center(
            child: pw.Column(children: [
              pw.Text(file.fileName, style: pw.TextStyle(font: font)),
              pw.Container(child: pw.Image(imageBytes)),
            ]),
          );
        },
      ),
    );

    for (final room in rooms) {
      final List<ItemModel> items = await dbhelper.getItems(room.id);
      final roomImageBytes = pw.MemoryImage(base64Decode(room.roomImage));
      final List<pw.Widget> itemWidgets = [];

      for (final item in items) {
        final itemImageBytes = pw.MemoryImage(base64Decode(item.itemImage));
        itemWidgets.add(
          pw.Text(item.itemName, style: pw.TextStyle(font: font)),
        );
        itemWidgets.add(
          pw.Text(item.itemDetails, style: pw.TextStyle(font: font)),
        );
        itemWidgets.add(pw.Container(child: pw.Image(itemImageBytes)));
      }

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              child: pw.Column(
                children: [
                  pw.Text(room.roomName, style: pw.TextStyle(font: font)),
                  pw.Container(child: pw.Image(roomImageBytes)),
                ],
              ),
            );
          },
        ),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(children: itemWidgets);
          },
        ),
      );
    }
    final uuidd = generateUniqueId();
    final Directory? outputDir = await getExternalStorageDirectory();
    final String pdfPath = '${outputDir!.path}/${uuidd.toString()}.pdf';
    final File pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    print(pdfPath);
  }

  // Report By File
  Future<void> byRoom(RoomModel room) async {
    final items = await dbhelper.getItems(room.id);

    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final imageBytes = pw.MemoryImage(base64Decode(room.roomImage));
          return pw.Center(
            child: pw.Column(children: [
              pw.Text(room.roomName, style: pw.TextStyle(font: font)),
              pw.Container(child: pw.Image(imageBytes)),
            ]),
          );
        },
      ),
    );

    final List<pw.Widget> itemWidgets = [];

    for (final item in items) {
      final itemImageBytes = pw.MemoryImage(base64Decode(item.itemImage));
      itemWidgets.add(
        pw.Text(item.itemName, style: pw.TextStyle(font: font)),
      );
      itemWidgets.add(
        pw.Text(item.itemDetails, style: pw.TextStyle(font: font)),
      );
      itemWidgets.add(pw.Container(child: pw.Image(itemImageBytes)));
    }
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(children: itemWidgets);
        },
      ),
    );

    final uuidd = generateUniqueId();
    final Directory? outputDir = await getExternalStorageDirectory();
    final String pdfPath = '${outputDir!.path}/${uuidd.toString()}.pdf';
    final File pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    print(pdfPath);
  }
}
