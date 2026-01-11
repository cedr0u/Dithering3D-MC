# Dither3D Technical Reference

## Algorithm Overview

Surface-stable fractal dithering achieves constant screen-space dot density while maintaining surface coherence. This is accomplished through:

1. **SVD-based frequency analysis** of UV derivatives
2. **Fractal layer selection** from multi-scale 3D Bayer texture
3. **Anisotropic smoothing** to prevent stretched dots
4. **Radial compensation** for camera rotation stability

---

## Mathematical Foundation

### 1. UV Frequency Computation

The core insight is that surface frequency (cycles per pixel) can be derived from the Jacobian matrix of UV coordinates:

```
J = [∂u/∂x  ∂u/∂y]
    [∂v/∂x  ∂v/∂y]
```

In GLSL, we obtain this via derivatives:
```glsl
vec2 du = dFdx(texcoord);  // (∂u/∂x, ∂v/∂x)
vec2 dv = dFdy(texcoord);  // (∂u/∂y, ∂v/∂y)
```

#### Eigenvalue Analysis

We compute eigenvalues of J^T · J (symmetric positive-definite matrix):

```
J^T · J = [du·du  du·dv]
          [du·dv  dv·dv]
```

Eigenvalues:
```
λ₁, λ₂ = (trace ± √(trace² - 4·det)) / 2
```

Where:
- `trace = du·du + dv·dv`
- `det = (du·du)(dv·dv) - (du·dv)²`

#### Frequency Metrics

- **Frequency** (cycles/pixel): `sqrt(√(λ₁·λ₂))` (geometric mean)
- **Stretch** (anisotropy): `√(λ₁/λ₂)` (aspect ratio)

**Why geometric mean?** Preserves perceptual uniformity under rotation and scaling.

---

### 2. Fractal Layer Selection

Given frequency `f`, we select the appropriate Bayer matrix layer:

```glsl
float layer = log2(spacing / f) / log2(bayer_size);
```

Where:
- `spacing`: Target dot spacing in pixels (from DITHER_DOT_SCALE)
- `bayer_size`: Bayer matrix dimension (2, 4, 8, etc.)

**Fractional layers:** Interpolate between discrete Bayer levels for smooth transitions.

#### Example (64×64×512 texture, 8×8 Bayer basis):

| Surface Distance | Frequency | Layer Index | Bayer Used |
|------------------|-----------|-------------|------------|
| 1 m | 64 cycles/px | 0.0 | Base pattern |
| 10 m | 6.4 cycles/px | 3.3 | Interpolated |
| 100 m | 0.64 cycles/px | 6.6 | Coarsest |

**Quantization option:** `DITHER_QUANTIZE_LAYERS` rounds layer to integer, preventing dot morphing at cost of visible transitions.

---

### 3. Anisotropic Smoothing

Stretched UVs (high `stretch` ratio) cause elongated dots. We counter this by:

1. **Compute stretch direction** (eigenvector of max eigenvalue)
2. **Blur orthogonally** to stretch axis

```glsl
float smoothFactor = mix(1.0, stretch, DITHER_STRETCH_SMOOTH);
vec2 blurDir = normalize(vec2(-du.y, du.x));  // Perpendicular to stretch
uv += blurDir * (smoothFactor - 1.0) * 0.5 / frequency;
```

**Effect:** Dots remain circular even on oblique surfaces.

---

### 4. Radial Compensation

Camera rotation causes world-space dots to shift in screen space. We compensate by:

1. **Project screen position to sphere** around camera
2. **Compute rotation angle** from sphere center
3. **Counter-rotate dot pattern** by same angle

```glsl
vec2 screenNorm = screenPos.xy / screenPos.w;  // NDC
float angle = atan(screenNorm.y, screenNorm.x);
uv = rotateUV(uv, -angle);
```

**Limitation:** Only corrects for rotation around view axis (roll). Full 3D rotation requires quaternions (expensive).

**Toggle:** `DITHER_RADIAL_COMP` can disable for stationary cameras (performance gain).

---

## Color Modes

### Grayscale (Mode 0)
Single luminance channel:
```glsl
float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));  // Rec.601
float dither = getDither3D(uv, screenPos, du, dv, luma);
color.rgb = vec3(dither);
```

### RGB (Mode 1)
Independent per-channel dithering:
```glsl
for (int i = 0; i < 3; i++) {
    color[i] = getDither3D(uv, screenPos, du, dv, color[i]);
}
```

**Issue:** Color shifts (e.g., red → magenta if G/B channels both round up).

**Fix:** Use CMYK for accurate color reproduction.

### CMYK (Mode 2)
Simulates halftone printing with rotated screens:

| Channel | Rotation | Rationale |
|---------|----------|-----------|
| Cyan | 15° | Avoid moiré with Magenta |
| Magenta | 75° | Maximum separation from Cyan |
| Yellow | 0° | Least visible to eye (lighter) |
| Black | 45° | Classic newspaper angle |

```glsl
vec4 cmyk = rgbToCMYK(color.rgb);
vec2 uv_c = rotateUV(uv, radians(15.0));
vec2 uv_m = rotateUV(uv, radians(75.0));
// ... dither each channel with rotated UV
color.rgb = cmykToRGB(cmyk_dithered);
```

**Result:** Authentic halftone patterns, no color distortion.

---

## Texture Format

### 3D Bayer Texture

**Dimensions:** `size × size × layers`
- `size`: Base Bayer matrix dimension (8, 16, 32, 64)
- `layers`: Fractal octaves (typically 8–512)

**Encoding:** Grayscale, uint8 (0–255)

**Generation:**
1. Recursive Bayer subdivision (see `generate_textures.py`)
2. Radial gradient overlay for smooth gradations
3. Normalize to [0, 1] range

**File format:**
- `.raw`: Binary, ZYX order (fastest, but not portable)
- `.png` atlas: Layers arranged in grid (compatible with all loaders)
- Procedural: Compute Bayer on-the-fly (no files, but slower)

### Brightness Ramp Texture

**Purpose:** Map dithered values to final brightness via CDF of histogram.

**Why?** Ensures 50% brightness input → 50% pixel coverage (perceptual uniformity).

**Dimensions:** 1D, 256 samples

**Encoding:** Grayscale, uint8

**Generation:**
1. Render all 3D texture values into histogram
2. Compute cumulative distribution function (CDF)
3. Store CDF as lookup table

**Usage:**
```glsl
float raw = texture(dither3DTex, uvw).r;
float remapped = texture(ditherRampTex, vec2(raw, 0.5)).r;
```

---

## Performance Considerations

### Bottlenecks

1. **3D texture sampling** (8–16 samples per fragment in CMYK mode)
   - **Mitigation:** Use lower-resolution textures (32×32×256 vs 64×64×512)
   
2. **SVD frequency computation** (per-fragment math)
   - **Mitigation:** Pre-compute at lower LOD, share across nearby pixels
   
3. **Screen-space derivatives** (`dFdx`/`dFdy`)
   - **Mitigation:** Unavoidable, but modern GPUs handle well

### Optimization Strategies

#### Low-End GPUs (Integrated)
```glsl
#define DITHER_DOT_SCALE 3.0        // Larger dots = fewer layers
#define DITHER_STRETCH_SMOOTH 0.5   // Less anisotropic correction
#define RENDER_STYLE 1              // Grayscale only (3× faster)
#define DITHER_RADIAL_COMP false    // Skip rotation compensation
```

#### High-End GPUs (Discrete)
```glsl
#define DITHER_DOT_SCALE 8.0        // Tiny dots
#define DITHER_STRETCH_SMOOTH 2.0   // Full smoothing
#define RENDER_STYLE 2              // CMYK halftone
#define DITHER_RADIAL_COMP true     // Rotation stability
```

#### Profiling
Use GPU profiler (e.g., RenderDoc, Nsight) to identify hotspots. Key metrics:
- **Texture bandwidth** (GB/s)
- **ALU utilization** (% time in math ops)
- **Fragment overdraw** (transparent surfaces)

---

## Limitations and Known Issues

### 1. Skybox Appears Flat
**Cause:** Sky has no geometry → UVs are screen-aligned → breaks surface-stability illusion.

**Fix:** Use spherical UV mapping (see `gbuffers_skybasic.fsh`):
```glsl
vec3 viewDir = normalize(worldPos);
float u = atan(viewDir.x, viewDir.z) / (2.0 * PI) + 0.5;
float v = 0.731746 * log(tan(angle) + 1.0 / cos(angle));  // Mercator-ish
```

### 2. Texture Atlas Seams
**Cause:** Entities/items use atlased UVs → UVs jump discontinuously at atlas borders.

**Fix:** Pass pre-atlased UV coordinates if available. Otherwise, accept minor seams (barely visible in motion).

### 3. VR Stereo Mismatch
**Cause:** Radial compensation calculates from per-eye position, not head center.

**Fix:** Obtain head center position (`headPos` uniform in VR-enabled shaders), use that for compensation angle.

### 4. Distant LOD Popping
**Cause:** Mipmaps don't exist for 3D textures → frequency jumps at distance.

**Fix:** Enable `DITHER_QUANTIZE_LAYERS` to snap to discrete levels, masking the transition.

---

## Debugging Techniques

### Visualize Frequency Map
```glsl
float freq = computeUVFrequency(du, dv).x;
gl_FragColor = vec4(vec3(freq * 0.1), 1.0);  // Scale for visibility
```
**Expect:** White = high frequency (near), dark = low frequency (far).

### Visualize Layer Selection
```glsl
float layer = computeLayer(spacing, frequency);
gl_FragColor = vec4(vec3(layer / NUM_LAYERS), 1.0);
```
**Expect:** Smooth gradient from camera to horizon.

### Visualize Stretch
```glsl
float stretch = computeUVFrequency(du, dv).y;
gl_FragColor = vec4(stretch * 0.2, 0.0, 0.0, 1.0);  // Red = stretched
```
**Expect:** Red on oblique surfaces, black on perpendicular.

### Disable Dithering
Comment out `applyDither3DColor()` to see original textures/colors. Useful for isolating bugs.

---

## References

### Original Work
- **Paper:** [Surface-Stable Fractal Dithering](https://github.com/runevision/Dither3D) by Rune Skovbo Johansen
- **Video Explainer:** https://youtu.be/HPqGaIMVuLs
- **Unity Implementation:** https://github.com/runevision/Dither3D

### Academic Background
- Bayer matrices: "An optimum method for two-level rendition of continuous-tone pictures" (Bayer, 1973)
- Halftone screening: "Digital Halftoning" by Ulichney (1987)
- SVD decomposition: "Numerical Recipes" Chapter 2.6

### GLSL Resources
- OptiFine shader docs: https://github.com/sp614x/optifine/tree/master/OptiFineDoc/doc
- Iris shader docs: https://github.com/IrisShaders/Iris/wiki

---

## Glossary

- **Bayer matrix:** Ordered dithering pattern with fractal self-similarity
- **SVD:** Singular Value Decomposition (eigenanalysis of Jacobian)
- **Anisotropy:** Directional distortion (stretch)
- **Halftone:** Printing technique using dots to simulate continuous tone
- **CMYK:** Cyan-Magenta-Yellow-Black color model (subtractive)
- **NDC:** Normalized Device Coordinates ([-1,1] screen space)
- **CDF:** Cumulative Distribution Function (for histogram linearization)
- **Moiré:** Interference pattern from overlapping screens (avoided by rotation)

---

## License

Derivative work of Dither3D by Rune Skovbo Johansen, licensed under MPL-2.0.

**Key requirement:** Modified files must retain license header and document changes.
