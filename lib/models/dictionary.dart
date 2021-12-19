import 'package:localstore/localstore.dart';
class Dictionary {
  final String id;
  String word;
  // ignore: non_constant_identifier_names
  String pronunciation_uk;
  // ignore: non_constant_identifier_names
  String pronunciation_us;
  String definition;
  String form;
  String similar;
  String speciality;
  // ignore: non_constant_identifier_names
  Dictionary({this.id, this.word, this.form, this.pronunciation_uk, this.pronunciation_us, this.definition,this.similar, this.speciality});
    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'form' : form,
      'pronunciation_uk': pronunciation_uk,
      'pronunciation_us': pronunciation_us,
      'definition': definition,
      'similar' : similar,
      'speciality' : speciality
    };
  }

  factory Dictionary.fromMap(Map<String, dynamic> map) {
    return Dictionary(
      id: map['id'],
      word: map['word'],
      form : map['form'],
      pronunciation_uk: map['pronunciation_uk'],
      pronunciation_us: map['pronunciation_us'],
      definition: map['definition'],
      similar : map['similar'],
      speciality : map['speciality']
    );
  }
}
extension ExtCheck on Dictionary {
  Future save() async {
    final _db = Localstore.instance;
    return _db.collection('dictionaries').doc(id).set(toMap());
  }
}