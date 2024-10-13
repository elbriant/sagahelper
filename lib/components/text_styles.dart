import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

Map<String, StyledTextTagBase> tagsAsHtml = {
  'b' : StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
  'i' : StyledTextTag(style: TextStyle(fontStyle: FontStyle.italic))
};

Map<String, StyledTextTagBase> tagsAsArknights = {
  'b' : StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
  'i' : StyledTextTag(style: TextStyle(fontStyle: FontStyle.italic))
};