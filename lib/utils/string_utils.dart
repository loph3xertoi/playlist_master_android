class StringUtils{
  /// Extract raw title of bili resource with <em> tag to its final title.
  static String extractWholeName(String rawName){
    RegExp htmlTagsRegex = RegExp(r'<[^>]*>');
    return rawName.replaceAll(htmlTagsRegex, '');
  } 
}