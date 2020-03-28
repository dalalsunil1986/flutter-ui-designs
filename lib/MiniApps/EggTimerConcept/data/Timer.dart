import 'dart:async' as aSync;

class Timer {
  Timer({this.maxTime, this.onTimerUpdate});

  final Duration maxTime;
  aSync.Timer internalTimer;
  final Function onTimerUpdate;
  final Stopwatch stopwatch = Stopwatch();

  TimerState state = TimerState.ready;
  Duration currentTime = Duration(minutes: 0);
  Duration lastStartTime = Duration(minutes: 0);
  Duration cache4Reset = Duration(minutes: 0);

  setCurrentTime(time) {
    if (state == TimerState.ready) {
      currentTime = time;
      lastStartTime = currentTime;
    }
  }

  resume() {
    if (state == TimerState.running) {
      return;
    }
    if (state == TimerState.ready) {
      currentTime = Duration(minutes: (currentTime.inSeconds / 60).round());
      lastStartTime = currentTime;
    }
    state = TimerState.running;

    stopwatch.start();
    tick();
  }

  pause() {
    if (state != TimerState.running) {
      return;
    }

    state = TimerState.paused;
    stopwatch.stop();

    if (onTimerUpdate != null) {
      onTimerUpdate();
    }
  }

  restart() {
    if (state != TimerState.paused) {
      return;
    }
    state = TimerState.running;
    currentTime = lastStartTime;

    stopwatch.reset();
    stopwatch.start();

    tick();
  }

  reset() {
    if (state != TimerState.paused) {
      return;
    }

    state = TimerState.ready;
    currentTime = Duration(seconds: 0);
    lastStartTime = currentTime;
    stopwatch.reset();

    if (onTimerUpdate != null) {
      onTimerUpdate();
    }
  }

  tick() {
    currentTime = lastStartTime - stopwatch.elapsed;
    cache4Reset = currentTime;
    if (onTimerUpdate != null) {
      onTimerUpdate();
    }
    if (currentTime.inSeconds > 0) {
      internalTimer = aSync.Timer(
        Duration(seconds: 1),
        () => state == TimerState.running ? tick() : null,
      );
    } else {
      state = TimerState.ready;
    }
  }

  dispose() {
    internalTimer?.cancel();
  }
}

enum TimerState {
  ready,
  running,
  paused,
}
