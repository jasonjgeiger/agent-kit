# GLSL Patterns

Common uniforms, varyings, math helpers, noise functions, and debugging techniques for Three.js shader development.

## Standard Uniforms

```glsl
uniform float u_time;          // Elapsed time in seconds (from useFrame clock)
uniform vec2  u_resolution;    // Viewport width and height in pixels
uniform vec2  u_mouse;         // Normalized mouse position (0..1 or -1..1)
uniform sampler2D u_texture;   // Input texture (DOM capture, image, data)
uniform float u_amplitude;     // Effect strength (displacement, intensity)
uniform float u_frequency;     // Wave/pattern frequency
uniform float u_speed;         // Animation speed multiplier
```

Three.js also provides built-in uniforms automatically:
- `projectionMatrix` — camera projection
- `modelViewMatrix` — combined model and view transform
- `normalMatrix` — inverse transpose of modelView (for normals)
- `cameraPosition` — world-space camera position

## Standard Varyings

Pass data from vertex to fragment shader:

```glsl
// Vertex shader
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying float vDisplacement;

void main() {
  vUv = uv;                                    // UV coordinates (built-in attribute)
  vNormal = normalize(normalMatrix * normal);   // Transform normal to view space
  vPosition = (modelMatrix * vec4(position, 1.0)).xyz; // World position

  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
```

```glsl
// Fragment shader
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying float vDisplacement;

void main() {
  // Use varyings for lighting, texturing, coloring
  gl_FragColor = vec4(vNormal * 0.5 + 0.5, 1.0);
}
```

## Math Helpers

### Built-in Functions

```glsl
smoothstep(edge0, edge1, x)   // Hermite interpolation: 0 when x <= edge0, 1 when x >= edge1
mix(a, b, t)                   // Linear interpolation: a * (1-t) + b * t
clamp(x, minVal, maxVal)       // Constrain x to [minVal, maxVal]
fract(x)                       // Fractional part: x - floor(x)
step(edge, x)                  // 0.0 if x < edge, 1.0 otherwise
abs(x)                         // Absolute value
sign(x)                        // -1.0, 0.0, or 1.0
mod(x, y)                      // Modulus: x - y * floor(x/y)
length(v)                      // Vector magnitude
distance(a, b)                 // Distance between two points
normalize(v)                   // Unit vector
dot(a, b)                      // Dot product
cross(a, b)                    // Cross product (vec3 only)
reflect(I, N)                  // Reflection vector
refract(I, N, eta)             // Refraction vector
```

### Remap Function

Map a value from one range to another:

```glsl
float remap(float value, float inMin, float inMax, float outMin, float outMax) {
  return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin);
}
```

Usage: `float brightness = remap(vDisplacement, -1.0, 1.0, 0.2, 1.0);`

### Rotation Matrix (2D)

```glsl
mat2 rotate2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

// Usage: rotate UV coordinates
vec2 rotatedUv = rotate2D(u_time * 0.5) * (vUv - 0.5) + 0.5;
```

### Polar Coordinates

```glsl
vec2 toPolar(vec2 uv) {
  vec2 centered = uv - 0.5;
  float angle = atan(centered.y, centered.x);
  float radius = length(centered);
  return vec2(angle, radius);
}
```

## Noise Functions

For production noise, use the [lygia shader library](https://lygia.xyz/) ([GitHub](https://github.com/patriciogonzalezvivo/lygia)) which provides tested implementations of Simplex, Perlin, Worley, and other noise types. Include via:

```glsl
// If using lygia via imports (requires build tool support)
#include "lygia/generative/snoise.glsl"
```

### Inline 2D Simplex Noise

When you cannot use external includes, here is a self-contained 2D simplex noise:

```glsl
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x * 34.0) + 10.0) * x); }

float snoise(vec2 v) {
  const vec4 C = vec4(
    0.211324865405187,   // (3.0 - sqrt(3.0)) / 6.0
    0.366025403784439,   // 0.5 * (sqrt(3.0) - 1.0)
   -0.577350269189626,   // -1.0 + 2.0 * C.x
    0.024390243902439    // 1.0 / 41.0
  );

  vec2 i  = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);

  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  i = mod289(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));

  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;

  return 130.0 * dot(m, g);
}
```

Usage:
```glsl
float n = snoise(vUv * 10.0 + u_time * 0.5); // Animated noise pattern
float fbm = snoise(p) * 0.5 + snoise(p * 2.0) * 0.25 + snoise(p * 4.0) * 0.125; // Fractal Brownian motion
```

## Debugging Techniques

### Visualize Values as Color

The simplest way to debug a shader is to output the value you are investigating as a color:

```glsl
// Visualize UV coordinates — should show red/green gradient
gl_FragColor = vec4(vUv, 0.0, 1.0);

// Visualize normals — should show smooth RGB sphere-like coloring
gl_FragColor = vec4(vNormal * 0.5 + 0.5, 1.0);

// Visualize world position
gl_FragColor = vec4(fract(vPosition * 0.1), 1.0);

// Visualize a float value as grayscale
float val = vDisplacement;
gl_FragColor = vec4(vec3(val * 0.5 + 0.5), 1.0);

// Visualize a float with heatmap (blue=low, red=high)
float t = clamp(val * 0.5 + 0.5, 0.0, 1.0);
gl_FragColor = vec4(t, 0.0, 1.0 - t, 1.0);
```

### Cycle Values with Time

Use `sin(u_time)` to sweep a parameter and watch how the output changes:

```glsl
float testVal = sin(u_time) * 0.5 + 0.5; // oscillates 0..1
gl_FragColor = vec4(vec3(testVal), 1.0);
```

This reveals discontinuities, clamping issues, and unexpected ranges.

### Check for NaN

NaN in shaders produces black or garbage pixels. Detect it with the self-inequality trick:

```glsl
if (value != value) {
  // value is NaN
  gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0); // Magenta = NaN detected
  return;
}
```

Common NaN sources:
- `normalize(vec3(0.0))` — normalizing a zero vector
- `sqrt(negative)` — square root of a negative number
- `0.0 / 0.0` — division of zero by zero
- `acos(value)` when `value` is outside [-1, 1] due to floating point drift

### Step-Through with Preprocessor

Use `#define` flags to toggle sections of your shader for isolation:

```glsl
#define DEBUG_UV 0
#define DEBUG_NORMAL 0
#define DEBUG_DISPLACEMENT 1

void main() {
  #if DEBUG_UV
    gl_FragColor = vec4(vUv, 0.0, 1.0); return;
  #endif
  #if DEBUG_NORMAL
    gl_FragColor = vec4(vNormal * 0.5 + 0.5, 1.0); return;
  #endif
  #if DEBUG_DISPLACEMENT
    gl_FragColor = vec4(vec3(vDisplacement * 0.5 + 0.5), 1.0); return;
  #endif

  // Normal rendering code below
  // ...
}
```

## References

- [Khronos GLSL ES 3.0 Reference](https://registry.khronos.org/OpenGL-Refpages/es3.0/)
- [Three.js ShaderMaterial — built-in uniforms](https://threejs.org/docs/#api/en/materials/ShaderMaterial)
- [The Book of Shaders](https://thebookofshaders.com/)
- [The Book of Shaders — Noise](https://thebookofshaders.com/11/)
- [lygia shader library](https://lygia.xyz/) · [GitHub](https://github.com/patriciogonzalezvivo/lygia)
- [Shadertoy](https://www.shadertoy.com)
