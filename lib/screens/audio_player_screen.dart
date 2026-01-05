import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web; // Modern web DOM APIs
import 'package:neurorga/models/raga.dart';
import 'package:neurorga/screens/mood_tracker_screen.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Raga raga;
  final String emotion;

  const AudioPlayerScreen({super.key, required this.raga, required this.emotion});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // We no longer use YouTube. Only open user-provided Spotify links.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raga.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.raga.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        Text(
                          widget.raga.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.95)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _hasValidSpotifyUrl ? _openOnSpotify : null,
                    icon: const Icon(Icons.graphic_eq, color: Colors.white),
                    label: Text(
                      _hasValidSpotifyUrl
                          ? 'Open Playlist'
                          : (widget.raga.spotifyUrl.trim().isEmpty ? 'Playlist link not set yet' : 'Invalid playlist link'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.science, color: Theme.of(context).colorScheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Neuroscience Insight',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.raga.neuroscienceDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoodTrackerScreen(
                          raga: widget.raga,
                          emotion: widget.emotion,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Rate Your Experience'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ==== Spotify helpers (the only source now) ====
  String _spotifyQuery() => '${widget.raga.name} Carnatic raga';

  Uri _buildSpotifyAppSearchUri() => Uri.parse('spotify://search?q=${Uri.encodeComponent(_spotifyQuery())}');

  Uri _buildSpotifyWebSearchUri() => Uri.parse('https://open.spotify.com/search/${Uri.encodeComponent(_spotifyQuery())}');

  /// Normalize a provided Spotify URL or deep link to a usable web URL.
  /// Supports: open.spotify.com/*, spotify:playlist:ID, spotify:album:ID, spotify:track:ID
  Uri? _normalizeSpotifyUrl(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final t = raw.trim();
      // Handle deep link forms
      if (t.startsWith('spotify:')) {
        final parts = t.split(':');
        if (parts.length >= 3) {
          final type = parts[1];
          final id = parts[2];
          return Uri.parse('https://open.spotify.com/$type/$id');
        }
      }
      // Ensure scheme
      final withScheme = t.startsWith('http') ? t : 'https://$t';
      final uri = Uri.parse(withScheme);
      if (uri.host.contains('open.spotify.com')) return uri;
      // If not a spotify domain, treat as invalid and fall back
      return null;
    } catch (e) {
      debugPrint('Failed to normalize Spotify URL: $e');
      return null;
    }
  }

  /// Return the preferred Spotify URL for this raga: a provided playlist/url if set, else a search URL.
  Uri _buildSpotifyPreferredWebUri() {
    final normalized = _normalizeSpotifyUrl(widget.raga.spotifyUrl);
    return normalized ?? _buildSpotifyWebSearchUri();
  }

  bool get _hasValidSpotifyUrl {
    final normalized = _normalizeSpotifyUrl(widget.raga.spotifyUrl);
    return normalized != null;
  }

  /// If we have a deep link original form (spotify:*), return it for app launch; else null.
  Uri? _deepLinkFromOriginal() {
    final t = widget.raga.spotifyUrl.trim();
    if (t.startsWith('spotify:')) {
      try {
        return Uri.parse(t);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _openOnSpotify() async {
    final webUri = _buildSpotifyPreferredWebUri();
    final deepLink = _deepLinkFromOriginal();
    try {
      debugPrint('AudioPlayerScreen: opening Spotify. DeepLink: ${deepLink?.toString() ?? 'none'}, Web: $webUri');
      if (kIsWeb) {
        try {
          web.window.open(webUri.toString(), '_blank');
          return;
        } catch (e) {
          debugPrint('Spotify window.open failed: $e');
        }
      }
      // On mobile: try deep link first if available
      bool launched = false;
      if (deepLink != null) {
        try {
          launched = await launchUrl(deepLink, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Spotify deep link launch failed: $e');
        }
      }
      if (!launched) {
        final ok = await launchUrl(webUri, mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Spotify. Link copied.')));
          }
          await _copySpotifyLink();
        }
      }
    } catch (e) {
      debugPrint('Error opening Spotify: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening failed. You can paste the copied link: ${webUri.toString()}')));
      }
      await _copySpotifyLink();
    }
  }

  Future<void> _copySpotifyLink() async {
    try {
      final url = _buildSpotifyPreferredWebUri().toString();
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Spotify link copied. Paste in a new tab.')));
      }
    } catch (e) {
      debugPrint('Copy Spotify link failed: $e');
    }
  }
}
