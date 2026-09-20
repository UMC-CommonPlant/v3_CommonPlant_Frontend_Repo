import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';

Map<String, Object?> weatherResponse(WeatherRequest request) {
  final isObservation = request.product == WeatherProduct.observation;
  final values = isObservation
      ? {'T1H': '23.5', 'REH': '65', 'PTY': '0'}
      : {'SKY': '3', 'POP': '20'};
  final target = request.baseAt.add(
    const Duration(hours: 9, minutes: 30),
  ); // KST의 다음 정시
  final date = '${target.year}${_two(target.month)}${_two(target.day)}';
  final items = [
    for (final entry in values.entries)
      <String, Object?>{
        'baseDate': request.baseDate,
        'baseTime': request.baseTime,
        'nx': request.grid.nx,
        'ny': request.grid.ny,
        'category': entry.key,
        if (isObservation) 'obsrValue': entry.value,
        if (!isObservation) ...{
          'fcstDate': date,
          'fcstTime': '${_two(target.hour)}00',
          'fcstValue': entry.value,
        },
      },
  ];
  return {
    'response': {
      'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
      'body': {
        'pageNo': 1,
        'numOfRows': 1000,
        'totalCount': items.length,
        'items': {'item': items},
      },
    },
  };
}

List<Map<String, Object?>> weatherItems(Map<String, Object?> data) {
  final response = data['response']! as Map;
  final body = response['body'] as Map;
  return (body['items'] as Map)['item'] as List<Map<String, Object?>>;
}

String _two(int value) => value.toString().padLeft(2, '0');
