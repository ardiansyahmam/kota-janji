# KOTA JANJI — Petualangan Anggaran

Platformer retro 8-bit satir fiksi. Dibangun mengikuti spec
`Super_Prompt_Kota_Janji.md` dan desain Figma "Game Adventure Satir Sumsel".

## Cara main (Godot 4.3)

```bash
# Buka Godot 4.3 → Import → pilih folder kota-janji → Play (F5)
# Atau headless (uji cepat):
./godot --headless --path kota-janji
```

Kontrol keyboard: `←`/`→` atau `A`/`D` bergerak, `Spasi`/`W` lompat,
`Shift`/`J` dash, `P`/`Esc` pause. Di HP: tombol sentuh di bawah layar.

## Yang sudah jadi (MVP + 8 level)

- Layar: Loading, Start, Gameplay, Pause, Pengaturan, Level Selesai,
  Game Over, Ending "Kota Bukti"
- Mekanik inti: lari, lompat (coyote time + jump buffer 100ms), dash,
  3 hati, checkpoint posko, simpan lokal (`user://save.json`)
- Level 1 Jalan Berlubang (lubang + 10 dokumen)
- Level 2 Kantor Rapat (zona lambat + Notulen + 5 stempel)
- Level 3 Proyek Mangkrak (boss Pagar Proyek — lompat di kepala, 3 HP)
- Level 4 Kota Gelap (kegelapan berkurang tiap bohlam, 8 bohlam)
- Level 5 Halte Sepi (bus platform sesuai jadwal 6 dtk ada / 10 dtk tidak)
- Level 6 Stadion Sepi (tiket 3 + spanduk 3 + panggung 3 + perayaan)
- Level 7 Langit Kuning (zona asap menguras nyawa tanpa masker 30 dtk)
- Level 8 Gedung Janji (boss Mesin Janji — serahkan 3 dokumen ke Kotak Fakta)
- Bubble keluhan warga: 6 keluhan per level (48 total), bergantian tiap
  mendekat / tiap 5 detik. Level 7 bernada serius & empatik.
- Audio: SFX prosedural (tanpa file eksternal). Font pixel Press Start 2P
  + VT323 (OFL) TIDAK ikut di repo (file biner) — unduh dengan
  `bash tools/fetch-fonts.sh` sebelum membuka di editor; tanpa font pun
  game tetap jalan dengan font bawaan Godot. Workflow GitHub Actions
  (`.github/workflows/export-web.yml`) otomatis mengekspor versi Web dan
  deploy ke GitHub Pages setiap push ke `main` (aktifkan Pages → Source:
  GitHub Actions sekali di Settings repo).

## Yang belum / langkah berikut

- Ekspor Android (APK/AAB): butuh export template Godot 4.3 + Android SDK
  di laptop, lalu `Project → Export`. Kode sudah mobile-ready (portrait
  390×844, tombol sentuh).
- Musik latar loop chiptune (saat ini baru SFX).
- Ikon aplikasi & splash screen final.

## Guardrail satir

Fiksi total: yang disindir adalah PROSES (lubang, rapat, proyek mangkrak,
janji). Tanpa nama, wajah, atau instansi asli. Disclaimer ada di layar Start.
