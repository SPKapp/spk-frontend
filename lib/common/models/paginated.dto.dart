final class Paginated<T> {
  const Paginated({
    required this.data,
    this.offset,
    this.limit,
    this.totalCount,
  });

  final List<T> data;
  final int? offset;
  final int? limit;
  final int? totalCount;

  static Paginated<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return Paginated<T>(
      data: (json['data'] as List).map((json) => fromJson(json)).toList(),
      offset: json['offset'],
      limit: json['limit'],
      totalCount: json['totalCount'],
    );
  }
}
