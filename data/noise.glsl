#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2 resolution;
uniform float time;
uniform float duration;

uniform vec3 c1;
uniform vec3 c2;
uniform vec3 c3;
uniform vec3 c4;

uniform float c2value;
uniform float c3value;

uniform float scale;
uniform float scale1;
uniform float scale2;

uniform float seed;
uniform float timescale;

uniform float radius;

#define TAU 6.28318530718

// -------------------- HASH 4D --------------------
float hash(vec4 p) {
  p += vec4(seed, seed*1.37, seed*2.17, seed*3.11);
  return fract(sin(dot(p, vec4(127.1,311.7,74.7,199.9))) * 43758.5453);
}

// -------------------- NOISE 4D --------------------
float noise(vec4 p) {
  vec4 i = floor(p);
  vec4 f = fract(p);

  vec4 u = f*f*(3.0-2.0*f);

  float n0000 = hash(i + vec4(0,0,0,0));
  float n1000 = hash(i + vec4(1,0,0,0));
  float n0100 = hash(i + vec4(0,1,0,0));
  float n1100 = hash(i + vec4(1,1,0,0));
  float n0010 = hash(i + vec4(0,0,1,0));
  float n1010 = hash(i + vec4(1,0,1,0));
  float n0110 = hash(i + vec4(0,1,1,0));
  float n1110 = hash(i + vec4(1,1,1,0));

  float n0001 = hash(i + vec4(0,0,0,1));
  float n1001 = hash(i + vec4(1,0,0,1));
  float n0101 = hash(i + vec4(0,1,0,1));
  float n1101 = hash(i + vec4(1,1,0,1));
  float n0011 = hash(i + vec4(0,0,1,1));
  float n1011 = hash(i + vec4(1,0,1,1));
  float n0111 = hash(i + vec4(0,1,1,1));
  float n1111 = hash(i + vec4(1,1,1,1));

  float x00 = mix(n0000, n1000, u.x);
  float x10 = mix(n0100, n1100, u.x);
  float x01 = mix(n0010, n1010, u.x);
  float x11 = mix(n0110, n1110, u.x);

  float y0 = mix(x00, x10, u.y);
  float y1 = mix(x01, x11, u.y);

  float z0 = mix(y0, y1, u.z);

  float x00b = mix(n0001, n1001, u.x);
  float x10b = mix(n0101, n1101, u.x);
  float x01b = mix(n0011, n1011, u.x);
  float x11b = mix(n0111, n1111, u.x);

  float y0b = mix(x00b, x10b, u.y);
  float y1b = mix(x01b, x11b, u.y);

  float z1 = mix(y0b, y1b, u.z);

  return mix(z0, z1, u.w);
}

// -------------------- FBM --------------------
float fbm(vec4 p) {
  float v = 0.0;
  float a = 0.5;

  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p *= 2.0;
    a *= 0.5;
  }

  return v;
}

// -------------------- MAIN --------------------
void main() {
  vec2 uv = gl_FragCoord.xy / resolution.xy;

  // --- LOOPING TIME ---
  float angle = time * TAU / duration;
  vec2 loop = vec2(cos(angle), sin(angle));

  // --- BASE POSITION (4D) ---
  vec4 p = vec4(
    uv * resolution.xy * scale,
    loop * radius
  );

  // --- DOMAIN WARP ---
  vec2 q = vec2(
    fbm(p + vec4(0.0, 0.0, 0.0, 0.0)),
    fbm(p + vec4(5.2, 1.3, 0.0, 0.0))
  ) * scale1;

  vec4 pq = p + vec4(q, 0.0, 0.0);

  vec2 r = vec2(
    fbm(pq + vec4(1.7, 9.2, 0.0, 0.0)),
    fbm(pq + vec4(8.3, 2.8, 0.0, 0.0))
  ) * scale2;

  float t = fbm(p + vec4(r, 0.0, 0.0));
  t *= t * t;

  float t1 = clamp(t * 1 / c2value, 0.0, 1.0);
  float t2 = clamp((t - c2value) / (c3value - c2value), 0.0, 1.0);
  float t3 = clamp((t - c3value) / (1 - c3value), 0.0, 1.0);

  vec3 col = mix(mix(mix(c1, c2, t1), c3, t2), c4, t3);

  gl_FragColor = vec4(col, 1.0);
}