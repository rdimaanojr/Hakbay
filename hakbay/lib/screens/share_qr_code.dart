import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/providers/travel_provider.dart';
import 'package:hakbay/providers/user_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareQrCode extends StatefulWidget {
  final TravelPlan travelPlan;

  const ShareQrCode({super.key, required this.travelPlan});

  @override
  State<ShareQrCode> createState() => _ShareQrCodeState();
}

class _ShareQrCodeState extends State<ShareQrCode> {
  final GlobalKey _qrKey = GlobalKey();
  final TextEditingController usernameController = TextEditingController();

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

  Future<void> shareWithUsername() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) return;

    final uid = await context.read<UserProvider>().getUidByUsername(username);

    if (uid == null) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username not found.")),
      );
      return;
    }

    if (uid == widget.travelPlan.uid) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You cannot share with yourself.")),
      );
      return;
    }

    if (widget.travelPlan.sharedWith.contains(uid)) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User already has access.")),
      );
      return;
    } 

    await context.read<TravelPlanProvider>().shareTravelPlan(widget.travelPlan, uid);
    
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Successfully shared with @$username")),
    );

    usernameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share this travel plan',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // QR + Download Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: QrImageView(
                    data: widget.travelPlan.planId!,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
              
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _saveQrImage,
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 30),
                tooltip: "Download QR",
              )
            ],
          ),

          const SizedBox(height: 24),

          // Username Input
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.alternate_email, color: Colors.white70),
              labelText: "Enter username",
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 16),

          // Share Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: shareWithUsername,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("Share", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1DB954),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
