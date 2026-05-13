PShader shader;

color c1 = #061826; // Midnight Abyss
color c2 = #0D3B66; // Deep Ocean Blue
color c3 = #3A86C8; // Moonlit Azure
color c4 = #A9D6E5; //Frost Blue

float c2value = 0.2;
float c3value = 0.5;

float scale = 0.004;
float scale1 = 4.0;
float scale2 = 4.0;

float duration = 4.0;
float fps = 60;

float radius = 0.5;

PGraphics bg;

int renderW = 1440;
int renderH = 3136;

void setup() {
  //fullScreen(P2D);
  size(200, 200, P2D);
  
  int seed = (int)random(16777216);
  //seed = 11511244;
  println(seed);
  
  shader = loadShader("noise.glsl");

  shader.set("resolution", (float)renderW, (float)renderH);

  shader.set("c1", red(c1)/255.0, green(c1)/255.0, blue(c1)/255.0);
  shader.set("c2", red(c2)/255.0, green(c2)/255.0, blue(c2)/255.0);
  shader.set("c3", red(c3)/255.0, green(c3)/255.0, blue(c3)/255.0);
  shader.set("c4", red(c4)/255.0, green(c4)/255.0, blue(c4)/255.0);
  shader.set("c2value", c2value);
  shader.set("c3value", c3value);

  shader.set("scale", scale);
  shader.set("scale1", scale1);
  shader.set("scale2", scale2);
  
  shader.set("seed", seed);
  
  shader.set("duration", duration);
  shader.set("radius", radius);
  
  bg = createGraphics(renderW, renderH, P2D);
}

void draw() {
  if (frameCount <= duration * fps)
    shader.set("time", customEase(frameCount / fps / duration) * duration);
  else
    shader.set("time", duration);
  
  bg.beginDraw();
  bg.shader(shader);
  bg.noStroke();
  bg.rect(0, 0, renderW, renderH);
  bg.endDraw();
  image(bg, 0, 0, width, height);
  bg.save("frames/frame-" + nf(frameCount, 4) + ".png");
  if (frameCount >= duration * fps) {
    exit();
  }
}

float inFactor = 1.5;
float outFactor = 5;

float customEase (float x) {
  return (1 - x) * pow(x, inFactor) + x - x * pow(1 - x, outFactor);
}

/*
void setup () {
  fullScreen();
  pixelDensity(displayDensity());
  noiseSeed(seed);
}

void draw () {
  PVector p = new PVector();
  PVector q = new PVector();
  PVector r = new PVector();
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      //float scale0 = lerp(scale * 2, scale, (float)y / height);
      float ax = x * scale;
      float ay = y * scale;
      p.set(ax, ay);
      q.set(fbm(p.copy().add(0, 0)),
            fbm(p.copy().add(5, 1)));
      q.mult(scale1);
      r.set(fbm(p.copy().add(q).add(1, 5)),
            fbm(p.copy().add(q).add(7, 3)));
      r.mult(scale2);
      float t = fbm(p.add(r));
      t *= t*t;
      pixels[x + y * width] = lerpColor(lerpColor(lerpColor(c1, c2, t), c3, 1 - r.y), c4, 1 - q.y);
    }
  }
  updatePixels();
}

float fbm(PVector p) {
  return noise(p.x, p.y);
}
*/
