---
name: shader-prototyping
description: >
  Prototype WebGL/Three.js/R3F shader effects for marketing sites — displacement, ripple,
  texture capture, and GLSL patterns. Use when asked about "shader", "displacement",
  "ripple effect", "vertex displacement", "GLSL", "Three.js shader", "R3F shader",
  "html2canvas texture", or "WebGL effect".
---

# Shader Prototyping

Rapid prototyping workflow for WebGL shader effects using Three.js, React Three Fiber (R3F), and Framer Motion layering.

## Prototyping Flow

### 1. Clarify the Effect Goal

- What visual result is expected (ripple, distortion, glow, morph, noise field)?
- Which surface or geometry receives the effect (plane, sphere, custom mesh)?
- What triggers the effect (time, scroll, mouse hover, click, page load)?
- Is it full-viewport background or localized to an element?

### 2. Choose Approach

| Approach | When to Use |
| --- | --- |
| Raw Three.js | Vanilla JS project, no React, maximum control |
| R3F (`@react-three/fiber`) | React project, component-based, hooks for animation |
| R3F + Framer Motion layering | Marketing page with 3D background + animated 2D overlay |

### 3. Implement Shader

Write vertex and fragment shaders using patterns from the reference files. Start minimal — get something on screen, then iterate.

### 4. Wire Uniforms and Animate

- Pass time, mouse, resolution, and custom values as uniforms
- Use `useFrame` for per-frame updates in R3F
- Bridge Framer Motion spring values to shader uniforms when layering

### 5. Test, Iterate, Optimize

- Dispose geometry, materials, and textures on cleanup
- Profile on mobile devices — reduce segment count or disable effect if GPU budget is exceeded
- Check for WebGL context loss handling

## Reference Index

| Reference | Covers |
| --- | --- |
| [Displacement Effects](references/displacement-effects.md) | Vertex displacement, ripple formula, mouse-driven effects, geometry subdivision |
| [R3F + Framer Motion](references/r3f-framer-motion.md) | Canvas/overlay layering, pointer forwarding, spring bridging, motion meshes |
| [Texture Pipeline](references/texture-pipeline.md) | html2canvas capture, CanvasTexture, CORS, DataTexture, caching |
| [GLSL Patterns](references/glsl-patterns.md) | Standard uniforms/varyings, math helpers, noise, debugging techniques |

## Rules

### Uniform Naming

Always use the `u_` prefix for uniforms: `u_time`, `u_resolution`, `u_mouse`, `u_texture`, `u_amplitude`, etc. This distinguishes uniforms from varyings and locals at a glance.

### Resource Disposal

Always dispose geometry, material, and textures in cleanup. In R3F, return a cleanup function from `useEffect`. In vanilla Three.js, call `.dispose()` on unmount or when replacing resources. Leaked GPU resources cause memory growth and eventual context loss.

### Geometry Subdivision

Displacement shaders require adequate geometry subdivision to produce visible results. A `PlaneGeometry` with only 1x1 segments has 4 vertices — no amount of shader math will create a smooth ripple. Use a minimum of 64x64 segments for visible ripple/wave effects. Higher counts (128x128, 256x256) produce smoother results but cost more.

### Mobile Performance

Test on actual mobile hardware. Strategies for mobile:
- Reduce segment count (32x32 instead of 128x128)
- Lower the rendering resolution with `dpr={[1, 1.5]}` on the R3F Canvas
- Disable the effect entirely behind a `matchMedia` or GPU capability check
- Avoid `highp` precision in fragment shaders when `mediump` suffices

### Community Skills

For foundational Three.js and WebGPU knowledge, see:
- [CloudAI-X/threejs-skills](https://github.com/CloudAI-X/threejs-skills) — general Three.js patterns and scene setup
- [dgreenheck/webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill) — WebGPU compute and render pipeline fundamentals

This skill covers the displacement, R3F integration, and Framer Motion layering niche that those skills do not address.

## Documentation Sources

Key references backing this skill's patterns:

- [Three.js ShaderMaterial](https://threejs.org/docs/#api/en/materials/ShaderMaterial) — built-in uniforms, attributes, and shader integration
- [Three.js PlaneGeometry](https://threejs.org/docs/#api/en/geometries/PlaneGeometry) — segment subdivision parameters
- [Three.js Texture](https://threejs.org/docs/#api/en/textures/Texture) — needsUpdate, dispose, filter modes
- [React Three Fiber](https://r3f.docs.pmnd.rs/getting-started/introduction) — R3F core docs
- [@react-three/drei shaderMaterial](https://drei.docs.pmnd.rs/shaders/shader-material) — declarative custom shaders in R3F
- [Motion for React Three Fiber](https://motion.dev/docs/react-three-fiber) — framer-motion-3d (now part of main motion package)
- [Motion docs](https://motion.dev/docs) — useMotionValue, useSpring, animation API
- [@react-spring/three](https://react-spring.dev/docs/guides/react-three-fiber) — spring physics for 3D
- [html2canvas](https://html2canvas.hertzen.com/) — DOM-to-canvas capture
- [Khronos GLSL ES 3.0 Reference](https://registry.khronos.org/OpenGL-Refpages/es3.0/) — built-in function specs
- [The Book of Shaders](https://thebookofshaders.com/) — GLSL fundamentals and noise
- [lygia shader library](https://lygia.xyz/) — production noise and generative functions
- [Shadertoy](https://www.shadertoy.com) — community shader examples and inspiration
- [WebGL Fundamentals](https://webglfundamentals.org/webgl/lessons/webgl-shaders-and-glsl.html) — vertex/fragment shader basics
