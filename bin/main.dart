import 'dart:io';

import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main(List<String> arguments) async {
  printDefault('Lendo o arquivo videos.txt');
  final file = File('./bin/videos.txt');

  final videos = await file.readAsLines();

  printDefault('Encontrados ${videos.length} videos');

  var count = 1;

  for (var video in videos) {
    printWarning('Progresso: $count/${videos.length}');
    await downloadMp3(video);
    count++;
  }
  print('Finalizando');
}

Future<void> downloadMp3(String link) async {
  final videoId = getLinkId(link);
  var yt = YoutubeExplode();
  var dio = Dio();

  var video = await yt.videos.get(link);

  printDefault('Coletando dados do "${video.title}"');

  var manifest = await yt.videos.streamsClient.getManifest(videoId);

  var url = manifest?.audioOnly?.first?.url?.toString() ?? '';
  if (url.isNotEmpty) {
    printWarning('Iniciando o download do "${video.title}"');
    final filePath = './bin/mp3/' + video.title + '.mp3';
    if (File(filePath).existsSync()) {
      printError('Video -> ${video.title} já foi baixado!');
    } else {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (count, total) {
          //print('$count / $total');
        },
      );
      printSucess(video.title + ' - Baixado com sucesso!');
    }
  } else {
    printError('${video.title} não foi encontrado');
    printError(link);
  }

  printWarning(
      '================================================================================================================================');
  printWarning(
      '================================================================================================================================');
  printWarning(
      '================================================================================================================================');
}

String getLinkId(String link) => link.replaceAll('https://youtu.be/', '');

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

void printDefault(String text) {
  print('\x1B[35m$text\x1B[0m');
}

void printSucess(String text) {
  print('\x1B[32m$text\x1B[0m');
}