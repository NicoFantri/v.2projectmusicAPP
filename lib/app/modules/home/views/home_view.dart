import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicapp/app/data/model/artist.dart';
import 'package:musicapp/app/data/model/artist_album.dart';
import 'package:musicapp/app/data/model/track.dart';
import 'package:musicapp/app/data/repository/music_repo.dart';
import '../controllers/home_controller.dart';
import 'drawer_menu.dart';
import 'search_results_view.dart';
import 'playerview.dart';
import 'music_screen.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            _buildSearchBar(),
            _buildArtistSection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        '',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // Navigate to ProfileView (implementation to be added)
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Hello nico',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'What do you want to hear today?',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for tracks',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      Get.to(() => SearchResultsView(searchQuery: query));
    }
  }

  Widget _buildArtistSection() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        MusicRepo.getArtists(), // Future to get artists
        MusicRepo.getArtistAlbums(), // Future to get albums
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No artists or albums found'));
        }

        // snapshot.data![0] contains the list of artists
        // snapshot.data![1] contains the list of albums
        final artists = snapshot.data![0] as List<Artist>;
        final albums = snapshot.data![1] as List<Albums>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrendingMusicSection(albums), // Passing albums to the trending section
            _buildTabSection(artists), // Passing artists to the tab section
          ],
        );
      },
    );
  }


  Widget _buildTrendingMusicSection(List<Albums> albums) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Music Trending',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Show more',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: albums.map((album) => _buildAlbumBox(album)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumBox(Albums album) {
    return GestureDetector(
      onTap: () async {
        // Fetch the artist for this album
        Artist? artist = await _getArtistForAlbum(album);
        if (artist != null) {
          Get.to(() => MusicScreen(artist: artist));
        }
      },
      child: Container(
        width: 150, // Mengatur ukuran tetap untuk tiap item album
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                album.images?.firstOrNull?.url ?? 'https://via.placeholder.com/150',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name ?? 'Unknown Album',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artists?.firstOrNull?.name ?? 'Unknown Artist',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<Artist?> _getArtistForAlbum(Albums album) async {
    if (album.artists?.isNotEmpty ?? false) {
      String artistId = album.artists!.first.id!;
      List<Artist> artists = await MusicRepo.getArtists();
      return artists.firstWhereOrNull((artist) => artist.id == artistId);
    }
    return null;
  }



  Widget _buildTabSection(List<Artist> artists) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Recently'),
              Tab(text: 'Popular'),
              Tab(text: 'Similar'),
              Tab(text: 'Trending'),
            ],
            isScrollable: false,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: TabBarView(
              children: List.generate(4, (index) => _buildSongList(artists)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(List<Artist> artists) {
    return FutureBuilder<List<Tracks>>(
      future: MusicRepo.getMultipleTopTrack(
          artists.map((e) => e.id!).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tracks found'));
        }

        final tracks = snapshot.data!;
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _buildSongItem(
              track.album?.images?.first.url ?? 'https://via.placeholder.com/50',
              track.name ?? 'Unknown',
              track.artists?.map((a) => a.name).join(', ') ?? 'Unknown Artist',
              '${track.durationMs ?? 0 ~/ 60000}:${(track.durationMs ?? 0 % 60000 ~/ 1000).toString().padLeft(2, '0')}',
              track.previewUrl,
            );
          },
        );
      },
    );
  }

  Widget _buildSongItem(String imageUrl, String title, String artist, String duration, String? previewUrl) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PlayerView(
          title: title,
          artist: artist,
          imageUrl: imageUrl,
          previewUrl: previewUrl,
        ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artist,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                Text(
                  duration,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          imageUrl ?? 'https://via.placeholder.com/150',
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}