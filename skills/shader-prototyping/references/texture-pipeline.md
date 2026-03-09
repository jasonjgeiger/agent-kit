# Texture Pipeline

Workflows for capturing DOM content as textures, creating procedural textures, and feeding them into shaders.

## html2canvas to CanvasTexture Workflow

The pipeline: render a DOM element to a canvas bitmap with `html2canvas`, wrap it in a `THREE.CanvasTexture`, and pass it to a shader as a uniform sampler.

### Step-by-Step

```javascript
import html2canvas from 'html2canvas';
import * as THREE from 'three';

async function captureElementAsTexture(element) {
  // Step 1: Render DOM element to canvas
  const canvas = await html2canvas(element, {
    useCORS: true,       // attempt to load cross-origin images
    scale: 2,            // 2x resolution for retina
    backgroundColor: null // transparent background
  });

  // Step 2: Create Three.js texture from the captured canvas
  const texture = new THREE.CanvasTexture(canvas);
  texture.needsUpdate = true;

  // Step 3: Configure texture parameters
  texture.minFilter = THREE.LinearFilter;
  texture.magFilter = THREE.LinearFilter;
  texture.format = THREE.RGBAFormat;

  return texture;
}
```

### Using the Texture in a Shader

```glsl
// Fragment shader
uniform sampler2D u_texture;
varying vec2 vUv;

void main() {
  vec4 texColor = texture2D(u_texture, vUv);
  gl_FragColor = texColor;
}
```

### Updating When DOM Changes

When the source DOM element updates (content changes, animations), recapture:

```javascript
async function updateTexture(element, existingTexture) {
  const canvas = await html2canvas(element, { useCORS: true, scale: 2 });

  // Update the existing texture's image source
  existingTexture.image = canvas;
  existingTexture.needsUpdate = true;
}
```

Do not recreate the texture object — update `image` and set `needsUpdate = true` to avoid GPU memory churn.

## Async Capture

`html2canvas` returns a Promise. The texture is not available until the capture completes. Handle this in R3F:

```tsx
import { useEffect, useRef, useState } from 'react';
import { useFrame } from '@react-three/fiber';
import html2canvas from 'html2canvas';
import * as THREE from 'three';

function DomTexturePlane({ sourceRef }) {
  const [texture, setTexture] = useState(null);
  const uniformsRef = useRef({
    u_texture: { value: null },
    u_time: { value: 0 },
  });

  useEffect(() => {
    if (!sourceRef.current) return;

    let disposed = false;

    async function capture() {
      const canvas = await html2canvas(sourceRef.current, {
        useCORS: true,
        scale: 2,
      });

      if (disposed) return;

      const tex = new THREE.CanvasTexture(canvas);
      tex.minFilter = THREE.LinearFilter;
      tex.needsUpdate = true;

      uniformsRef.current.u_texture.value = tex;
      setTexture(tex);
    }

    capture();

    return () => {
      disposed = true;
      if (uniformsRef.current.u_texture.value) {
        uniformsRef.current.u_texture.value.dispose();
      }
    };
  }, [sourceRef]);

  useFrame((state) => {
    uniformsRef.current.u_time.value = state.clock.elapsedTime;
  });

  if (!texture) return null;

  return (
    <mesh>
      <planeGeometry args={[4, 3, 1, 1]} />
      <shaderMaterial
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={uniformsRef.current}
      />
    </mesh>
  );
}
```

## CORS Gotchas

`html2canvas` renders the DOM by reading computed styles and drawing to a canvas. Cross-origin resources cause problems:

### Problem: External Images

Images from different origins taint the canvas, making it unreadable. `html2canvas` will either skip them or produce a blank area.

### Solutions

1. **`useCORS: true`** — tells html2canvas to attempt loading images with CORS headers. The server must respond with `Access-Control-Allow-Origin`.

2. **Proxy** — route external images through your own server:
   ```javascript
   html2canvas(element, {
     proxy: '/api/html2canvas-proxy',
     useCORS: true,
   });
   ```

3. **Pre-load as base64** — fetch images server-side, convert to data URIs, and embed them in the DOM before capture:
   ```javascript
   const response = await fetch('/api/proxy-image?url=' + encodeURIComponent(imageUrl));
   const blob = await response.blob();
   const dataUrl = await blobToDataURL(blob);
   imgElement.src = dataUrl; // Now it is same-origin
   ```

4. **Inline SVG** — for vector content, use inline SVG instead of external files.

## Texture Caching

Creating textures is expensive. Cache and reuse:

```javascript
const textureCache = new Map();

async function getCachedTexture(element, cacheKey) {
  if (textureCache.has(cacheKey)) {
    return textureCache.get(cacheKey);
  }

  const texture = await captureElementAsTexture(element);
  textureCache.set(cacheKey, texture);
  return texture;
}

// Invalidate when content changes
function invalidateTexture(cacheKey) {
  const texture = textureCache.get(cacheKey);
  if (texture) {
    texture.dispose();
    textureCache.delete(cacheKey);
  }
}
```

Rules:
- Do not recreate textures every frame — capture once, update only on content change
- Dispose textures when they are no longer needed
- Use a cache key that reflects the content state (hash, version counter, etc.)

## DataTexture for Procedural Generation

When you need a texture from computed data rather than DOM content:

```javascript
const width = 256;
const height = 256;
const data = new Uint8Array(width * height * 4);

// Fill with procedural pattern
for (let y = 0; y < height; y++) {
  for (let x = 0; x < width; x++) {
    const i = (y * width + x) * 4;
    data[i]     = (x / width) * 255;       // R
    data[i + 1] = (y / height) * 255;      // G
    data[i + 2] = 128;                      // B
    data[i + 3] = 255;                      // A
  }
}

const texture = new THREE.DataTexture(data, width, height, THREE.RGBAFormat);
texture.needsUpdate = true;
```

Use cases:
- Noise lookup tables (bake Perlin/Simplex noise into a texture for faster shader reads)
- Gradient ramps for color mapping displacement values
- Audio visualization data (pass frequency bins as a 1D texture)

Update a DataTexture per-frame by modifying the `data` array and setting `needsUpdate = true`. This is cheaper than html2canvas but still not free — avoid unnecessary updates.

## References

- [html2canvas](https://html2canvas.hertzen.com/)
- [html2canvas configuration](https://html2canvas.hertzen.com/configuration)
- [html2canvas GitHub](https://github.com/niklasvh/html2canvas)
- [Three.js CanvasTexture](https://threejs.org/docs/#api/en/textures/CanvasTexture)
- [Three.js DataTexture](https://threejs.org/docs/#api/en/textures/DataTexture)
- [Three.js Texture (dispose, needsUpdate)](https://threejs.org/docs/#api/en/textures/Texture)
