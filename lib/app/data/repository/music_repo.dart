import 'dart:developer';
import 'package:musicapp/app/data/model/artist.dart';
import 'package:musicapp/app/data/model/artist_album.dart';
import 'package:musicapp/app/data/model/track.dart';
import 'package:musicapp/app/data/services/network_service.dart';
import 'package:musicapp/app/data/utils/app_navigators.dart';
import 'package:musicapp/app/data/utils/music_storage.dart';
import 'package:musicapp/app/data/utils/shared_helpers.dart';
import 'package:dio/dio.dart';
import 'package:musicapp/app/modules/home/views/music_screen.dart';

class MusicRepo {
  static final _dio = NetworkService.initDio();

  static Future<void> generateToken() async {
    try {
      final options = BaseOptions(
        baseUrl: "https://accounts.spotify.com/api/",
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      final data = {
        "grant_type": "client_credentials",
        "client_id": "f2e888211f5a43cf9a0e8de013ed7ce5",
        "client_secret": "f0a2c596ad3440ef8e543f16111ff05d"
      };

      final response = await Dio(options).post("token", data: data);

      log("Token generation response: $response");

      await setSharedString(
        "spotifyToken",
        response.data['access_token'].toString(),
      );
      log("New token stored: ${response.data['access_token']}");
    } on DioException catch (e) {
      log('Error generating token: $e');
      log('Error response: ${e.response}');
    }
  }

  static Future<List<Artist>> getArtists() async {
    try {
      List<Artist> listArtist = [];
      List<String> list = [
        "6KImCVD70vtIoJWnq6nGn3",
        "66CXWjxzNUsdJxJ2JdwvnR",
        "0kPb52ySN2k9P6wEZPTUzm",
        "6Sv2jkzH9sWQjwghW5ArMG"
      ];

      for (var id in list) {
        log('Fetching related artists for ID: $id');
        final response = await _dio.get("artists/$id/related-artists");
        log('Response status code: ${response.statusCode}');
        log('Response data: ${response.data}');

        if (response.statusCode == 200) {
          List<Artist> artists = List.from(
            response.data['artists'].map((e) => Artist.fromJson(e)),
          );
          log('Number of related artists fetched: ${artists.length}');
          listArtist.addAll(artists.take(2));
        }
      }

      log('Total number of artists fetched: ${listArtist.length}');
      return listArtist;
    } catch (e) {
      log('Error in getArtists: $e');
      return [];
    }
  }

  static Future<List<Tracks>> getMultipleTopTrack(List<String> listId) async {
    try {
      List<Tracks> listTrack = [];

      for (var id in listId) {
        final response = await _dio.get("artists/$id/top-tracks?market=US");
        if (response.statusCode == 200) {
          List<Tracks> result = List.from(
            response.data['tracks'].map((e) => Tracks.fromJson(e)),
          );
          listTrack.addAll(result);  // Add all tracks, not just the first one
        }
      }

      return listTrack;
    } catch (e) {
      log('Error in getMultipleTopTrack: $e');
      return [];
    }
  }

  static Future<dynamic> searchTrack(String content) async {
    try {
      String query = content.replaceAll(" ", "+");
      log('Searching for tracks with query: $query');

      final response = await _dio.get("search?q=$query&type=track&limit=10");

      log("searchTrack response status: ${response.statusCode}");
      log("searchTrack response data: ${response.data}");

      if (response.statusCode == 200) {
        TracksResponse tracks = TracksResponse.fromJson(response.data['tracks']);
        log("Number of tracks found: ${tracks.items?.length ?? 0}");
        return [response.statusCode, tracks];
      } else {
        log("Unexpected status code: ${response.statusCode}");
        return [response.statusCode, null];
      }
    } on DioException catch (e) {
      log('Error in searchTrack: $e');
      log('Error response: ${e.response}');
      return [e.response?.statusCode ?? 500, null];
    }
  }


  static Future<List<Tracks>> getArtistTopTrack(String artistId) async {
    try {
      final response = await _dio.get("artists/$artistId/top-tracks?market=US");
      if (response.statusCode == 200) {
        List<Tracks> result = List.from(
          response.data['tracks'].map((e) => Tracks.fromJson(e)),
        );
        return result;
      } else {
        return [];
      }
    } catch (e) {
      log('Error in getArtistTopTrack: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getAlbumTrack(String albumId) async {
    try {
      final response = await _dio.get("albums/$albumId/tracks");
      if (response.statusCode == 200) {
        TracksResponse result = TracksResponse.fromJson(response.data);
        return [response.statusCode, result];
      } else {
        return [response.statusCode, null];
      }
    } catch (e) {
      log('Error in getAlbumTrack: $e');
      return [500, null];
    }
  }

  static Future<List<Albums>> getArtistAlbums([String? s]) async {
    try {
      List<Albums> allAlbums = [];
      final artists = await getArtists();

      for (var artist in artists) {
        if (artist.id != null) {
          final response = await _dio.get("artists/${artist.id}/albums?limit=5&include_groups=album,single");
          if (response.statusCode == 200) {
            ArtistAlbumResponse albumResponse = ArtistAlbumResponse.fromJson(response.data);
            if (albumResponse.items != null) {
              allAlbums.addAll(albumResponse.items!);
            }
          }
        }
      }

      // Sort albums by release date, most recent first
      allAlbums.sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));

      // Take the top 10 most recent albums
      return allAlbums.take(10).toList();
    } catch (e) {
      log('Error in getArtistAlbums: $e');
      return [];
    }
  }
  static Future<dynamic> getAvailableGenre() async {
    try {
      final response = await _dio.get("recommendations/available-genre-seeds");

      log("getAvailableGenre: $response");

      List<String> genres = response.data['genres'].cast<String>();

      return [response.statusCode, genres];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }
}
