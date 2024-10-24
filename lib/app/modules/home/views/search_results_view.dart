import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicapp/app/data/model/track.dart';
import 'package:musicapp/app/data/repository/music_repo.dart';
import 'playerview.dart';

class SearchResultsView extends StatefulWidget {
  final String searchQuery;

  const SearchResultsView({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _SearchResultsViewState createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  List<Tracks> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() async {
    final result = await MusicRepo.searchTrack(widget.searchQuery);
    setState(() {
      if (result[0] == 200 && result[1] is TracksResponse) {
        _searchResults = result[1].items ?? [];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results: ${widget.searchQuery}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
          ? const Center(child: Text('No results found'))
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final track = _searchResults[index];
          return _buildTrackItem(track);
        },
      ),
    );
  }

  Widget _buildTrackItem(Tracks track) {
    return ListTile(
      leading: track.album?.images?.isNotEmpty ?? false
          ? Image.network(
        track.album!.images!.first.url!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      )
          : Icon(Icons.music_note),
      title: Text(track.name ?? 'Unknown Track'),
      subtitle: Text(track.artists?.map((a) => a.name).join(', ') ?? 'Unknown Artist'),
      onTap: () {
        Get.to(() => PlayerView(
          title: track.name ?? 'Unknown Track',
          artist: track.artists?.map((a) => a.name).join(', ') ?? 'Unknown Artist',
          imageUrl: track.album?.images?.first.url ?? '',
          previewUrl: track.previewUrl,
        ));
      },
    );
  }
}