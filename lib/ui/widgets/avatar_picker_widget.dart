import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_image/crop_image.dart';

class AvatarPicker extends StatefulWidget {
  final Uint8List? currentAvatar;
  final Function(Uint8List) onAvatarChanged;
  final double size;

  const AvatarPicker({
    Key? key,
    this.currentAvatar,
    required this.onAvatarChanged,
    this.size = 120,
  }) : super(key: key);

  @override
  _AvatarPickerState createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;
      /*Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AvatarCropper(
            imageData: bytes,
            onCropped: (croppedBytes) {
              widget.onAvatarChanged(croppedBytes);
            },
          ),
        ),
      );*/
      widget.onAvatarChanged(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: widget.size,
        backgroundImage: widget.currentAvatar != null
            ? MemoryImage(widget.currentAvatar!)
            : null,
        child: widget.currentAvatar == null
            ? Icon(Icons.add_a_photo, size: widget.size * 0.5)
            : null,
      ),
    );
  }
}

class AvatarCropper extends StatefulWidget {
  final Uint8List imageData;
  final Function(Uint8List) onCropped;

  const AvatarCropper({
    required this.imageData,
    required this.onCropped,
    Key? key,
  }) : super(key: key);

  @override
  _AvatarCropperState createState() => _AvatarCropperState();
}

class _AvatarCropperState extends State<AvatarCropper> {
  final _cropController = CropController(aspectRatio: 1);
  late ui.Image _decodedImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    _decodedImage = await _decodeImage(widget.imageData);
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

Future<Uint8List> _cropImage() async {
    final cropRect = _cropController.crop;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    final imageWidth = _decodedImage.width.toDouble();
    final imageHeight = _decodedImage.height.toDouble();
    final displaySize = 300.0;

    final imageAspect = imageWidth / imageHeight;
    final displayAspect = 1.0;

    double scale, offsetX, offsetY;

    if (imageAspect > displayAspect) {
      scale = displaySize / imageWidth;
      offsetX = 0;
      offsetY = (displaySize - imageHeight * scale) / 2;
    } else {
      scale = displaySize / imageHeight;
      offsetX = (displaySize - imageWidth * scale) / 2;
      offsetY = 0;
    }

    final sourceLeft = (cropRect.left - offsetX) / scale;
    final sourceTop = (cropRect.top - offsetY) / scale;
    final sourceWidth = cropRect.width / scale;
    final sourceHeight = cropRect.height / scale;

    final clampedLeft = sourceLeft.clamp(0, imageWidth - sourceWidth);
    final clampedTop = sourceTop.clamp(0, imageHeight - sourceHeight);
    final clampedWidth = sourceWidth.clamp(0, imageWidth - clampedLeft);
    final clampedHeight = sourceHeight.clamp(0, imageHeight - clampedTop);

    final sourceRect = Rect.fromLTWH(
      clampedLeft.toDouble(),
      clampedTop.toDouble(),
      clampedWidth.toDouble(),
      clampedHeight.toDouble(),
    );


    canvas.drawImageRect(
      _decodedImage,
      sourceRect,
      Rect.fromLTWH(0, 0, 200, 200),
      paint,
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(200, 200);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _confirmCrop() async {
    try {
      final croppedBytes = await _cropImage();
      widget.onCropped(croppedBytes);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обрезке: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обрезать аватарку'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmCrop,
          ),
        ],
      ),
      body: Center(
        child: CropImage(
          controller: _cropController,
          image: Image.memory(widget.imageData),
          paddingSize: 20.0,
        ),
      ),
    );
  }
}
