import 'dart:async';

class TimerService {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  final Function(Duration) onTick;
  final Function()? onComplete;

  TimerService({required this.onTick, this.onComplete});

  bool get isRunning => _timer?.isActive ?? false;
  Duration get elapsed => _elapsed;

  void setElapsedTime(Duration duration) {
    _elapsed = duration;
    onTick(_elapsed);
  }

  void start() {
    if (_timer?.isActive ?? false) return;

    _elapsed = Duration.zero;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _elapsed + const Duration(seconds: 1);
      onTick(_elapsed);
    });

    print('✅ Timer started');
  }

  void stop() {
    _timer?.cancel();
    print('⏹️ Timer stopped');
  }

  void pause() {
    _timer?.cancel();
    print('⏸️ Timer paused');
  }

  void resume() {
    if (_timer?.isActive ?? false) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _elapsed + const Duration(seconds: 1);
      onTick(_elapsed);
    });

    print('▶️ Timer resumed');
  }

  void reset() {
    _timer?.cancel();
    _elapsed = Duration.zero;
    print('🔄 Timer reset');
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void dispose() {
    _timer?.cancel();
  }
}
