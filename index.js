require('dotenv').config();

// 2. SONRA DİĞER MODÜLLER GELMELİ
const express = require('express');
const cors = require('cors');
const prisma = require('./db'); // db.js artık çalışırken DATABASE_URL'i hafızada bulacak


const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// 1. TEST ROTASI
app.get('/', (req, res) => {
  res.json({ message: "Focushion API Aktif! 🚀" });
});

// 2. KAYIT OL (REGISTER) ROTASI
app.post('/api/register', async (req, res) => {
  const { email, username, password } = req.body;

  try {
    // E-posta veya kullanıcı adı zaten var mı kontrol et
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email: email },
          { username: username }
        ]
      }
    });

    if (existingUser) {
      return res.status(400).json({ error: "E-posta veya kullanıcı adı zaten kullanımda!" });
    }

    // Yeni kullanıcıyı Docker veritabanına kaydet
    // NOT: Gerçek projelerde şifre bcrypt ile şifrelenir, şimdilik mantığı oturtmak için düz yazıyoruz.
    const newUser = await prisma.user.create({
      data: {
        email,
        username,
        password,
        score: 100 // Yeni başlayan her popüler adaya 100 hoş geldin puanı!
      }
    });

    res.status(201).json({ message: "Kullanıcı başarıyla oluşturuldu!", user: newUser });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Sunucu hatası oluştu." });
  }
});

// 3. GİRİŞ YAP (LOGIN) ROTASI
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Kullanıcıyı e-posta adresine göre ara
    const user = await prisma.user.findUnique({
      where: { email: email }
    });

    // Kullanıcı yoksa veya şifre yanlışsa hata dön
    if (!user || user.password !== password) {
      return res.status(400).json({ error: "E-posta veya şifre hatalı!" });
    }

    // Giriş başarılıysa kullanıcı bilgilerini dön
    res.status(200).json({
      message: "Giriş başarılı! Hoş geldin.",
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        score: user.score
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Sunucu hatası oluştu." });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server ${PORT} portunda cayır cayır çalışıyor...`);
});