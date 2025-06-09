// Api/server.js

const path = require('path');
const express = require('express');
const multer = require('multer');
const fs = require('fs').promises;

const app = express();
const DB_PATH = path.join(__dirname, 'db.json');

// --- 0) Logging middleware ---
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use((req, res, next) => {
  console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  if (['POST', 'PATCH', 'PUT'].includes(req.method)) {
    console.log('Body:', req.body);
  }
  next();
});

// --- 1) Multer storage: decide carpeta por extensión si MIME falla ---
const storage = multer.diskStorage({
  destination: (_, file, cb) => {
    // extraemos la extensión en minúsculas
    const ext = path.extname(file.originalname).toLowerCase();
    console.log(`Upload incoming: ${file.originalname} (mimetype=${file.mimetype})`);
    console.log(`Detected extension: ${ext}`);

    // si es vídeo por extensión, guardamos en 'videos'
    const videoExts = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    const folder = videoExts.includes(ext) ? 'videos' : 'images';
    console.log(`=> Saving to folder: ${folder}`);

    cb(null, path.join(__dirname, 'public', folder));
  },
  filename: (_, file, cb) => {
    const ext = path.extname(file.originalname);
    const name = Date.now() + ext;
    console.log(`=> Assigned filename: ${name}`);
    cb(null, name);
  }
});

const upload = multer({ storage });

// --- 2) Static file serving ---
app.use('/images', express.static(path.join(__dirname, 'public', 'images')));
app.use('/videos', express.static(path.join(__dirname, 'public', 'videos')));

// --- 3) GET /productos ---
app.get('/productos', async (_, res) => {
  try {
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db  = JSON.parse(raw);
    console.log(`Returning ${db.productos.length} products`);
    res.json(db.productos);
  } catch (e) {
    console.error('Error reading db.json:', e);
    res.status(500).json({ error: 'No pude leer db.json' });
  }
});

// --- 4) POST /upload ---
app.post('/upload', upload.single('file'), (req, res) => {
  console.log('POST /upload');
  if (!req.file) {
    console.warn('No file was uploaded');
    return res.status(400).json({ error: 'No se subió archivo' });
  }
  // decidimos la carpeta ya en storage.destination
  const folder = req.file.destination.includes('videos') ? 'videos' : 'images';
  const url = `/${folder}/${req.file.filename}`;
  console.log('File uploaded successfully, URL:', url);
  res.json({ url });
});

// --- 5) POST /productos ---
app.post('/productos', async (req, res) => {
  console.log('POST /productos, payload:', req.body);
  try {
    const newProd = req.body;
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db  = JSON.parse(raw);
    db.productos.push(newProd);
    await fs.writeFile(DB_PATH, JSON.stringify(db, null, 2));
    console.log('Product added:', newProd.id);
    res.status(201).json(newProd);
  } catch (e) {
    console.error('Error writing db.json:', e);
    res.status(500).json({ error: 'No pude escribir db.json' });
  }
});

// --- 6) PATCH /productos/:id ---
app.patch('/productos/:id', async (req, res) => {
  console.log(`PATCH /productos/${req.params.id}, body:`, req.body);
  try {
    const { id } = req.params;
    const raw = await fs.readFile(DB_PATH, 'utf-8');
    const db  = JSON.parse(raw);
    const idx = db.productos.findIndex(p => p.id === id);
    if (idx === -1) {
      console.warn('Product not found:', id);
      return res.status(404).json({ error: 'Producto no existe' });
    }
    Object.assign(db.productos[idx], req.body);
    await fs.writeFile(DB_PATH, JSON.stringify(db, null, 2));
    console.log('Product updated:', id, 'fields:', Object.keys(req.body));
    res.json(db.productos[idx]);
  } catch (e) {
    console.error('Error updating product:', e);
    res.status(500).json({ error: 'Error al actualizar producto' });
  }
});

// --- 7) Start server ---
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API listening on http://localhost:${PORT}`);
});
