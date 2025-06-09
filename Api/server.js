// Api/server.js

const path = require('path');
const express = require('express');
const multer = require('multer');
const fs = require('fs').promises;

const app = express();
const DB_PATH = path.join(__dirname, 'db.json');

// 0) Middleware JSON + logging
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use((req, res, next) => {
  console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  if (['POST', 'PATCH', 'PUT'].includes(req.method)) {
    console.log('Body:', req.body);
  }
  next();
});

// 1) LOGIN
app.post('/login', async (req, res) => {
  try {
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db = JSON.parse(raw);
    console.log('Usuarios en DB:', db.usuarios);

    const { email, password } = req.body;
    const user = db.usuarios.find(
      u => u.email === email && u.password === password
    );
    if (!user) {
      console.warn('Credenciales inválidas para', email);
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    // Devuelve user sin password
    const { password: _, ...safe } = user;
    return res.json(safe);
  } catch (e) {
    console.error('Error en /login:', e);
    return res.status(500).json({ error: 'Error interno' });
  }
});

// Multer storage (imágenes / vídeos)
const storage = multer.diskStorage({
  destination: (_, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const videoExts = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    const folder = videoExts.includes(ext) ? 'videos' : 'images';
    cb(null, path.join(__dirname, 'public', folder));
  },
  filename: (_, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + ext);
  }
});
const upload = multer({ storage });

// 2) Servir estáticos
app.use('/images', express.static(path.join(__dirname, 'public', 'images')));
app.use('/videos', express.static(path.join(__dirname, 'public', 'videos')));

// 3) GET /productos
app.get('/productos', async (_, res) => {
  try {
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db = JSON.parse(raw);
    return res.json(db.productos);
  } catch (e) {
    console.error('Error leyendo productos:', e);
    return res.status(500).json({ error: 'No pude leer db.json' });
  }
});

// 4) POST /upload
app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No se subió archivo' });
  }
  const folder = req.file.destination.includes('videos') ? 'videos' : 'images';
  const url = `/${folder}/${req.file.filename}`;
  return res.json({ url });
});

// 5) POST /productos
app.post('/productos', async (req, res) => {
  try {
    const newProd = req.body;
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db = JSON.parse(raw);
    db.productos.push(newProd);
    await fs.writeFile(DB_PATH, JSON.stringify(db, null, 2));
    return res.status(201).json(newProd);
  } catch (e) {
    console.error('Error creando producto:', e);
    return res.status(500).json({ error: 'No pude escribir db.json' });
  }
});

// 6) PATCH /productos/:id
app.patch('/productos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db = JSON.parse(raw);
    const idx = db.productos.findIndex(p => p.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Producto no existe' });
    }
    Object.assign(db.productos[idx], req.body);
    await fs.writeFile(DB_PATH, JSON.stringify(db, null, 2));
    return res.json(db.productos[idx]);
  } catch (e) {
    console.error('Error actualizando producto:', e);
    return res.status(500).json({ error: 'Error al actualizar producto' });
  }
});

// 7) PATCH /usuarios/:id (para favorites y cart)
app.patch('/usuarios/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db = JSON.parse(raw);
    const idx = db.usuarios.findIndex(u => u.id === id);
    if (idx === -1) {
      return res.status(404).json({ error: 'Usuario no existe' });
    }
    Object.assign(db.usuarios[idx], req.body);
    await fs.writeFile(DB_PATH, JSON.stringify(db, null, 2));
    const { password: _, ...safe } = db.usuarios[idx];
    return res.json(safe);
  } catch (e) {
    console.error('Error actualizando usuario:', e);
    return res.status(500).json({ error: 'Error al actualizar usuario' });
  }
});

// 8) Arrancar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API escuchando en http://localhost:${PORT}`);
});
