import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ytrendd/http_client.dart';
import 'package:ytrendd/models/country.dart';
import 'package:ytrendd/models/youtube_video_data.dart';
import 'package:ytrendd/models/youtube_videos_response.dart';
import 'package:ytrendd/widgets/youtube_card.dart';
import 'package:ytrendd/.env.dart';

class YoutubeVideosList extends StatefulWidget {
  final Country country;

  YoutubeVideosList({Key key, this.country}) : super(key: key);

  @override
  _YoutubeVideosListState createState() => _YoutubeVideosListState();
}

class _YoutubeVideosListState extends State<YoutubeVideosList> {
  ScrollController _scrollController = ScrollController();
  List<YoutubeVideoData> videos = List<YoutubeVideoData>();
  String nextPageToken = "";

  void fetchYoutubeTrendVideos(Country country) async {
    final String regionCode = country.code;
    final int maxResults = 50;

    final String url =
        'https://www.googleapis.com/youtube/v3/videos?part=snippet%2Cstatistics&chart=mostPopular&regionCode=$regionCode&pageToken=$nextPageToken&maxResults=$maxResults&key=$youtubeApiKey';

    try {
      Response response = await dio.get(url);

      final parsedYoutubeResponse =
          YoutubeVideosResponse.fromJson(response.data);

      final newVideos = parsedYoutubeResponse.items;

      setState(() {
        nextPageToken = parsedYoutubeResponse.nextPageToken;
        videos?.addAll(newVideos);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    fetchYoutubeTrendVideos(widget.country);
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (nextPageToken == null) return;
        fetchYoutubeTrendVideos(widget.country);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return YoutubeCard(video: videos[index], index: index);
        });
  }
}
