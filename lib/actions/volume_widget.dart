import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_audio_manager/tizen_audio_manager.dart';
import 'package:tizen_fs/providers/volume_provider.dart';

class VolumeWidget extends StatefulWidget {
  const VolumeWidget({super.key});

  @override
  State<VolumeWidget> createState() => VolumeWidgetState();
}

class VolumeWidgetState extends State<VolumeWidget> {
  @override
  void initState() {
    super.initState();
    context.read<VolumeProvider>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: 500,
        height: 65,
        child: Consumer<VolumeProvider>(
          builder: (context, provider, child) {
            final volumeData = provider.getVolumeData(AudioVolumeType.media);

            // 데이터 타입 변환 및 방어 코드
            final double maxVal = volumeData.maxLevel.toDouble();
            final double currentVal = volumeData.level.toDouble();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${volumeData.level}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: Slider(
                      // max가 0이면 슬라이더가 비활성화되도록 설정
                      value: maxVal > 0 ? currentVal.clamp(0.0, maxVal) : 0.0,
                      min: 0.0,
                      max: maxVal > 0 ? maxVal : 1.0,
                      divisions: maxVal > 0 ? maxVal.toInt() : null,
                      onChanged:
                          maxVal > 0
                              ? (double value) {
                                // 드래그 즉시 레벨 변경 및 notifyListeners() 트리거
                                provider.setLevel(
                                  AudioVolumeType.media,
                                  value.toInt(),
                                );
                              }
                              : null,
                      onChangeEnd: (value) {},
                      onChangeStart: (_) {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
