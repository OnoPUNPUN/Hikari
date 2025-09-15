import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/reading_mode.dart';
import '../../../core/providers/reading_mode_provider.dart';
import '../../../core/providers/api_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  final Manga manga;

  const ReaderScreen({super.key, required this.chapter, required this.manga});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadChapterImages();
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterImages() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getChapterImages(widget.chapter.id);
      setState(() {
        _imageUrls = response.imageUrls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final readingMode = ref.watch(readingModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _buildErrorWidget()
          else
            _buildReader(readingMode),
          if (_showControls) _buildControls(readingMode),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Failed to load chapter images',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadChapterImages,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReader(ReadingMode readingMode) {
    return GestureDetector(
      onTap: _toggleControls,
      child: readingMode == ReadingMode.classic
          ? _buildClassicReader()
          : _buildWebtoonReader(),
    );
  }

  Widget _buildClassicReader() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: CachedNetworkImage(
              imageUrl: _imageUrls[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error, color: Colors.white, size: 48),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebtoonReader() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 2),
          child: CachedNetworkImage(
            imageUrl: _imageUrls[index],
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => Container(
              height: 400,
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 400,
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.error, color: Colors.white, size: 48),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(ReadingMode readingMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopControls(),
            const Spacer(),
            if (readingMode == ReadingMode.classic) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.manga.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.chapter.displayTitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildReadingModeButton(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
                : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: Text(
              '${_currentPage + 1} / ${_imageUrls.length}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _currentPage < _imageUrls.length - 1
                ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
                : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingModeButton() {
    return PopupMenuButton<ReadingMode>(
      icon: const Icon(Icons.view_module, color: Colors.white),
      onSelected: (mode) {
        ref.read(readingModeProvider.notifier).setReadingMode(mode);
      },
      itemBuilder: (context) => ReadingMode.values.map((mode) {
        return PopupMenuItem(
          value: mode,
          child: Row(
            children: [
              Icon(
                mode == ReadingMode.classic
                    ? Icons.view_module
                    : Icons.view_stream,
                color: ref.watch(readingModeProvider) == mode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              Text(mode.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }
}
