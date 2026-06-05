import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    /// 🔥 CORES PRINCIPAIS
    primaryColor: const Color(0xFFFFB300),

    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    /// 🔥 REMOVE ROXO DEFINITIVO
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFFB300),
      secondary: Color(0xFFFFB300),
      surface: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),

    /// 🔥 APPBAR
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    /// 🔥 BOTÕES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB300),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    /// 🔥 INPUTS (SEM ROXO)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFFFB300), // 🔥 AMARELO
          width: 2,
        ),
      ),

      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.grey),
    ),

    /// 🔥 TEXTBUTTON (ESQUECEU SENHA)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFB300)),
    ),
  );
}
