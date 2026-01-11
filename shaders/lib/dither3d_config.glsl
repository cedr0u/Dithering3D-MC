/*
 * Surface-Stable Fractal Dithering - Configuration
 * Copyright (c) 2025 Cedric - MPL-2.0
 * Default values and constants - options set in dither3d_options.glsl
 */

#ifndef DITHER3D_CONFIG_GLSL
#define DITHER3D_CONFIG_GLSL

// ============================================================================
// DEFAULT VALUES - DITHERING PARAMETERS
// ============================================================================

#ifndef DITHER_DOT_SCALE
#define DITHER_DOT_SCALE 5.0
#endif

#ifndef DITHER_SIZE_VARIABILITY
#define DITHER_SIZE_VARIABILITY 0.0
#endif

#ifndef DITHER_DOT_CONTRAST
#define DITHER_DOT_CONTRAST 1.0
#endif

#ifndef DITHER_STRETCH_SMOOTH
#define DITHER_STRETCH_SMOOTH 1.0
#endif

#ifndef DITHER_EXPOSURE
#define DITHER_EXPOSURE 1.0
#endif

#ifndef DITHER_OFFSET
#define DITHER_OFFSET 0.0
#endif

// ============================================================================
// DEFAULT VALUES - RENDER STYLE (Unified Color/Palette Selection)
// ============================================================================
// Render Style (all-in-one selection):
//   0 = Full Color RGB (no dithering restriction)
//   1 = Grayscale (classic B&W newspaper)
//   2 = CMYK Halftone (printing simulation)
//   3 = 1-Bit Monochrome (pure B&W)
//   4 = Game Boy (4 green shades)
//   5 = CGA Mode 1 (cyan/magenta)
//   6 = Virtual Boy (4 red shades)
//   7 = Sepia (old photo)
//   8 = Pico-8 (16 colors)
//   9 = Nord (8 polar colors)
//  10 = Solarized (8 low-contrast)
//  11 = Custom 2-Color
//  12 = Custom 4-Color
//  13 = Custom 8-Color
//  14 = Eldritch Ruins (16 dark fantasy)

#ifndef RENDER_STYLE
#define RENDER_STYLE 1
#endif

#ifndef PALETTE_COLOR_MATCH
#define PALETTE_COLOR_MATCH 0
#endif

// ============================================================================
// CUSTOM PALETTE COLORS (for Custom 2/4-Color modes)
// ============================================================================

#ifndef PALETTE_CUSTOM_1_R
#define PALETTE_CUSTOM_1_R 0.0
#endif
#ifndef PALETTE_CUSTOM_1_G
#define PALETTE_CUSTOM_1_G 0.0
#endif
#ifndef PALETTE_CUSTOM_1_B
#define PALETTE_CUSTOM_1_B 0.0
#endif

#ifndef PALETTE_CUSTOM_2_R
#define PALETTE_CUSTOM_2_R 1.0
#endif
#ifndef PALETTE_CUSTOM_2_G
#define PALETTE_CUSTOM_2_G 1.0
#endif
#ifndef PALETTE_CUSTOM_2_B
#define PALETTE_CUSTOM_2_B 1.0
#endif

#ifndef PALETTE_CUSTOM_3_R
#define PALETTE_CUSTOM_3_R 0.33
#endif
#ifndef PALETTE_CUSTOM_3_G
#define PALETTE_CUSTOM_3_G 0.33
#endif
#ifndef PALETTE_CUSTOM_3_B
#define PALETTE_CUSTOM_3_B 0.33
#endif

#ifndef PALETTE_CUSTOM_4_R
#define PALETTE_CUSTOM_4_R 0.66
#endif
#ifndef PALETTE_CUSTOM_4_G
#define PALETTE_CUSTOM_4_G 0.66
#endif
#ifndef PALETTE_CUSTOM_4_B
#define PALETTE_CUSTOM_4_B 0.66
#endif

#ifndef PALETTE_CUSTOM_5_R
#define PALETTE_CUSTOM_5_R 0.2
#endif
#ifndef PALETTE_CUSTOM_5_G
#define PALETTE_CUSTOM_5_G 0.2
#endif
#ifndef PALETTE_CUSTOM_5_B
#define PALETTE_CUSTOM_5_B 0.5
#endif

#ifndef PALETTE_CUSTOM_6_R
#define PALETTE_CUSTOM_6_R 0.5
#endif
#ifndef PALETTE_CUSTOM_6_G
#define PALETTE_CUSTOM_6_G 0.2
#endif
#ifndef PALETTE_CUSTOM_6_B
#define PALETTE_CUSTOM_6_B 0.2
#endif

#ifndef PALETTE_CUSTOM_7_R
#define PALETTE_CUSTOM_7_R 0.2
#endif
#ifndef PALETTE_CUSTOM_7_G
#define PALETTE_CUSTOM_7_G 0.5
#endif
#ifndef PALETTE_CUSTOM_7_B
#define PALETTE_CUSTOM_7_B 0.2
#endif

#ifndef PALETTE_CUSTOM_8_R
#define PALETTE_CUSTOM_8_R 0.8
#endif
#ifndef PALETTE_CUSTOM_8_G
#define PALETTE_CUSTOM_8_G 0.8
#endif
#ifndef PALETTE_CUSTOM_8_B
#define PALETTE_CUSTOM_8_B 0.2
#endif

// Build custom color vectors
#define PALETTE_CUSTOM_COLOR_1 vec3(PALETTE_CUSTOM_1_R, PALETTE_CUSTOM_1_G, PALETTE_CUSTOM_1_B)
#define PALETTE_CUSTOM_COLOR_2 vec3(PALETTE_CUSTOM_2_R, PALETTE_CUSTOM_2_G, PALETTE_CUSTOM_2_B)
#define PALETTE_CUSTOM_COLOR_3 vec3(PALETTE_CUSTOM_3_R, PALETTE_CUSTOM_3_G, PALETTE_CUSTOM_3_B)
#define PALETTE_CUSTOM_COLOR_4 vec3(PALETTE_CUSTOM_4_R, PALETTE_CUSTOM_4_G, PALETTE_CUSTOM_4_B)
#define PALETTE_CUSTOM_COLOR_5 vec3(PALETTE_CUSTOM_5_R, PALETTE_CUSTOM_5_G, PALETTE_CUSTOM_5_B)
#define PALETTE_CUSTOM_COLOR_6 vec3(PALETTE_CUSTOM_6_R, PALETTE_CUSTOM_6_G, PALETTE_CUSTOM_6_B)
#define PALETTE_CUSTOM_COLOR_7 vec3(PALETTE_CUSTOM_7_R, PALETTE_CUSTOM_7_G, PALETTE_CUSTOM_7_B)
#define PALETTE_CUSTOM_COLOR_8 vec3(PALETTE_CUSTOM_8_R, PALETTE_CUSTOM_8_G, PALETTE_CUSTOM_8_B)

// ============================================================================
// MINECRAFT SHADER UNIFORMS
// ============================================================================

uniform mat4 gbufferProjection;       // Projection matrix (for radial compensation)

#endif // DITHER3D_CONFIG_GLSL
