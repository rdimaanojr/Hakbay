import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareQrCode extends StatefulWidget {
  final String planId;

  const ShareQrCode({super.key, required this.planId});

  @override
  State<ShareQrCode> createState() => _ShareQrCodeState();
}

class _ShareQrCodeState extends State<ShareQrCode> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _saveQrImage() async {
    final status = await Permission.photos.request();
    
    if (!status.isGranted) {
      final storageStatus = await Permission.storage.request();

      if(!storageStatus.isGranted){
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission denied.")),
        );
        return;
      }
    }

    RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3);
    ByteData? bytedata = await (image.toByteData(format: ImageByteFormat.png));

    if(bytedata != null){
      final result = await ImageGallerySaverPlus.saveImage(bytedata.buffer.asUint8List());
      print(result);

      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR Code saved to gallery.")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Scan this QR to join this travel plan',
              style: TextStyle(color: Colors.white),),
          SizedBox(height: 16),
          // Generate QR Image
          RepaintBoundary(
            key: _qrKey,
            child: QrImageView(
              data: widget.planId,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            )
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveQrImage,
              icon:  Icon(Icons.download, color: Colors.white,),
              label:  Text("Download QR", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }
}
