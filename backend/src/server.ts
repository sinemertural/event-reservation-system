import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => { // belirtilen port üzerinden sunucuyu dinlemeye başlıyoruz.
    console.log(`Server is running on http://localhost:${PORT}`);
});