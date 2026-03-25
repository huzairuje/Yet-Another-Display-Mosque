# 🕋 Yet Another Display Mosque (YADM)

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Build](https://img.shields.io/badge/build-Svelte_5-orange.svg)

**YADM** adalah sistem display informasi masjid modern yang dirancang khusus untuk layar 1080p. Dengan fokus pada estetika "vibe-centric" dan kemudahan pengelolaan via Panel Admin yang intuitif.

## ✨ Fitur Utama

- 🕋 **Jadwal Sholat Otomatis**: Kalkulasi presisi berdasarkan koordinat lokasi (Lat/Lng).
- ⚡ **Real-time Sync (SSE)**: Perubahan di Panel Admin langsung muncul di layar tanpa *refresh*.
- 🎨 **Tema Dinamis**: Pilihan tema (Modern, Classic, Ocean, Sunset, dll) yang menyesuaikan suasana.
- 🖼️ **Slideshow Background**: Unggah foto kegiatan masjid atau pemandangan dengan mudah.
- 💰 **Manajemen Kas**: Pencatatan pemasukan & pengeluaran yang transparan.
- 📜 **Informasi & Teks Berjalan**: Sampaikan pengumuman atau hadits dengan gaya elegan.
- 🕌 **Mode Jum'at**: Tampilan khusus untuk nama Khathib dan durasi khutbah.

## 🛠️ Tech Stack

- **Framework**: [Svelte 5](https://svelte.dev/) (Runes)
- **Meta-framework**: [SvelteKit](https://kit.svelte.dev/)
- **Styling**: [TailwindCSS](https://tailwindcss.com/)
- **Icons**: [Lucide Svelte](https://lucide.dev/)
- **Communication**: Server-Sent Events (SSE)

## 🚀 Cara Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/nyanpoketto-kujira/Yet-Another-Display-Mosque.git
   cd Yet-Another-Display-Mosque
   ```

2. **Install Dependencies**
   ```bash
   pnpm install
   ```

3. **Jalankan Mode Development**
   ```bash
   pnpm dev
   ```

4. **Build untuk Produksi**
   ```bash
   pnpm build
   ```

## 📝 Konfigurasi

Semua pengaturan dilakukan melalui halaman admin di `/admin`. Password default dapat dilihat/diubah di file `data/settings.json`.

---
Dibuat dengan ❤️ oleh [nyanpoketto-kujira](https://github.com/nyanpoketto-kujira)
