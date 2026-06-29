# 💳 Dompet Kampus Global - E-Wallet Application

### 👤 Identitas Mahasiswa
- **Nama:** Aditya Maula Wiratama
- **NIM:** 1123150013
- **Kelas:** TI SE 1


[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://go.dev)
[![MySQL](https://img.shields.io/badge/MySQL-00000F?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com)
[![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

Aplikasi dompet digital (E-Wallet) berbasis mobile yang dirancang khusus untuk ekosistem kampus. Aplikasi ini memungkinkan pengguna melakukan pembayaran merchant secara instan melalui integrasi **Native Deep Linking**, transfer saldo antar-pengguna, pengisian saldo (top-up), dengan perlindungan keamanan ganda berupa **PIN Transaksi** dan **Two-Factor Authentication (2FA)**.

---

## 📺 Demo Video
Tonton demonstrasi alur transaksi lengkap dan penjelasan integrasi sistem pada video YouTube berikut:
👉 **[Video Demo & Penjelasan Proyek di YouTube](https://youtu.be/lqV_6NxRiec)**

---

## ✨ Fitur Utama
- **Autentikasi Firebase & Google Sign-In**: Login aman satu ketukan menggunakan kredensial Google yang diverifikasi oleh Firebase Admin SDK di backend.
- **Pembayaran Deep-Link Merchant**: Secara otomatis mendeteksi dan merespons tagihan belanja dari aplikasi luar melalui custom scheme URL (`dompetkampus://pay`).
- **Two-Factor Authentication (2FA)**:
  - **OTP Email SMTP**: OTP dinamis dikirim ke email pengguna via SMTP Gmail dan diverifikasi menggunakan penyimpanan sementara di Redis.
  - **TOTP (Time-based OTP)**: Sinkronisasi token dinamis 6-digit menggunakan algoritma standar Google Authenticator.
- **PIN Transaksi 6-Digit**: Lapisan perlindungan lokal sebelum transaksi dikirim ke backend.
- **Bypass OTP untuk Deep-Link**: Pengalaman pembayaran merchant yang instan dengan mem-bypass verifikasi OTP email (menggunakan PIN transaksi sebagai validasi utama).
- **Mutasi Saldo & Riwayat Transaksi**: Pencatatan riwayat transaksi debit, kredit, transfer, dan top-up secara real-time.

---

## 📸 Antarmuka UI & Screenshots

Untuk mempermudah pemahaman alur aplikasi, berikut adalah tangkapan layar (screenshots) dari antarmuka pengguna aplikasi Dompet Kampus Global:

### 1. Autentikasi & Verifikasi Keamanan (2FA)
| Halaman Awal | Pendaftaran Akun | Masuk Akun (Login) | Kode OTP (2FA) |
| :---: | :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/8af2847b-7910-4d47-82c6-18e34c69a0b3" width="200" /> | <img src="https://github.com/user-attachments/assets/b024050b-0bdb-4e45-9c44-4a1be70c02fe" width="200" /> | <img src="https://github.com/user-attachments/assets/65ea42d9-c604-4dde-89b6-8e87c87ebda5" width="200" /> | <img src="https://github.com/user-attachments/assets/6531d799-33e2-43fc-9eab-0c1b35a97047" width="200" /> |

### 2. Fitur Transaksi & Profil
| Halaman Beranda Utama | Menu Top-Up (Isi Saldo) | Riwayat Transaksi | Detail Profil Akun |
| :---: | :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/ac9290e1-a0dc-4952-aa33-26e107ad8a7f" width="200" /> | <img src="https://github.com/user-attachments/assets/9e100fac-97e6-4e9d-bba6-7353180d178f" width="200" /> | <img src="https://github.com/user-attachments/assets/b85083cb-6651-4ad9-b870-008f1936b86b" width="200" /> | <img src="https://github.com/user-attachments/assets/cf883c64-42aa-437e-9452-ed3f12c348cc" width="200" /> |




## 🛠️ Arsitektur Aplikasi & Struktur Proyek
Aplikasi dikembangkan menggunakan **Flutter Clean Architecture** yang dipadukan dengan state management **BLoC**:

```
lib/
├── core/
│   ├── constants/       # Konfigurasi port, base URL, dan endpoint API
│   ├── error/           # Definisi exceptions dan failures
│   ├── network/         # Client HTTP (Dio) dengan Logger Interceptor
│   ├── services/        # Service Deep-link dan callback merchant
│   └── theme/           # Konfigurasi warna, gaya font, dan tema UI
├── data/
│   ├── datasources/     # Remote data sources (API request)
│   ├── models/          # GORM-compliant models & serialization
│   └── repositories/    # Implementasi repositori data
├── domain/
│   ├── entities/        # Entitas bisnis utama
│   ├── repositories/    # Kontrak/interface repositori
│   └── usecases/        # Logika bisnis transaksi dan OTP
└── presentation/
    ├── blocs/           # Flutter BLoC (Auth, Payment, Otp)
    ├── pages/           # Layar antarmuka UI (Home, PIN, Success, 2FA)
    └── widgets/         # Kustomisasi UI reusable (PinPad, Buttons)
```

---

## 🔗 Mekanisme Integrasi Pembayaran (Deep Link)
Alur transaksi antara E-Commerce (Pasar Malam) dan E-Wallet (Dompet Kampus Global) berjalan sebagai berikut:

```mermaid
sequenceDiagram
    participant PM as Pasar Malam (E-Commerce)
    participant DK as Dompet Kampus (E-Wallet)
    participant BE as be-emoney (Backend Wallet)

    PM->>DK: Launch Deep-link (dompetkampus://pay?merchant_id=...&amount=400000)
    Note over DK: Parse parameter nominal & metadata
    DK->>DK: Pengguna memasukkan PIN Transaksi
    DK->>BE: POST /v1/payment/transfer (otp_type: "deeplink")
    Note over BE: Verifikasi PIN & Potong Saldo (MySQL)
    BE-->>DK: HTTP 200 OK (Transfer Sukses)
    DK->>PM: Callback Deep-link (pasarmalam://payment-callback?status=success&transaction_id=...)
    Note over PM: Transaksi terdeteksi sukses instan & order diperbarui
```

---

## ⚙️ Panduan Instalasi & Setup

### Sisi Backend (`be-emoney`)
Backend berjalan menggunakan **Go (Golang)** pada port `8081`.

1. Pastikan database **MySQL** dan **Redis** Anda sudah berjalan lokal.
2. Buat database baru bernama `emoney` di MySQL.
3. Konfigurasikan file `.env` di folder backend:
   ```env
   PORT=8081
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=emoney
   REDIS_HOST=localhost
   REDIS_PORT=6379
   ```
4. Jalankan perintah untuk mengunduh dependencies, kompilasi, dan menjalankan server:
   ```bash
   go run main.go
   ```

### Sisi Frontend (Flutter)
1. Buka file `lib/core/constants/app_constants.dart` dan sesuaikan IP `baseUrl` dengan IP mesin lokal Anda:
   ```dart
   static const String baseUrl = 'http://192.168.0.105:8081';
   ```
2. Bersihkan cache build lama dan ambil packages:
   ```bash
   flutter clean
   flutter pub get
   ```
3. Sambungkan emulator Android atau HP Anda, lalu jalankan:
   ```bash
   flutter run
   ```

---

## 👥 Pengembang (Contributors)
- **Aditya Maula Wiratama** - **1123150013** (Kelas: TI SE 1) - Pengembangan Frontend Mobile (Flutter BLoC), Integrasi Native Deep-linking, & Penyesuaian API E-Wallet.
