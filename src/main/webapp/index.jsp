<html>
<head>
<title>Bike Rider Game</title>

<style>
body {
    margin: 0;
    background: #222;
    font-family: Arial;
    text-align: center;
    color: white;
}

h1 { color: orange; }

#game {
    width: 400px;
    height: 550px;
    background: #555;
    margin: auto;
    position: relative;
    overflow: hidden;
    border-left: 6px solid white;
    border-right: 6px solid white;
}

#bike {
    position: absolute;
    bottom: 25px;
    left: 175px;
    font-size: 45px;
    z-index: 5;
}

.road-line {
    position: absolute;
    width: 8px;
    height: 60px;
    background: white;
    left: 196px;
}

.obstacle {
    position: absolute;
    font-size: 35px;
}

#score {
    font-size: 22px;
    margin: 10px;
}

button {
    padding: 12px 25px;
    background: orange;
    border: none;
    border-radius: 8px;
    font-size: 17px;
    margin: 8px;
}
</style>
</head>

<body>

<h1>🏍 BIKE RIDER GAME</h1>
<div id="score">Score: 0</div>

<div id="game">
    <div id="bike">🏍️</div>
</div>

<button onclick="move(-1)">⬅ LEFT</button>
<button onclick="startGame()">START</button>
<button onclick="move(1)">RIGHT ➡</button>
<br>
<button onclick="accelerate()">ACCELERATE</button>

<script>
const game = document.getElementById("game");
const bike = document.getElementById("bike");
const scoreText = document.getElementById("score");

let bikeX = 175;
let score = 0;
let speed = 5;
let running = false;
let obstacles = [];
let animation;
let lastObstacle = 0;

function move(direction) {
    if (!running) return;

    bikeX += direction * 45;
    bikeX = Math.max(10, Math.min(345, bikeX));
    bike.style.left = bikeX + "px";
}

function accelerate() {
    if (running) speed = Math.min(speed + 2, 15);
}

function startGame() {
    cancelAnimationFrame(animation);
    obstacles.forEach(o => o.el.remove());
    obstacles = [];

    bikeX = 175;
    score = 0;
    speed = 5;
    lastObstacle = 0;
    running = true;

    bike.style.left = bikeX + "px";
    gameLoop();
}

function createObstacle() {
    let el = document.createElement("div");
    el.className = "obstacle";
    el.innerHTML = "🚗";

    let x = [35, 130, 235, 320][Math.floor(Math.random() * 4)];

    el.style.left = x + "px";
    el.style.top = "-50px";

    game.appendChild(el);
    obstacles.push({el: el, x: x, y: -50});
}

function gameLoop() {
    if (!running) return;

    let now = Date.now();

    if (now - lastObstacle > 1100) {
        createObstacle();
        lastObstacle = now;
    }

    obstacles.forEach((o, index) => {
        o.y += speed;
        o.el.style.top = o.y + "px";

        // Collision detection
        if (
            o.y > 445 &&
            o.y < 525 &&
            Math.abs(o.x - bikeX) < 45
        ) {
            running = false;
            alert("GAME OVER! Your Score: " + score);
        }

        if (o.y > 560) {
            o.el.remove();
            obstacles.splice(index, 1);
            score += 10;
            scoreText.innerHTML = "Score: " + score;
        }
    });

    if (running) {
        animation = requestAnimationFrame(gameLoop);
    }
}

document.addEventListener("keydown", function(e) {
    if (e.key === "ArrowLeft") move(-1);
    if (e.key === "ArrowRight") move(1);
    if (e.key === "ArrowUp") accelerate();
});
</script>

</body>
</html>

