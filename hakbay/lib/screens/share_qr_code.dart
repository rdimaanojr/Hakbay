import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareQrCode extends StatefulWidget {
  final String planId;

  const ShareQrCode({super.key, required this.planId});

  @override
  State<ShareQrCode> createState() => _ShareQrCodeState();
}

class _ShareQrCodeState extends State<ShareQrCode> {

  Future<void> _saveQrImage() async {
    // TODO: Save QR code to gallery
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
          QrImageView(
              data: widget.planId,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
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
