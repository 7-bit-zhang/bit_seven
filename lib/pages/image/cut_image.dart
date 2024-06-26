import 'dart:io';

import 'package:bit_seven/utils/overall_situation.dart';
import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/image_editor.dart';

class CutImagePage extends StatefulWidget {
  const CutImagePage(this.file, {super.key});
  final File file;
  @override
  State<CutImagePage> createState() => _CutImagePageState();
}

class _CutImagePageState extends State<CutImagePage> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
              onPressed: () {
                save(context);
              },
              child: const Text("确认", style: TextStyle(color: Colors.black)))
        ],
      ),
      body: Container(
          alignment: Alignment.center,
          child: ExtendedImage.file(
            widget.file,
            fit: BoxFit.contain,
            cacheRawData: true,
            mode: ExtendedImageMode.editor,
            extendedImageEditorKey: editorKey,
            initEditorConfigHandler: (state) {
              return EditorConfig(
                lineColor: OverallSituation.typea[0],
                lineHeight: 3,
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
              );
            },
          )),
    );
  }

  void save(BuildContext context) async {
    if (editorKey.currentState != null) {
      var state = editorKey.currentState;
      Rect? cropRect = state!.getCropRect();
      var data = state.rawImageData;
      var action = editorKey.currentState!.editAction;
      final rotateAngle = action!.rotateAngle.toInt();
      final flipHorizontal = action.flipY;
      final flipVertical = action.flipX;

      ImageEditorOption option = ImageEditorOption();
      if (action.needCrop) option.addOption(ClipOption.fromRect(cropRect!));
      if (action.needFlip) {
        option.addOption(
            FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
      }

      if (action.hasRotateAngle) {
        option.addOption(RotateOption(rotateAngle));
      }

      final result = await ImageEditor.editImage(
        image: data,
        imageEditorOption: option,
      );

      Get.back(result: result);
    }
  }
}
