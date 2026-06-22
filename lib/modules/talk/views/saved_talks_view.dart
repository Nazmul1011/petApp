import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/empty_state/app_empty_state.dart';
import '../../talk/models/translation_model.dart';
import '../../talk/services/talk_api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/snack_bar/app_snack_bar.dart';

class SavedTalksController extends GetxController {
  final TalkApiService _api = TalkApiService();
  final AudioPlayer _player = AudioPlayer();

  final talks = <TranslationModel>[].obs;
  final isLoading = false.obs;
  final RxBool showHumanToPet = true.obs; // true = human→pet view active
  final RxInt playingIndex = (-1).obs;
  final RxString petIcon = 'assets/images/dogwave.png'.obs;

  @override
  void onInit() {
    super.onInit();
    _updatePetIcon();
    fetchSaved();

    // Dynamically update pet icon when the active user profile switches pets
    ever(AuthController.to.user, (_) {
      _updatePetIcon();
    });
  }

  void _updatePetIcon() {
    try {
      final user = AuthController.to.user.value;
      if (user != null) {
        final activePetId = user.activePetId;
        final pets = user.pets;
        if (activePetId != null && pets != null) {
          final activePet = pets.firstWhere(
            (p) => p['id'] == activePetId,
            orElse: () => pets.first,
          );
          if (activePet['type'] == 'CAT') {
            petIcon.value = 'assets/images/catwave.png';
          } else {
            petIcon.value = 'assets/images/dogwave.png';
          }
        }
      }
    } catch (e) {
      print('[SavedTalks] Error updating pet icon: $e');
    }
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

  Future<void> deleteTalk(int index) async {
    try {
      final list = filtered;
      if (index < 0 || index >= list.length) return;
      final item = list[index];
      
      final success = await _api.deleteSaved(item.id);
      if (success) {
        talks.removeWhere((t) => t.id == item.id);
        showSnack(
          content: 'Talk deleted successfully',
          status: SnackBarStatus.success,
        );
      } else {
        showSnack(
          content: 'Failed to delete talk',
          status: SnackBarStatus.error,
        );
      }
    } catch (e) {
      print('[SavedTalks] Error deleting talk: $e');
    }
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C3BAA),
                        ),
                      );
                    }

                    final list = controller.filtered;
                    if (list.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.separated(
                      padding: EdgeInsets.only(
                        left: R.width(20),
                        right: R.width(20),
                        top: R.height(8),
                        bottom: R.height(100), // Extra padding to clear the floating mode toggle
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => SizedBox(height: R.height(10)),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            controller.deleteTalk(index);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: R.width(16)),
                            color: Colors.transparent,
                            child: Container(
                              width: R.width(48),
                              height: R.width(48),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFEBEB),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFF05151),
                                size: 24,
                              ),
                            ),
                          ),
                          child: Obx(
                            () => _TalkCard(
                              item: item,
                              index: index,
                              isPlaying: controller.playingIndex.value == index,
                              onPlay: () {
                                controller.togglePlay(index, item.inputAudioUrl);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
            Obx(() {
              if (controller.isLoading.value || controller.filtered.isNotEmpty) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: R.height(96),
                left: 0,
                right: 0,
                bottom: R.height(96),
                child: const AppEmptyState(
                  icon: Icons.mic_none_outlined,
                  title: 'No saved talks',
                  description:
                      'Record a voice on the home screen and access it from here',
                ),
              );
            }),
            Positioned(
              bottom: R.height(24),
              left: 0,
              right: 0,
              child: Center(
                child: _buildModeToggle(controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SavedTalksController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(20),
        vertical: R.height(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
          SizedBox(height: R.height(16)),
          const Text(
            'Saved talks',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(SavedTalksController controller) {
    return GestureDetector(
      onTap: controller.toggleView,
      child: Container(
        width: R.width(192),
        height: R.height(66),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(33),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: R.width(192),
              height: R.height(66),
              padding: EdgeInsets.symmetric(
                horizontal: R.width(8),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(33),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildToggleAvatar(controller, isHuman: controller.showHumanToPet.value),
                    AnimatedRotation(
                      turns: controller.showHumanToPet.value ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    _buildToggleAvatar(controller, isHuman: !controller.showHumanToPet.value),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleAvatar(SavedTalksController controller, {required bool isHuman}) {
    return isHuman
        ? Image.asset(
            'assets/images/Emoji Image.png',
            width: R.width(32),
            height: R.width(32),
            fit: BoxFit.contain,
          )
        : Image.asset(
            controller.petIcon.value,
            width: R.width(32),
            height: R.width(32),
            fit: BoxFit.contain,
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
              width: R.width(32),
              height: R.width(32),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: OverflowBox(
                minWidth: R.width(54),
                maxWidth: R.width(54),
                minHeight: R.width(54),
                maxHeight: R.width(54),
                child: Image.asset(
                  isPlaying
                      ? 'assets/images/audio_button/pause.png'
                      : 'assets/images/audio_button/start_playing.png',
                  fit: BoxFit.contain,
                ),
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
              ? const Color(0xFF6C3BAA)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
