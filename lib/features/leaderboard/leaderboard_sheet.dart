import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict/core/services/future_services.dart';
import 'package:verdict/core/services/service_providers.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict_engine/verdict_engine.dart';

class LeaderboardSheet extends ConsumerStatefulWidget {
  const LeaderboardSheet({required this.game, super.key});

  final GameViewState game;

  @override
  ConsumerState<LeaderboardSheet> createState() => _LeaderboardSheetState();
}

class _LeaderboardSheetState extends ConsumerState<LeaderboardSheet> {
  List<LeaderboardEntry> _entries = const [];
  bool _loading = true;
  bool _submitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!ref.read(onlineServicesEnabledProvider)) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final entries = await ref
          .read(leaderboardRepositoryProvider)
          .topScores(GameMode.classic);
      if (mounted) {
        setState(() {
          _entries = entries;
          _loading = false;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = _friendlyError(error);
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitScore() async {
    setState(() {
      _submitting = true;
      _message = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInAnonymously();
      var username = await auth.currentUsername();
      if (username == null) {
        if (!mounted) return;
        username = await _requestUsername();
        if (username == null) return;
        if (!RegExp(r'^[A-Za-z0-9_]{3,20}$').hasMatch(username)) {
          throw const FormatException(
            'Use 3-20 letters, numbers, or underscores.',
          );
        }
        await auth.claimUsername(username);
      }

      final score = await ref
          .read(leaderboardRepositoryProvider)
          .submitAttempt(
            VerifiedAttempt(
              puzzleId: widget.game.session.puzzleId,
              mode: widget.game.session.config.mode,
              guesses: widget.game.session.guesses,
              startedAt: widget.game.puzzle.utcDate,
              completedAt: DateTime.now().toUtc(),
            ),
          );
      if (mounted) {
        setState(() => _message = 'Score posted: $score');
        await _refresh();
      }
    } on Object catch (error) {
      if (mounted) setState(() => _message = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _requestUsername() {
    var username = '';
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: BrutalBox(
            color: VerdictPalette.yellow,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'CLAIM YOUR NAME',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  maxLength: 20,
                  scrollPadding: const EdgeInsets.all(80),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'masked_player',
                    filled: true,
                    fillColor: VerdictPalette.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: VerdictPalette.ink,
                        width: 3,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: VerdictPalette.ink,
                        width: 3,
                      ),
                    ),
                  ),
                  onChanged: (value) => username = value.trim(),
                  onSubmitted: (value) => Navigator.pop(context, value.trim()),
                ),
                const SizedBox(height: 8),
                BrutalButton(
                  label: 'CLAIM',
                  onPressed: () => Navigator.pop(context, username),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(onlineServicesEnabledProvider);
    final canSubmit = widget.game.session.status == GameStatus.won;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 21, 20),
        child: BrutalBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'GLOBAL BOARD',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close leaderboard',
                    ),
                  ],
                ),
                const Text(
                  'CLASSIC · ALL-TIME SCORE',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                if (!enabled)
                  const _EmptyBoard(
                    icon: Icons.cloud_off,
                    text: 'The global board is not connected in this build.',
                  )
                else if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_entries.isEmpty)
                  const _EmptyBoard(
                    icon: Icons.emoji_events_outlined,
                    text: 'No verdicts posted yet. Take the first spot.',
                  )
                else
                  for (var index = 0; index < _entries.length; index++)
                    _LeaderboardRow(rank: index + 1, entry: _entries[index]),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
                if (enabled && canSubmit) ...[
                  const SizedBox(height: 16),
                  BrutalButton(
                    label: _submitting ? 'POSTING...' : 'POST TODAY\'S SCORE',
                    icon: Icons.publish,
                    color: VerdictPalette.green,
                    onPressed: _submitting ? () {} : _submitScore,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is FormatException) return error.message;
    return 'The board could not complete that request. Try again.';
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.rank, required this.entry});

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: rank == 1 ? VerdictPalette.yellow : VerdictPalette.white,
      border: Border.all(color: VerdictPalette.ink, width: 2.5),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '#$rank',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: Text(
            entry.username,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          width: 60,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${entry.score}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Icon(icon, size: 42),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
