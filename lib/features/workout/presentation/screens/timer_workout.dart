import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../providers/workout_provider.dart';
import 'workout_summary.dart';

class TimerWorkoutScreen extends StatefulWidget {
  final String workoutType; // "Running" or "Walking"

  const TimerWorkoutScreen({
    super.key,
    required this.workoutType,
  });

  @override
  State<TimerWorkoutScreen> createState() => _TimerWorkoutScreenState();
}

class _TimerWorkoutScreenState extends State<TimerWorkoutScreen> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  // --- FIXED FINISH LOGIC ---
  void _onFinishPress() async {
    // 1. Stop Timer & Pause
    _timer?.cancel();
    setState(() => _isPaused = true);

    // 2. ✅ THE FIX: Remove the 10-second limit
    // If time is > 0, use it. If it's 0 (instant click), default to 1 second.
    final int finalSeconds =
    _elapsedTime.inSeconds > 0 ? _elapsedTime.inSeconds : 1;

    // 3. SHOW LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    // 4. CALL PROVIDER
    final provider = Provider.of<WorkoutProvider>(context, listen: false);

    // We pass 'null' for coreExercises since this is Running/Walking
    final workout = await provider.finishWorkout(
      type: widget.workoutType,
      durationSeconds: finalSeconds,
      coreExercises: null,
    );

    // 5. HIDE LOADER
    if (mounted) Navigator.pop(context);

    // 6. NAVIGATE TO SUMMARY
    if (workout != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(
            workoutType: widget.workoutType,
            totalTime: Duration(seconds: finalSeconds),
            caloriesBurned: workout.caloriesBurned,
          ),
        ),
      );
    }
  }

  IconData _getIcon() {
    if (widget.workoutType == 'Running') return Icons.directions_run_rounded;
    if (widget.workoutType == 'Walking') return Icons.directions_walk_rounded;
    return Icons.fitness_center_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // ------------------------------------------------
          // 1. BACKGROUND GLOW DECORATION
          // ------------------------------------------------
          Positioned(
            top: -responsive.hp(15),
            right: -responsive.wp(20),
            child: Container(
              width: responsive.wp(80),
              height: responsive.wp(80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
              child: Column(
                children: [
                  SizedBox(height: responsive.hp(4)),

                  // 2. HEADER
                  _buildTopHeader(responsive),

                  const Spacer(),

                  // 3. CENTER TIMER CARD
                  _buildTimerDisplay(responsive),

                  const Spacer(),

                  // 4. CONTROLS
                  _buildControlButtons(responsive),

                  SizedBox(height: responsive.hp(6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(Responsive responsive) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.wp(5)),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Icon(
            _getIcon(),
            color: AppColors.primary,
            size: responsive.hp(4.5),
          ),
        ),
        SizedBox(height: responsive.hp(2)),
        Text(
          widget.workoutType.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.hp(2.8),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: responsive.hp(1)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(3), vertical: responsive.hp(0.5)),
          decoration: BoxDecoration(
            color: _isPaused
                ? Colors.redAccent.withValues(alpha: 0.2)
                : Colors.greenAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPaused ? Colors.redAccent : Colors.greenAccent,
              width: 1,
            ),
          ),
          child: Text(
            _isPaused ? "PAUSED" : "ACTIVE",
            style: TextStyle(
              color: _isPaused ? Colors.redAccent : Colors.greenAccent,
              fontSize: responsive.hp(1.4),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay(Responsive responsive) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final String hours = twoDigits(_elapsedTime.inHours);
    final String minutes = twoDigits(_elapsedTime.inMinutes.remainder(60));
    final String seconds = twoDigits(_elapsedTime.inSeconds.remainder(60));

    final double fontSize = responsive.hp(8.5);

    // Monospaced numbers prevent jittering when digits change
    final TextStyle digitStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: Colors.white,
    );

    final TextStyle separatorStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: Colors.white38,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.hp(4)),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            'DURATION',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: responsive.hp(1.6),
              letterSpacing: 3.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: responsive.hp(1)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours
                Text(hours,
                    style: digitStyle.copyWith(color: AppColors.primary)),
                Text(':', style: separatorStyle),
                // Minutes
                Text(minutes, style: digitStyle),
                Text(':', style: separatorStyle),
                // Seconds
                Text(seconds,
                    style: digitStyle.copyWith(color: AppColors.mutedOrange)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(Responsive responsive) {
    final double btnHeight = responsive.hp(7.5);
    final double btnWidth = responsive.wp(40);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Resume / Pause Button
        SizedBox(
          height: btnHeight,
          width: btnWidth,
          child: ElevatedButton(
            onPressed: _togglePause,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardSurface,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: AppColors.primary,
                  size: responsive.hp(3),
                ),
                SizedBox(width: responsive.wp(2)),
                Text(
                  _isPaused ? "Resume" : "Pause",
                  style: TextStyle(
                    fontSize: responsive.hp(2.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Finish Button
        SizedBox(
          height: btnHeight,
          width: btnWidth,
          child: ElevatedButton(
            onPressed: _onFinishPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop_rounded,
                    color: Colors.white, size: responsive.hp(3)),
                SizedBox(width: responsive.wp(2)),
                Text(
                  "Finish",
                  style: TextStyle(
                    fontSize: responsive.hp(2.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}