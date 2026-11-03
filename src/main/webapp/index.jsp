<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
<meta name="theme-color" content="#071323">
<title>3D Car Racing</title>
<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#071323;color:#fff;font-family:Arial,sans-serif;touch-action:none}
#game{position:relative;width:100%;height:100dvh;overflow:hidden;background:#74c8f2}
#view{position:absolute;inset:0}canvas{display:block;width:100%;height:100%}
.hud{position:absolute;z-index:3;top:calc(10px + env(safe-area-inset-top));left:10px;display:grid;gap:7px;pointer-events:none}
.stat{min-width:116px;padding:8px 12px;border-radius:12px;background:#07182cdb;border:1px solid #ffffff55;box-shadow:0 4px 14px #0017}
.stat small{display:block;font-size:11px;font-weight:bold;color:#dcecff;letter-spacing:1px}
.stat b{font-size:21px;color:#ffce2e}
.title{position:absolute;z-index:3;top:calc(10px + env(safe-area-inset-top));left:50%;transform:translateX(-50%);padding:8px 15px;border-radius:10px;border:1px solid #ffffff88;background:#101e35dd;text-align:center;font-weight:900;font-size:clamp(16px,4vw,26px);font-style:italic;white-space:nowrap;pointer-events:none}
.title span{color:#ffcc22}.title small{display:block;font-size:9px;letter-spacing:3px;color:#e7f0ff}
.right{position:absolute;z-index:3;right:10px;top:calc(10px + env(safe-area-inset-top))}
button{font-family:inherit;cursor:pointer;touch-action:none}
.pause{width:45px;height:45px;border-radius:50%;border:2px solid #ffffffaa;color:white;background:#07182cdd;font-size:21px}
.controls{position:absolute;z-index:3;bottom:calc(15px + env(safe-area-inset-bottom));left:0;right:0;display:flex;justify-content:space-between;padding:0 14px;pointer-events:none}
.controlGroup{display:flex;gap:10px;pointer-events:auto}
.ctrl{width:clamp(60px,17vw,88px);height:clamp(60px,17vw,88px);border:2px solid #ffffffb8;border-radius:50%;background:#07182cbb;color:#fff;font-size:30px;font-weight:bold;box-shadow:0 5px 16px #0006}
.ctrl span{display:block;font-size:9px;letter-spacing:1px;margin-top:-2px}
.ctrl.active,.ctrl:active{background:#087fce;transform:scale(.96)}
.overlay{position:absolute;z-index:5;inset:0;display:flex;align-items:center;justify-content:center;padding:20px;background:#02091688}
.dialog{width:min(390px,94vw);padding:24px 20px;text-align:center;border:1px solid #ffffff99;border-radius:18px;background:linear-gradient(145deg,#172c45,#06101d);box-shadow:0 15px 45px #0009}
.dialog h1{margin:0 0 8px;color:#ffcf24;font-size:clamp(28px,8vw,40px);font-style:italic}
.dialog p{color:#e4edf8;line-height:1.45}
.action{border:0;border-radius:9px;padding:12px 20px;margin:5px;color:white;background:#087fe0;font-size:16px;font-weight:bold}
.action.green{background:#149b48}.hidden{display:none!important}
.note{font-size:11px;color:#bdd2e7}
@media(max-height:500px){.ctrl{width:54px;height:54px}.controls{bottom:5px}.stat{padding:5px 8px}.stat b{font-size:17px}}
</style>
<script type="importmap">
{"imports":{"three":"https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js"}}
</script>
</head>
<body>
<div id="game">
  <div id="view"></div>
  <div class="hud">
    <div class="stat"><small>🏆 SCORE</small><b id="score">0</b></div>
    <div class="stat"><small>⚡ SPEED</small><b><span id="speed">80</span> km/h</b></div>
    <div class="stat"><small>◷ TIME</small><b id="timer">00:00</b></div>
  </div>
  <div class="title">3D <span>CAR RACING</span><small>SPEED • RACE • WIN</small></div>
  <div class="right"><button class="pause" id="pauseBtn" aria-label="Pause">Ⅱ</button></div>
  <div class="controls">
    <div class="controlGroup">
      <button class="ctrl" data-key="left" aria-label="Left">◀</button>
      <button class="ctrl" data-key="right" aria-label="Right">▶</button>
    </div>
    <div class="controlGroup">
      <button class="ctrl" data-key="brake" aria-label="Brake">▤<span>BRAKE</span></button>
      <button class="ctrl" data-key="gas" aria-label="Accelerate">▲<span>GAS</span></button>
    </div>
  </div>
  <div class="overlay" id="start">
    <div class="dialog">
      <h1>3D CAR RACING</h1>
      <p>Drive through traffic, avoid collisions and collect points.</p>
      <p class="note">Use the on-screen buttons or your keyboard arrows.</p>
      <button class="action" id="startBtn">START RACE</button>
    </div>
  </div>
  <div class="overlay hidden" id="result">
    <div class="dialog">
      <h1 id="resultTitle">GAME OVER!</h1>
      <p>Your score: <b id="finalScore" style="color:#ffcf24">0</b></p>
      <button class="action" id="againBtn">↻ RESTART</button>
      <button class="action green" id="homeBtn">⌂ HOME</button>
    </div>
  </div>
</div>

<script type="module">
import * as THREE from 'three';

const mount = document.getElementById('view');
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x83cef3);
scene.fog = new THREE.Fog(0x83cef3, 45, 180);

const camera = new THREE.PerspectiveCamera(62, 1, 0.1, 250);
camera.position.set(0, 6.5, 11.5);
camera.lookAt(0, 0.7, -5);

const renderer = new THREE.WebGLRenderer({antialias:true, powerPreference:'high-performance'});
renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.7));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.outputColorSpace = THREE.SRGBColorSpace;
mount.appendChild(renderer.domElement);

scene.add(new THREE.HemisphereLight(0xffffff, 0x42604a, 2.0));
const sun = new THREE.DirectionalLight(0xffffff, 2.2);
sun.position.set(-8, 16, 8);
sun.castShadow = true;
sun.shadow.mapSize.set(1024,1024);
scene.add(sun);

function mat(color, roughness=0.8){return new THREE.MeshStandardMaterial({color,roughness});}
const roadMat=mat(0x30343d), grassMat=mat(0x39884c), lineMat=mat(0xffffff), darkMat=mat(0x15191e);
const road=new THREE.Mesh(new THREE.PlaneGeometry(13,220),roadMat);
road.rotation.x=-Math.PI/2; road.position.set(0,-0.06,-70); road.receiveShadow=true; scene.add(road);
const ground=new THREE.Mesh(new THREE.PlaneGeometry(180,240),grassMat);
ground.rotation.x=-Math.PI/2; ground.position.set(0,-0.12,-70); ground.receiveShadow=true; scene.add(ground);
const laneMarks=[];
for(let z=8;z>-210;z-=9){
  for(const x of [-2.15,2.15]){
    const m=new THREE.Mesh(new THREE.BoxGeometry(.13,.025,3.5),lineMat);
    m.position.set(x,.015,z); scene.add(m); laneMarks.push(m);
  }
}
for(const x of [-6.6,6.6]){
  const edge=new THREE.Mesh(new THREE.BoxGeometry(.18,.04,220),mat(0xf4f1df));
  edge.position.set(x,.01,-70);scene.add(edge);
}
const roadside=[];
function makeTree(x,z){
  const g=new THREE.Group();
  const trunk=new THREE.Mesh(new THREE.CylinderGeometry(.13,.2,1.6,6),mat(0x795034));
  trunk.position.y=.8;g.add(trunk);
  const crown=new THREE.Mesh(new THREE.ConeGeometry(1.05,2.5,7),mat(0x176b42));
  crown.position.y=2.45;g.add(crown);
  g.position.set(x,0,z);scene.add(g);roadside.push(g);
}
for(let z=12;z>-210;z-=12){makeTree(-9.5,z);makeTree(9.5,z-5);}

function makeCar(color=0xe82432){
  const group=new THREE.Group();
  const body=new THREE.Mesh(new THREE.BoxGeometry(1.65,.55,3.0),mat(color,.35));
  body.position.y=.72;body.castShadow=true;group.add(body);
  const hood=new THREE.Mesh(new THREE.BoxGeometry(1.5,.18,.85),mat(color,.3));
  hood.position.set(0,1.0,-.95);group.add(hood);
  const cabin=new THREE.Mesh(new THREE.BoxGeometry(1.18,.65,1.35),mat(0x9bd7ed,.25));
  cabin.position.set(0,1.25,.15);cabin.castShadow=true;group.add(cabin);
  const roof=new THREE.Mesh(new THREE.BoxGeometry(1.2,.12,1.38),mat(color,.35));
  roof.position.set(0,1.62,.15);group.add(roof);
  for(const x of [-.88,.88])for(const z of [-.95,.95]){
    const wheel=new THREE.Mesh(new THREE.CylinderGeometry(.34,.34,.22,12),darkMat);
    wheel.rotation.z=Math.PI/2;wheel.position.set(x,.42,z);group.add(wheel);
  }
  const tail=mat(0xff2525);
  for(const x of [-.53,.53]){
    const lamp=new THREE.Mesh(new THREE.BoxGeometry(.3,.15,.08),tail);
    lamp.position.set(x,.83,1.53);group.add(lamp);
  }
  return group;
}
const player=makeCar(0xe51f2b);player.position.set(0,0,5);scene.add(player);
const traffic=[];
const colors=[0xffc52e,0x1686e9,0xeceff4,0x21a66b,0x9c59d1];
function addTraffic(){
  const lane=[-3.9,0,3.9][Math.floor(Math.random()*3)];
  const car=makeCar(colors[Math.floor(Math.random()*colors.length)]);
  car.scale.setScalar(.92);car.position.set(lane,0,-105);scene.add(car);
  traffic.push(car);
}

let score=0,speed=80,elapsed=0,carX=0,spawnClock=0,roadMove=0;
let active=false,paused=false,ended=false,lastTime=0;
const input={left:false,right:false,gas:false,brake:false};
function reset(){
  traffic.forEach(c=>scene.remove(c));traffic.length=0;
  score=0;speed=80;elapsed=0;carX=0;spawnClock=.7;roadMove=0;
  player.position.x=0;player.rotation.z=0;
  active=true;paused=false;ended=false;
  document.getElementById('start').classList.add('hidden');
  document.getElementById('result').classList.add('hidden');
  document.getElementById('pauseBtn').textContent='Ⅱ';
  Object.keys(input).forEach(k=>input[k]=false);
}
function finish(title='GAME OVER!'){
  active=false;ended=true;
  document.getElementById('resultTitle').textContent=title;
  document.getElementById('finalScore').textContent=Math.floor(score);
  document.getElementById('result').classList.remove('hidden');
}
function pauseToggle(){
  if(!active||ended)return;
  paused=!paused;
  document.getElementById('pauseBtn').textContent=paused?'▶':'Ⅱ';
  if(paused)finishPause();else document.getElementById('result').classList.add('hidden');
}
function finishPause(){
  document.getElementById('resultTitle').textContent='PAUSED';
  document.getElementById('finalScore').textContent=Math.floor(score);
  document.getElementById('result').classList.remove('hidden');
}
document.getElementById('startBtn').onclick=reset;
document.getElementById('againBtn').onclick=reset;
document.getElementById('homeBtn').onclick=()=>{
  active=false;paused=false;ended=false;
  document.getElementById('result').classList.add('hidden');
  document.getElementById('start').classList.remove('hidden');
};
document.getElementById('pauseBtn').onclick=pauseToggle;

document.querySelectorAll('[data-key]').forEach(btn=>{
  const k=btn.dataset.key;
  const down=e=>{e.preventDefault();input[k]=true;btn.classList.add('active');};
  const up=e=>{e.preventDefault();input[k]=false;btn.classList.remove('active');};
  btn.addEventListener('pointerdown',down);
  ['pointerup','pointercancel','pointerleave'].forEach(ev=>btn.addEventListener(ev,up));
});
const keyMap={ArrowLeft:'left',ArrowRight:'right',ArrowUp:'gas',ArrowDown:'brake'};
window.addEventListener('keydown',e=>{if(keyMap[e.key]){e.preventDefault();input[keyMap[e.key]]=true;}if(e.key==='Escape'||e.key==='p')pauseToggle();});
window.addEventListener('keyup',e=>{if(keyMap[e.key])input[keyMap[e.key]]=false;});
window.addEventListener('blur',()=>Object.keys(input).forEach(k=>input[k]=false));

function update(dt){
  if(!active||paused||ended)return;
  elapsed+=dt;
  speed=THREE.MathUtils.clamp(speed+(input.gas?75:input.brake?-115:8)*dt,45,230);
  if(input.left)carX-=5.2*dt;
  if(input.right)carX+=5.2*dt;
  carX=THREE.MathUtils.clamp(carX,-4.7,4.7);
  player.position.x=THREE.MathUtils.damp(player.position.x,carX,.18,dt);
  player.rotation.z=THREE.MathUtils.damp(player.rotation.z,(input.left?.16:input.right?-.16:0),.15,dt);
  const flow=dt*(7+speed*.075);
  roadMove+=flow;
  laneMarks.forEach(m=>{m.position.z+=flow;if(m.position.z>12)m.position.z=-210;});
  roadside.forEach(t=>{t.position.z+=flow;if(t.position.z>15)t.position.z=-210;});
  spawnClock-=dt;
  if(spawnClock<=0){addTraffic();spawnClock=Math.max(.58,1.45-speed/280);}
  for(let i=traffic.length-1;i>=0;i--){
    const car=traffic[i];car.position.z+=flow*1.25;
    if(Math.abs(car.position.x-player.position.x)<1.35 && Math.abs(car.position.z-player.position.z)<2.25){finish();return;}
    if(car.position.z>13){scene.remove(car);traffic.splice(i,1);score+=100;}
  }
  score+=dt*speed*.25;
  document.getElementById('score').textContent=Math.floor(score);
  document.getElementById('speed').textContent=Math.round(speed);
  document.getElementById('timer').textContent=String(Math.floor(elapsed/60)).padStart(2,'0')+':'+String(Math.floor(elapsed%60)).padStart(2,'0');
}
function render(ts){
  const dt=Math.min((ts-lastTime)/1000||0,.05);lastTime=ts;
  update(dt);
  renderer.render(scene,camera);
  requestAnimationFrame(render);
}
function onResize(){
  const w=mount.clientWidth,h=mount.clientHeight;
  camera.aspect=w/h;camera.updateProjectionMatrix();renderer.setSize(w,h,false);
}
window.addEventListener('resize',onResize);onResize();
requestAnimationFrame(render);
</script>
</body>
</html>

