<html>
<head>
<title>Dil Se - Hindi Romantic Music</title>

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    background: linear-gradient(135deg,#18051f,#501044,#a83268);
    color: white;
    min-height: 100vh;
}

header {
    padding: 25px;
    text-align: center;
    font-size: 30px;
    font-weight: bold;
    color: #ffb6d5;
}

.container {
    max-width: 750px;
    margin: 20px auto;
    padding: 20px;
}

.player {
    background: rgba(255,255,255,0.12);
    padding: 25px;
    border-radius: 20px;
    text-align: center;
}

.cover {
    width: 220px;
    height: 220px;
    border-radius: 50%;
    margin: 15px auto;
    background: linear-gradient(45deg,#ff416c,#ff8cba);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 85px;
    box-shadow: 0 0 30px #ff4f9a;
}

h2 {
    margin: 15px;
}

.controls button {
    background: #ff4081;
    color: white;
    border: none;
    padding: 13px 20px;
    margin: 10px 5px;
    border-radius: 30px;
    cursor: pointer;
    font-size: 18px;
}

.controls button:hover {
    background: #ff80ab;
}

input[type="range"] {
    width: 90%;
    accent-color: #ff4081;
}

.search {
    width: 100%;
    padding: 14px;
    margin: 20px 0;
    border-radius: 10px;
    border: none;
}

.song {
    background: rgba(255,255,255,0.12);
    padding: 16px;
    margin: 10px 0;
    border-radius: 10px;
    cursor: pointer;
}

.song:hover {
    background: rgba(255,255,255,0.25);
}

footer {
    text-align: center;
    padding: 25px;
    color: #ffc0db;
}
</style>
</head>

<body>

<header>❤️ DIL SE MUSIC ❤️</header>

<div class="container">

<div class="player">

    <div class="cover">🎵</div>

    <h2 id="title">Select Your Love Song</h2>
    <p>Hindi Romantic Collection</p>

    <br>

    <audio id="audio"></audio>

    <input type="range" id="progress"
    value="0" min="0" max="100">

    <div class="controls">
        <button onclick="previousSong()">⏮</button>
        <button onclick="togglePlay()" id="playBtn">▶</button>
        <button onclick="nextSong()">⏭</button>
    </div>

    <p>Volume</p>
    <input type="range" min="0" max="1"
    step="0.01" value="0.7"
    id="volume">

</div>

<input type="text" class="search"
id="search" placeholder="Search romantic songs..."
oninput="searchSongs()">

<h2>💖 Romantic Songs</h2>

<div id="songList"></div>

</div>

<footer>
Made with ❤️ for Music Lovers
</footer>

<script>

const songs = [
    {
        name: "Tum Hi Ho",
        file: "songs/tum-hi-ho.mp3"
    },
    {
        name: "Raabta",
        file: "songs/raabta.mp3"
    },
    {
        name: "Kesariya",
        file: "songs/kesariya.mp3"
    },
    {
        name: "Hawayein",
        file: "songs/hawayein.mp3"
    },
    {
        name: "Shayad",
        file: "songs/shayad.mp3"
    },
    {
        name: "Apna Bana Le",
        file: "songs/apna-bana-le.mp3"
    },
    {
        name: "Tera Ban Jaunga",
        file: "songs/tera-ban-jaunga.mp3"
    },
    {
        name: "Ranjha",
        file: "songs/ranjha.mp3"
    }
];

let currentSong = 0;

const audio = document.getElementById("audio");
const title = document.getElementById("title");
const playBtn = document.getElementById("playBtn");
const progress = document.getElementById("progress");

function loadSong(index) {
    currentSong = index;
    audio.src = songs[index].file;
    title.innerText = songs[index].name;
    audio.play();
    playBtn.innerText = "⏸";
}

function togglePlay() {
    if (!audio.src) {
        loadSong(currentSong);
        return;
    }

    if (audio.paused) {
        audio.play();
        playBtn.innerText = "⏸";
    } else {
        audio.pause();
        playBtn.innerText = "▶";
    }
}

function nextSong() {
    currentSong = (currentSong + 1) % songs.length;
    loadSong(currentSong);
}

function previousSong() {
    currentSong =
        (currentSong - 1 + songs.length) % songs.length;
    loadSong(currentSong);
}

audio.addEventListener("timeupdate", () => {
    if (audio.duration) {
        progress.value =
            (audio.currentTime / audio.duration) * 100;
    }
});

progress.addEventListener("input", () => {
    if (audio.duration) {
        audio.currentTime =
            (progress.value / 100) * audio.duration;
    }
});

document.getElementById("volume").oninput = function() {
    audio.volume = this.value;
};

audio.addEventListener("ended", nextSong);

function displaySongs(list) {
    document.getElementById("songList").innerHTML = "";

    list.forEach(song => {
        let index = songs.indexOf(song);

        let div = document.createElement("div");
        div.className = "song";
        div.textContent = "🎵 " + song.name;

        div.onclick = () => loadSong(index);

        document.getElementById("songList")
            .appendChild(div);
    });
}

function searchSongs() {
    let query = document.getElementById("search")
        .value.toLowerCase();

    let filtered = songs.filter(song =>
        song.name.toLowerCase().includes(query)
    );

    displaySongs(filtered);
}

displaySongs(songs);

</script>

</body>
</html>

