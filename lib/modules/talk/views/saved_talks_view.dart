import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../../talk/models/translation_model.dart';
import '../../talk/services/talk_api_service.dart';

class SavedTalksController extends GetxController {
  final TalkApiService _api = TalkApiService();
  final AudioPlayer _player = AudioPlayer();

  final talks = <TranslationModel>[].obs;
  final isLoading = false.obs;
  final RxBool showHumanToPet = true.obs; // true = human→pet view active
  final RxInt playingIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    fetchSaved();
  }

  Future<void> fetchSaved() async {
    isLoading.value = true;
    final all = await _api.listSaved();
    talks.value = all;
    isLoading.value = false;
  }

  List<TranslationModel> get filtered => talks
      .where((t) => showHumanToPet.value ? t.isHumanToPet : !t.isHumanToPet)
      .toList();

  void toggleView() {
    showHumanToPet.value = !showHumanToPet.value;
    stopPlaying();
  }

  Future<void> togglePlay(int index, String? audioUrl) async {
    if (playingIndex.value == index) {
      await _player.stop();
      playingIndex.value = -1;
      return;
    }
    await _player.stop();
    playingIndex.value = index;

    if (audioUrl != null && audioUrl.startsWith('http')) {
      await _player.play(UrlSource(audioUrl));
    } else if (audioUrl != null && audioUrl.startsWith('file://')) {
      await _player.play(
        DeviceFileSource(audioUrl.replaceFirst('file://', '')),
      );
    } else if (audioUrl != null && audioUrl.isNotEmpty) {
      await _player.play(AssetSource(audioUrl));
    }
    _player.onPlayerComplete.listen((_) => playingIndex.value = -1);
  }

  void stopPlaying() {
    _player.stop();
    playingIndex.value = -1;
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}

class SavedTalksView extends StatelessWidget {
  const SavedTalksView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedTalksController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7F67CB)),
                  );
                }
                final list = controller.filtered;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.width(32)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.mic_none,
                            size: 64,
                            color: Color(0xFFCDC8E8),
                          ),
                          SizedBox(height: R.height(16)),
                          Text(
                            'No saved talks yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: R.height(8)),
                          Text(
                            'Record a voice on the home screen and tap "Save and continue".',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.width(20),
                    vertical: R.height(8),
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: R.height(10)),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Obx(
                      () => _TalkCard(
                        item: item,
                        index: index,
                        isPlaying: controller.playingIndex.value == index,
                        onPlay: () {
                          controller.togglePlay(index, item.inputAudioUrl);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SavedTalksController controller) {
    return Padding(
      padding: EdgeInsets.only(
        left: R.width(16),
        right: R.width(16),
        top: R.height(8),
        bottom: R.height(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back, size: 22, color: Colors.black),
          ),
          SizedBox(height: R.height(12)),
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Saved talks',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                // Human icon
                GestureDetector(
                  onTap: controller.showHumanToPet.value
                      ? null
                      : controller.toggleView,
                  child: _AvatarBadge(
                    isActive: controller.showHumanToPet.value,
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.width(8)),
                  child: GestureDetector(
                    onTap: controller.toggleView,
                    child: const Icon(
                      Icons.swap_horiz,
                      size: 22,
                      color: Color(0xFF7F67CB),
                    ),
                  ),
                ),
                // Pet icon
                GestureDetector(
                  onTap: controller.showHumanToPet.value
                      ? controller.toggleView
                      : null,
                  child: _AvatarBadge(
                    isActive: !controller.showHumanToPet.value,
                    child: Image.asset(
                      'assets/images/dog_happy_face.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: R.height(8)),
        ],
      ),
    );
  }
}

/// Circular avatar badge for the header toggle
class _AvatarBadge extends StatelessWidget {
  final bool isActive;
  final Widget child;
  const _AvatarBadge({required this.isActive, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF7F67CB) : Colors.grey.shade200,
      ),
      child: Center(child: child),
    );
  }
}

/// Individual saved talk card with waveform + name + play button
class _TalkCard extends StatelessWidget {
  final TranslationModel item;
  final int index;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _TalkCard({
    required this.item,
    required this.index,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        item.savedName ??
        item.inputText ??
        (item.isHumanToPet ? 'Human voice' : 'Pet sound');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(16),
        vertical: R.height(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: R.height(6)),
                _Waveform(isPlaying: isPlaying),
              ],
            ),
          ),
          SizedBox(width: R.width(12)),
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying
                    ? const Color(0xFF7F67CB)
                    : const Color(0xFF7F67CB),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated waveform bars (static when idle, animated when playing)
class _Waveform extends StatelessWidget {
  final bool isPlaying;
  const _Waveform({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final rng = Random(42); // Fixed seed for consistent bar heights
    return SizedBox(
      height: 24,
      child: Row(
        children: List.generate(28, (i) {
          final staticHeight = 4.0 + rng.nextDouble() * 14.0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: _WaveBar(
              height: staticHeight,
              isPlaying: isPlaying,
              index: i,
            ),
          );
        }),
      ),
    );
  }
}

class _WaveBar extends StatefulWidget {
  final double height;
  final bool isPlaying;
  final int index;
  const _WaveBar({
    required this.height,
    required this.isPlaying,
    required this.index,
  });

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 20),
    );
    _anim = Tween<double>(
      begin: 4,
      end: widget.height,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_WaveBar old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 3,
        height: widget.isPlaying ? _anim.value : widget.height,
        decoration: BoxDecoration(
          color: widget.isPlaying
              ? const Color(0xFF7F67CB)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
