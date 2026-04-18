📌 Dokumentasi Widget & Validasi - RapatIn

Dokumen ini menjelaskan struktur utama widget, file penting, serta sistem validasi yang ada di aplikasi RapatIn. Tujuannya biar developer (termasuk kamu yang baru join 😄) bisa cepat paham alur dan struktur project ini.

🎨 1. Theme & Tampilan
app_theme.dart

Di sini semua styling utama aplikasi dikumpulin.

Isinya:

Warna utama (Maroon)
Style TextField (border agak bulat)
Style tombol dan komponen UI lainnya

Kenapa penting?

Biar tampilan konsisten
Gak perlu nulis style berulang-ulang
Kalau mau ubah desain, cukup di sini aja
🔐 2. Halaman Login & Register
login_page.dart

Komponen:

Input Username
Input Password
Tombol Login

Validasi:

Username & password wajib diisi
Kalau kosong → muncul SnackBar:
"Username dan Password harus diisi"
register_page.dart

Komponen:

Nama lengkap
Username
Password

Validasi:

Semua field wajib diisi
Kalau kosong →
"Semua field harus diisi"
Password minimal 6 karakter (disarankan)
📋 3. Fitur Rapat (Notulensi)
home_page.dart

Fitur:

Nampilin daftar rapat pakai ListView
Pakai widget MeetingCard
Ada fitur search berdasarkan judul
meeting_detail_page.dart

Komponen:

CustomScrollView + SliverAppBar
Detail lengkap rapat:
Tanggal
Lokasi
Pembahasan
Keputusan
Tindak lanjut

Aksi penting:

Ada konfirmasi dulu sebelum hapus data
meeting_form_page.dart

Dipakai buat tambah & edit rapat

Komponen:

Form input (bisa multi-line)
DatePicker buat pilih tanggal

Validasi:

Judul wajib diisi
→ "Judul tidak boleh kosong"
Field lain opsional (biar fleksibel)
👤 4. Profil User
profile_page.dart

Isi:

Foto profil (CircleAvatar)
Nama & jabatan
Tombol logout
edit_profile_page.dart

Fitur:

Edit data diri
Upload foto pakai ImagePicker

Validasi:

Nama gak boleh kosong
⚙️ 5. Struktur Backend & Data
main.dart
Entry point aplikasi
Nentuin halaman pertama (LoginPage)
Apply theme dari AppTheme
models/

Isi struktur data, contohnya:

Meeting
User

➡️ Dipakai sebagai “blueprint” data di seluruh aplikasi

services/

Bagian ini handle komunikasi ke backend/API:

Ambil data
Tambah data
Edit data
Hapus data

➡️ Tujuannya biar UI gak kecampur sama logic backend

🧩 6. Widget Custom
meeting_card.dart

Dipakai di halaman home buat nampilin ringkasan rapat

Logic warna:

Status Selesai → hijau
Selain itu → maroon
meeting_detail_section.dart

Buat nyusun isi detail rapat jadi lebih rapi (misalnya bagian keputusan)

✅ 7. Validasi Singkat
Hampir semua form cek input dulu sebelum disimpan
Error/sukses ditampilin pakai SnackBar
Ada loading indicator (CircularProgressIndicator) saat proses jalan
🚀 Kesimpulan

Struktur RapatIn dibuat simpel dan modular:

UI dipisah dari logic
Theme terpusat
API dipisah di service

Jadi lebih gampang buat:

dikembangin
dibaca
dan di-maintain ke depannya
