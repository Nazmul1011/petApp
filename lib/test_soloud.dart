import 'package:flutter_soloud/flutter_soloud.dart';

void main() async {
  final soloud = SoLoud.instance;
  await soloud.init();
  var src = await soloud.loadWaveform(WaveForm.sin, true, 0.25, 1.0);
  await soloud.play(src);
}
