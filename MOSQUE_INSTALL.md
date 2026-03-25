# 🕌 Panduan Instalasi YADM (Yet Another Display Mosque)

Bismillah, panduan ini ditujukan bagi pengurus masjid atau teknisi yang ingin memasang sistem display YADM di layar TV/Monitor masjid.

## 📋 Persyaratan Sistem

Untuk menjalankan YADM, Anda membutuhkan:
1.  **Hardware**: PC Mini, Raspberry Pi, atau STB Android (yang sudah di-root/install Linux) dengan output HDMI.
2.  **OS**: Windows 10/11 atau Linux (Ubuntu/Debian/Arch/Raspberry Pi OS).
3.  **Software**: [Node.js v20+](https://nodejs.org/) terpasang di sistem.

---

## 🚀 Langkah 1: Instalasi Software (Runner)

Pilih salah satu cara berikut untuk memasang YADM:

### Cara A: Menggunakan Paket Siap Pakai (Rekomendasi)
1.  Buka halaman [Releases](https://github.com/nyanpoketto-kujira/Yet-Another-Display-Mosque/releases).
2.  Unduh file sesuai OS Anda (`yadm-linux.zip` atau `yadm-windows.zip`).
3.  Ekstrak folder tersebut ke lokasi yang diinginkan (contoh: `D:\YADM` atau `/home/pi/YADM`).

### Cara B: Build dari Source (Untuk Developer)
1.  Clone repo: `git clone https://github.com/nyanpoketto-kujira/Yet-Another-Display-Mosque.git`
2.  Jalankan `pnpm install`.
3.  Jalankan `bash build.sh`.
4.  Hasil build akan ada di folder `runner/`.

---

## ⚡ Langkah 2: Menjalankan YADM

### Di Windows
1.  Masuk ke folder `runner/windows`.
2.  Klik dua kali file `start.bat`.
3.  Buka browser (Chrome/Edge), ketik alamat: `http://localhost:3000`.

### Di Linux
1.  Buka terminal, masuk ke folder `runner/linux`.
2.  Jalankan perintah: `./start.sh`.
3.  Buka browser, ketik alamat: `http://localhost:3000`.

---

## 🖥️ Langkah 3: Setup Autorun (Boot)

Agar display masjid otomatis menyala saat listrik hidup:

### Di Windows (Startup Folder)
1.  Tekan `Win + R`, ketik `shell:startup`, tekan Enter.
2.  Klik kanan di dalam folder tersebut, pilih `New -> Shortcut`.
3.  Cari lokasi file `start.bat` di folder YADM Anda.
4.  Layar akan otomatis jalan saat Windows masuk ke Desktop.

### Di Linux (Systemd Service)
1.  Buat file service baru: `sudo nano /etc/systemd/system/yadm.service`
2.  Copy-paste teks berikut (sesuaikan PATH-nya):
    ```ini
    [Unit]
    Description=YADM Runner
    After=network.target

    [Service]
    Type=simple
    User=pi
    WorkingDirectory=/home/pi/YADM/runner/linux
    ExecStart=/home/pi/YADM/runner/linux/start.sh
    Restart=always

    [Install]
    WantedBy=multi-user.target
    ```
3.  Simpan (Ctrl+O, Enter), keluar (Ctrl+X).
4.  Jalankan perintah:
    ```bash
    sudo systemctl enable yadm
    sudo systemctl start yadm
    ```

---

## ⚙️ Langkah 4: Pengaturan Display (Panel Admin)

1.  Buka browser, akses `http://localhost:3000/admin`.
2.  **Kata Sandi Default**: `vibe-masjid`.
3.  Segera ganti kata sandi di tab **Umum**.
4.  Atur **Koordinat Lokasi (Lat/Lng)** agar jadwal sholat akurat. Anda bisa cek koordinat di Google Maps.
5.  Atur **Koreksi Waktu** jika jam di display berbeda beberapa menit dengan jam masjid.

---

## 🛠️ Troubleshooting (Tanya Jawab)

**Q: Kenapa jadwal sholat tidak muncul/salah?**
*   Cek koneksi internet (hanya diperlukan saat pertama kali set koordinat).
*   Pastikan Lat/Lng sudah benar di Panel Admin.
*   Cek jam sistem di komputer Anda (harus sesuai WIB/WITA/WIT).

**Q: Bagaimana cara membuat browser otomatis Fullscreen?**
*   Gunakan mode kiosk di browser. Contoh perintah di shortcut:
    `chrome.exe --kiosk http://localhost:3000`

**Q: Layar 500 Internal Error?**
*   Cek terminal (jendela hitam) tempat YADM berjalan.
*   Pastikan folder `data/` dan file `settings.json` ada di dalam folder runner.
*   Pastikan Node.js sudah versi 20 ke atas.

**Q: Background tidak muncul setelah di-upload?**
*   Refresh halaman atau cek di Panel Admin apakah gambar sudah terdaftar.
*   Pastikan ukuran gambar tidak terlalu besar (disarankan di bawah 2MB).

---
*Semoga bermanfaat untuk umat! Jazakallahu Khairan.* 🕋✨
