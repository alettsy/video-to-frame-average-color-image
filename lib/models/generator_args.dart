class ImageGeneratorArgs {
  final String path;
  final int interval;
  final int pixelWidth;
  final int height;

  ImageGeneratorArgs({
    required this.path,
    required this.interval,
    required this.pixelWidth,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'interval': interval,
      'pixelWidth': pixelWidth,
      'height': height,
    };
  }

  factory ImageGeneratorArgs.fromJson(Map<String, dynamic> json) {
    return ImageGeneratorArgs(
      path: json['path'],
      interval: json['interval'],
      pixelWidth: json['pixelWidth'],
      height: json['height'],
    );
  }
}
