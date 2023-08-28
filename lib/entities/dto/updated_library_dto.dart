import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// DTO for updated library.
@immutable
class UpdatedLibraryDTO {
  UpdatedLibraryDTO(this.id, this.name, this.intro, this.cover);

  final int id;
  final String name;
  final String? intro;
  final http.MultipartFile? cover;
}
