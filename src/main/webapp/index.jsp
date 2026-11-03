<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ultimate Racing X</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    background: #080d18;
    color: white;
    font-family: Arial, sans-serif;
    text-align: center;
    overflow: hidden;
}

h1 {
    color: #00eaff;
    letter-spacing: 4px;
    margin: 12px;
    text-shadow: 0 0 15px #00eaff;
}

#hud {
    display: flex;
    justify-content: space-around;
    max-width: 700px;
    margin: auto;
    padding: 10px;
    font-size: 17px;
    font-weight: bold;
}

#game {
    position: relative;
    width: min(700px, 100vw);
    height: min(75vh, 650px);
    min-height: 380px;
    margin: auto;
    overflow: hidden;
    background: linear-gradient(#152a32, #294a35 35%, #202020 36%);
    border: 3px solid #00d9ff;
    box-shadow: 0 0 25px #00bfff;
}

canvas {
    width: 100%;
    height: 100%;
    display: block;
}

#overlay {
    position: absolute;
    inset: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #000b;
    z-index: 5;
}

#overlay h2 {
    color: #00eaff;
    font-size: 36px;
}

button {
    border: 0;
    background: linear-gradient(45deg,#00aaff,#00ffcc);
    padding: 13px 24px;
    margin: 7px;
    border-radius: 9px;
    font-weight: bold;
    font-size: 16px;
    cursor: pointer;
    color: #00111c;
}

button:active { transform: scale(.94); }

#controls {
    margin: 8px;
}

.small {
    color: #b8c8d8;
    font-size: 13px;
}
</style>
</head>

<body>

<h1>🏁 ULTIMATE RACING X</h1>

<div id="hud">
    <div>🏆 SCORE: <span id="score">0</span></div>
    <div>⚡ SPEED: <span id="speed">0</span></div>
    <div>💎 NITRO: <span id="nitro">100</span>%</div>
</div>

<div id="game">
    <canvas id="canvas"></canvas>

    <div id="overlay">
        <h2>ULTIMATE RACING</h2>
        <p>Race through traffic. Avoid collisions!</p>
        <button onclick="startGame()">START RACE</button>
        <p class="small">Arrow keys / A-D to steer | Space for Nitro</p>
    </div>
</div>

<div id="controls">
    <button id="left">⬅ LEFT</button>
    <button id="boost">⚡ NITRO</button>
    <button id="right">RIGHT ➡</button>
</div>

<script>
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

const overlay = document.getElementById("overlay");

let W, H;
let running = false;
let score = 0;
let speed = 5;
let nitro = 100;
let roadOffset = 0;
let spawnTimer = 0;
let lastTime = 0;

let player = {
    x: 0,
    y: 0,
    width: 42,
    height: 78
};

let traffic = [];
let particles = [];
let keys = {};

function resize() {
    const rect = canvas.getBoundingClientRect();
    const oldW = W || rect.width;

    W = rect.width;
    H = rect.height;

    canvas.width = W * devicePixelRatio;
    canvas.height = H * devicePixelRatio;
    ctx.setTransform(devicePixelRatio,0,0,devicePixelRatio,0,0);

    player.y = H - 105;

    if (!player.x) player.x = W / 2;
    else player.x = Math.max(25, Math.min(W-25, player.x / oldW * W));
}

window.addEventListener("resize", resize);
resize();

function road() {
    const center = W / 2;
    const roadWidth = Math.min(W * .76, 420);
    const left = center - roadWidth/2;

    ctx.fillStyle = "#254b30";
    ctx.fillRect(0,0,W,H);

    ctx.fillStyle = "#292d32";
    ctx.fillRect(left,0,roadWidth,H);

    ctx.fillStyle = "#eeeeee";
    ctx.fillRect(left,0,5,H);
    ctx.fillRect(left+roadWidth-5,0,5,H);

    roadOffset += speed;
    if (roadOffset > 80) roadOffset = 0;

    for (let y=-80; y<H; y+=80) {
        let yy = y + roadOffset;

        ctx.fillStyle = "#eeeeee";
        ctx.fillRect(center-3, yy, 6, 42);

        ctx.fillStyle = "#f3bc39";
        ctx.fillRect(left+roadWidth/3, yy, 3, 35);
        ctx.fillRect(left+roadWidth*2/3, yy, 3, 35);
    }
}

function drawCar(x,y,color,isPlayer=false) {
    ctx.save();
    ctx.translate(x,y);

    // Shadow
    ctx.fillStyle = "#0008";
    ctx.fillRect(-20,8,44,68);

    // Wheels
    ctx.fillStyle = "#080808";
    ctx.fillRect(-23,13,7,20);
    ctx.fillRect(16,13,7,20);
    ctx.fillRect(-23,47,7,20);
    ctx.fillRect(16,47,7,20);

    // Car body
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.roundRect(-19,0,38,75,9);
    ctx.fill();

    // Windows
    ctx.fillStyle = "#9beaff";
    ctx.beginPath();
    ctx.roundRect(-13,15,26,20,5);
    ctx.fill();

    ctx.fillStyle = "#152d40";
    ctx.fillRect(-13,40,26,12);

    // Lights
    ctx.fillStyle = "#ff3030";
    ctx.fillRect(-15,65,8,5);
    ctx.fillRect(7,65,8,5);

    if(isPlayer) {
        ctx.fillStyle = "#00ffff";
        ctx.fillRect(-15,2,30,4);
    }

    ctx.restore();
}

function spawnTraffic() {
    const center = W/2;
    const roadWidth = Math.min(W*.76,420);
    const laneWidth = roadWidth/3;

    let lane = Math.floor(Math.random()*3);

    traffic.push({
        x: center-roadWidth/2+laneWidth*(lane+.5),
        y: -90,
        color: ["#ff3030","#f5b800","#bb55ff","#eeeeee"][Math.floor(Math.random()*4)],
        speed: 2+Math.random()*2
    });
}

function collision(a,b) {
    return Math.abs(a.x-b.x)<33 &&
           Math.abs(a.y-b.y)<62;
}

function update(dt) {
    if(!running) return;

    let boost = keys[" "] && nitro>0;

    if(boost) nitro=Math.max(0,nitro-.25*dt);
    else nitro=Math.min(100,nitro+.05*dt);

    let currentSpeed = speed+(boost?7:0);

    if(keys["ArrowLeft"] || keys["a"])
        player.x -= 5*dt/16;

    if(keys["ArrowRight"] || keys["d"])
        player.x += 5*dt/16;

    player.x = Math.max(25,Math.min(W-25,player.x));

    spawnTimer += dt;

    if(spawnTimer > Math.max(450,1050-speed*40)) {
        spawnTraffic();
        spawnTimer=0;
    }

    traffic.forEach(car=>{
        car.y += (currentSpeed+car.speed)*dt/16;
    });

    for(let i=traffic.length-1;i>=0;i--) {
        let car=traffic[i];

        if(collision(player,car)) {
            gameOver();
            return;
        }

        if(car.y>H+100) {
            traffic.splice(i,1);
            score+=10;
        }
    }

    score += dt/100;
    document.getElementById("score").textContent=Math.floor(score);
    document.getElementById("speed").textContent=Math.floor(currentSpeed*20);
    document.getElementById("nitro").textContent=Math.floor(nitro);
}

function draw() {
    ctx.clearRect(0,0,W,H);

    road();

    traffic.forEach(car=>{
        drawCar(car.x,car.y,car.color);
    });

    if(running) {
        drawCar(player.x,player.y,"#00aaff",true);
    }

    // Nitro flame
    if(running && keys[" "] && nitro>0) {
        ctx.fillStyle="#00ddff";
        ctx.beginPath();
        ctx.moveTo(player.x-9,player.y+73);
        ctx.lineTo(player.x,player.y+105+Math.random()*10);
        ctx.lineTo(player.x+9,player.y+73);
        ctx.fill();
    }
}

function loop(timestamp) {
    let dt=Math.min(timestamp-lastTime || 16,40);
    lastTime=timestamp;

    update(dt);
    draw();

    if(running) requestAnimationFrame(loop);
}

function startGame() {
    score=0;
    speed=5;
    nitro=100;
    traffic=[];
    spawnTimer=0;
    lastTime=0;

    player.x=W/2;
    player.y=H-105;

    running=true;
    overlay.style.display="none";

    requestAnimationFrame(loop);
}

function gameOver() {
    running=false;

    overlay.innerHTML=`
        <h2>GAME OVER!</h2>
        <h3>🏆 Score: ${Math.floor(score)}</h3>
        <button onclick="startGame()">RACE AGAIN</button>
    `;

    overlay.style.display="flex";
}

document.addEventListener("keydown",e=>{
    keys[e.key===" "?" ":e.key]=true;

    if(["ArrowLeft","ArrowRight","ArrowUp"," "].includes(e.key))
        e.preventDefault();
});

document.addEventListener("keyup",e=>{
    keys[e.key===" "?" ":e.key]=false;
});

function holdButton(id,key) {
    const btn=document.getElementById(id);

    btn.addEventListener("pointerdown",e=>{
        e.preventDefault();
        keys[key]=true;
    });

    ["pointerup","pointerleave","pointercancel"].forEach(event=>{
        btn.addEventListener(event,()=>keys[key]=false);
    });
}

holdButton("left","ArrowLeft");
holdButton("right","ArrowRight");
holdButton("boost"," ");

draw();
</script>

</body>
</html>

