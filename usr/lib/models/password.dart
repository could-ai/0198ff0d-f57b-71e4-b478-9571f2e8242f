import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class Password {
  int? id;
  String title;
  String username;
  String password;
  String? notes;

  Password({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': _encrypt(password),
      'notes': notes,
    };
  }

  static Password fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: _decrypt(map['password']),
      notes: map['notes'],
    );
  }

  // Simple encryption key (in production, use a secure key management)
  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final iv = encrypt.IV.fromLength(16);

  static String _encrypt(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  static String _decrypt(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}