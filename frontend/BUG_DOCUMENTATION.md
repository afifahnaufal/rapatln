# DOKUMENTASI BUG TESTING
## Aplikasi RapatLN - Task Besar Pemrograman 4

---

## BUG #1: Upload Foto Profil Error - MissingPluginException

### Steps:
1. Login sebagai pengguna yang sudah terdaftar
2. Masuk ke halaman Edit Profil
3. Klik tombol kamera untuk memilih foto dari galeri
4. Pilih foto dari galeri perangkat
5. Klik tombol SIMPAN untuk menyimpan perubahan profil

### Expected Result:
Foto profil berhasil diupload ke server dan tersimpan. Pengguna kembali ke halaman profil dengan foto baru ditampilkan.

### Actual Result:
Muncul error message: **"Gagal menyimpan profil: MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)"**

Foto tidak tersimpan dan pengguna tetap di halaman Edit Profil.

### Gambar:
[Screenshot error akan ditambahkan user]

### Analysis:
Bug terjadi karena ada dua masalah:
1. Plugin `path_provider` tidak ter-implementasi dengan benar pada platform yang digunakan
2. Kode mencoba menyalin file ke `getApplicationDocumentsDirectory()` yang membutuhkan plugin tersebut
3. Cara membuat `FormData.fromMap()` tidak sesuai untuk multipart file upload

### Penyebab (Kode):

**File: lib/pages/edit_profile_page.dart**
```dart
// ❌ BUG: getApplicationDocumentsDirectory() memerlukan path_provider plugin
final appDir = await getApplicationDocumentsDirectory();

final fileName = p.basename(image.path);
final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
// ❌ BUG: Operasi copy file yang tidak perlu dan tidak perlu disimpan dulu
final savedImage = await File(image.path).copy('${appDir.path}/$uniqueName');
```

**File: lib/services/user_service.dart**
```dart
// ❌ BUG: FormData.fromMap() tidak cocok untuk multipart files
final formData = FormData.fromMap({
  'id': user.id,
  'name': user.name,
  'position': user.position,
  'bio': user.bio,
  'profileImage': await MultipartFile.fromFile(
    file.path,
    filename: user.profileImagePath!.split('/').last,  // ❌ Path separator issue di Windows
  ),
});
```

### Solusi:
1. Hapus dependency `path_provider` dan `getApplicationDocumentsDirectory()`
2. Gunakan path langsung dari image picker tanpa perlu copy file
3. Build FormData dengan cara yang benar (add fields dan files terpisah)
4. Gunakan `Platform.pathSeparator` untuk extract filename agar kompatibel dengan semua platform

---

## BUG #2: Login dengan Password Terlalu Pendek (Security Issue)

### Steps:
1. Buka halaman Login
2. Masukkan Username: `testuser` (atau username yang terdaftar)
3. Masukkan Password: `a` (hanya 1 karakter)
4. Klik tombol LOGIN
5. Amati apakah ada validasi password length

### Expected Result:
Sistem menampilkan error message: **"Password minimal harus 6 karakter"**
Login ditolak dan pengguna tetap di halaman login.

### Actual Result:
❌ **Tidak ada validasi password length**
Sistem mencoba melakukan login langsung dengan password 1 karakter.
Hasilnya akan gagal di server (karena server menolak), bukan di aplikasi.

### Gambar:
[Screenshot login form dengan password 1 karakter akan ditambahkan user]

### Analysis:
Bug terjadi karena **tidak ada validasi minimum password length di aplikasi**.
Standar keamanan meminimalkan password harus 6-8 karakter, tapi aplikasi tidak melakukan check ini.
Seharusnya error ditangani di client-side, bukan mengandalkan server untuk reject-nya.

### Penyebab (Kode):

**File: lib/pages/login_page.dart**
```dart
Future<void> _login() async {
  // ❌ BUG: Hanya cek apakah field kosong, tidak cek panjang password minimum
  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username dan Password harus diisi')),
    );
    return;
  }
  // ❌ BUG: Langsung kirim ke server tanpa validasi password length
  // Seharusnya ada check: if (_passwordController.text.length < 6)

  await _userService.login(
    _usernameController.text,
    _passwordController.text,  // ❌ Password "a" atau "12345" dikirim langsung
  );
}
```

### Solusi:
Tambahkan validasi password length:
```dart
if (_passwordController.text.length < 6) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Password minimal 6 karakter')),
  );
  return;
}
```

---

## BUG #3: Register dengan Input Spasi - Data Tidak Konsisten

### Steps:
1. Buka halaman Register
2. Masukkan Username: `  testuser  ` (dengan 2 spasi di depan dan belakang)
3. Masukkan Password: `  password123  ` (dengan spasi)
4. Masukkan Nama: `Test User`
5. Klik tombol DAFTAR
6. Setelah registrasi berhasil, coba login dengan username `testuser` (tanpa spasi)
7. Amati apakah login gagal karena username tidak cocok

### Expected Result:
Sistem otomatis menghilangkan spasi di awal dan akhir (trim).
Username yang tersimpan: `testuser` (tanpa spasi)
User bisa login dengan username `testuser`

### Actual Result:
❌ **Spasi tidak dihilangkan**
Username yang tersimpan: `  testuser  ` (dengan spasi)
Jika user login dengan `testuser` (tanpa spasi) → LOGIN GAGAL
Pesan error: "Login Gagal! Akun tidak ditemukan"

### Gambar:
[Screenshot register form dengan username spasi akan ditambahkan user]
[Screenshot error login yang muncul akan ditambahkan user]

### Analysis:
Bug terjadi karena **tidak ada input trimming (trim()) pada TextField**
User input yang mempunyai spasi di awal/akhir akan tersimpan apa adanya di database.
Ini menyebabkan data tidak konsisten dan susah login kemudian jika user lupa pernah input dengan spasi.

### Penyebab (Kode):

**File: lib/pages/register_page.dart**
```dart
try {
  // ❌ BUG: Tidak ada trim() pada input field
  // Jika user input "  testuser  " akan disimpan dengan spasi
  await _userService.register(
    _usernameController.text,              // ❌ "  testuser  " 
    _passwordController.text,              // ❌ "  password123  "
    _nameController.text,
  );
}
```

### Solusi:
Gunakan `.trim()` untuk menghilangkan spasi:
```dart
await _userService.register(
  _usernameController.text.trim(),      // Spasi dihilangkan
  _passwordController.text.trim(),      // Spasi dihilangkan
  _nameController.text.trim(),
);
```

---

## SUMMARY TABEL

| No | Bug | File | Baris | Fitur | Severity | Category |
|----|-----|------|-------|-------|----------|----------|
| 1 | Upload Foto Error | edit_profile_page.dart, user_service.dart | 45-65, 74-110 | Edit Profil | CRITICAL | Runtime Error |
| 2 | Password 1 Karakter | login_page.dart | 18-35 | Login | HIGH | Security Issue |
| 3 | Input Spasi Disimpan | register_page.dart | 20-40 | Register | MEDIUM | Data Consistency |

---

**Catatan:** Semua bug ini adalah bug pembelajaran untuk keperluan tugas besar. Di production, semua validasi dan error handling harus proper.

