import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/track.dart';
import '../models/localTrackModel.dart';
import '../database/localTracks.dart';
import '../models/properties.dart';
import '../models/sensor.dart';
import '../exceptionHandling/result.dart';
import 'authProvider.dart';
import '../models/pointProperties.dart';
import '../services/tracksServices.dart';
import '../utils/snackBar.dart';

class LocalTracksProvider extends ChangeNotifier {
  List<Track> _tracksList;

  factory LocalTracksProvider() => _localTracksProvider;

  LocalTracksProvider._() {
    _tracksList = [];
    setLocalTracks();
  }

  static final LocalTracksProvider _localTracksProvider = LocalTracksProvider._();

  void setLocalTracks() {
    final list = LocalTracks.getLocalTracks();
    for (var i = 0; i < list.length; i++) {
      final Track track = encodeToTrack(list[i]);
      _tracksList.add(track);
      notifyListeners();
    }
  }

  Track encodeToTrack(LocalTrackModel trackData) {
    final Track track = Track();
    track.id = trackData.getTrackId;
    track.length = trackData.getDistance;
    track.begin = trackData.getStartTime;
    track.end = trackData.getEndTime;

    final Sensor sensor = Sensor();

    sensor.type = "car";
    // todo: change the hardcoded values
    sensor.properties = Properties(
      engineDisplacement: 2500,
      model: 'V50 2004',
      id: trackData.getCarId,
      fuelType: 'gasoline',
      constructionYear: 2004,
      manufacturer: 'Volvo'
    );

    track.sensor = sensor;

    return track;
  }

  void addLocalTrack(LocalTrackModel localTrackModel) {
    LocalTracks.saveTrack(localTrackModel);
    final Track track = encodeToTrack(localTrackModel);
    _tracksList.add(track);
    notifyListeners();
  }

  /// function to delete [track]
  void deleteLocalTrack(Track track, int index) {
    _tracksList.removeWhere((Track trackItem) => track.id == trackItem.id);
    LocalTracks.deleteTrack(index);
    notifyListeners();
  }

  // void decodeTrack(Map<String, dynamic> localTrackData) {
  //   DatabaseHelper.instance.insertValue(tableName: TracksTable.tableName, data: localTrackData);
  // }

  List<Track> get getLocalTracks {
    return [..._tracksList];
  }

  void uploadTrack(BuildContext context, int index) {
    final AuthProvider _authProvider = Provider.of<AuthProvider>(context, listen: false);
    final LocalTrackModel localTrackModel = LocalTracks.getTrackAtIndex(index);
    TracksServices().postTrack(authProvider: _authProvider, localTrackModel: localTrackModel).then((Result result) {
      if (result.status == ResultStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              result.exception.getErrorMessage(),
            ),
          ),
        );
      }
      else if (result.status == ResultStatus.success) {
        displaySnackBar('${localTrackModel.getTrackName} uploaded successfully!');
      }
    });
  }

  /// function to export the track data as csv
  Future exportTrack(int index) async {
    final LocalTrackModel localTrackModel = LocalTracks.getTrackAtIndex(index);
    final List<PointProperties> properties = localTrackModel.getProperties.values.toList();

    // final applicationDocumentsDirectory = await path_provider.getApplicationDocumentsDirectory();

    final List<List<dynamic>> data = [];
    final List<dynamic> dataRow = [];

    dataRow.add("Latitude");
    dataRow.add("Longitude");
    dataRow.add("Altitude");

    data.add(dataRow);

    for (int i = 0; i < properties.length; i++) {
      final List<dynamic> dataRow = [];
      dataRow.add(properties[i].latitude);
      dataRow.add(properties[i].longitude);
      dataRow.add(properties[i].altitude);

      data.add(dataRow);
    }

    // todo: export the converted file and store it in external storage

    final String trackDataCsv = const ListToCsvConverter().convert(data);
    // final File file = File("${applicationDocumentsDirectory.path}/${localTrackModel.getTrackName}.csv");
    // file.writeAsString(trackDataCsv);

  }

}