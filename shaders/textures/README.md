# Dither3D Textures

This directory should contain the 3D dither pattern textures required by the shader.

## Required Textures

The shader needs two types of textures:

### 1. 3D Pattern Texture (`dither3DTex`)
A 3D texture containing Bayer-based dither patterns with multiple layers.

**Specifications:**
- Format: 3D texture, R8 or R16
- Dimensions: Must follow the pattern `(16*N, 16*N, N²)` where N = dots per side
  - Example: 1x1 → 16×16×1
  - Example: 2x2 → 32×32×4
  - Example: 4x4 → 64×64×16
  - Example: 8x8 → 128×128×64
- Each layer contains more dots than the previous
- Dots are radial gradients (brightest at center)

### 2. Brightness Ramp Texture (`ditherRampTex`)
A 1D/2D lookup table that maps input brightness to threshold values.

**Specifications:**
- Format: 2D texture, R8 or R16 (width = pattern resolution, height = 1)
- Pre-computed to ensure correct brightness output at different thresholds
- Generated based on the 3D pattern texture

## Generation

These textures are typically generated procedurally. Options:

1. **Port from Unity**: Adapt `Dither3DTextureMaker.cs` from the original repository
2. **Use pre-generated assets**: Download from the original Dither3D repository
3. **Create a Python generator**: Use numpy to generate Bayer matrices and export to 3D texture format

## Temporary Solution

For testing without textures, you can:
1. Use a simple 2D Bayer matrix and repeat it in Z
2. Use a linear ramp for the brightness lookup

## File Naming Convention

```
dither3d_1x1.raw       # 16×16×1 pattern
dither3d_1x1_ramp.raw  # 16×1 ramp
dither3d_2x2.raw       # 32×32×4 pattern
dither3d_2x2_ramp.raw  # 32×1 ramp
...
```

Note: OptiFine/Iris may require specific texture formats. Consult their documentation for supported 3D texture formats.
