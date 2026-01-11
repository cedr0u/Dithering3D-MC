/*
 * Surface-Stable Fractal Dithering - Color Palettes
 * Copyright (c) 2025 Cedric - MPL-2.0
 * Curated palettes with unified access via getPaletteColor()/applyPalette()
 */

#ifndef DITHER3D_PALETTES_GLSL
#define DITHER3D_PALETTES_GLSL

#include "dither3d_utils.glsl"

// ============================================================================
// PALETTE SIZE CONSTANTS
// ============================================================================

const int PALETTE_SIZE_2  = 2;
const int PALETTE_SIZE_4  = 4;
const int PALETTE_SIZE_8  = 8;
const int PALETTE_SIZE_16 = 16;

// ============================================================================
// PALETTE DATA - Sorted by luminance for proper dithering
// ============================================================================

// 1-Bit Monochrome
const vec3 PALETTE_1BIT[2] = vec3[2](
    vec3(0.0),           // Black
    vec3(1.0)            // White
);

// Game Boy (4 colors)
const vec3 PALETTE_GAMEBOY[4] = vec3[4](
    vec3(0.06, 0.22, 0.06),   // Blackish
    vec3(0.19, 0.38, 0.19),   // Dark Green
    vec3(0.55, 0.67, 0.06),   // Light Green
    vec3(0.61, 0.74, 0.06)    // Whiteish
);

// CGA Mode 1 High (4 colors)
const vec3 PALETTE_CGA[4] = vec3[4](
    vec3(0.0),               // Black
    vec3(0.33, 1.0, 1.0),    // Cyan
    vec3(1.0, 0.33, 1.0),    // Magenta
    vec3(1.0)                // White
);

// Virtual Boy (4 colors)
const vec3 PALETTE_VBOY[4] = vec3[4](
    vec3(0.0),               // Black
    vec3(0.33, 0.0, 0.0),    // Dark Red
    vec3(0.66, 0.0, 0.0),    // Medium Red
    vec3(1.0, 0.0, 0.0)      // Bright Red
);

// Sepia (4 colors)
const vec3 PALETTE_SEPIA[4] = vec3[4](
    vec3(0.17, 0.11, 0.05),  // Dark Brown
    vec3(0.44, 0.26, 0.08),  // Mid Brown
    vec3(0.82, 0.71, 0.55),  // Paper
    vec3(0.96, 0.87, 0.70)   // Fade
);

// Nord Theme (8 colors) - Sorted by luminance
const vec3 PALETTE_NORD[8] = vec3[8](
    vec3(0.18, 0.20, 0.25),  // Dark Grey
    vec3(0.37, 0.51, 0.67),  // Frost Blue
    vec3(0.75, 0.38, 0.45),  // Red
    vec3(0.81, 0.55, 0.43),  // Orange
    vec3(0.56, 0.74, 0.73),  // Frost Cyan
    vec3(0.64, 0.75, 0.55),  // Green
    vec3(0.92, 0.79, 0.54),  // Yellow
    vec3(0.85, 0.87, 0.91)   // Snow White
);

// Solarized Dark (8 colors) - Sorted by luminance
const vec3 PALETTE_SOLARIZED[8] = vec3[8](
    vec3(0.00, 0.17, 0.21),  // Base03
    vec3(0.03, 0.21, 0.26),  // Base02
    vec3(0.35, 0.43, 0.46),  // Base01
    vec3(0.80, 0.29, 0.09),  // Orange
    vec3(0.40, 0.48, 0.51),  // Base00
    vec3(0.15, 0.55, 0.82),  // Blue
    vec3(0.83, 0.37, 0.00),  // Red
    vec3(0.16, 0.63, 0.60)   // Cyan
);

// Pico-8 (16 colors) - Sorted by luminance
const vec3 PALETTE_PICO8[16] = vec3[16](
    vec3(0.00, 0.00, 0.00),  // Black
    vec3(0.11, 0.17, 0.33),  // Dark Blue
    vec3(0.49, 0.15, 0.20),  // Dark Purple
    vec3(1.00, 0.00, 0.30),  // Red
    vec3(0.37, 0.34, 0.31),  // Dark Grey
    vec3(0.00, 0.53, 0.32),  // Dark Green
    vec3(0.67, 0.32, 0.21),  // Brown
    vec3(0.51, 0.46, 0.61),  // Indigo
    vec3(0.00, 0.89, 0.21),  // Green
    vec3(0.16, 0.68, 1.00),  // Blue
    vec3(1.00, 0.47, 0.66),  // Pink
    vec3(1.00, 0.64, 0.00),  // Orange
    vec3(0.76, 0.76, 0.78),  // Light Grey
    vec3(1.00, 0.80, 0.67),  // Peach
    vec3(1.00, 0.93, 0.15),  // Yellow
    vec3(1.00, 0.95, 0.91)   // White
);

// Eldritch Ruins (16 colors) - Dark fantasy, sorted by luminance
const vec3 PALETTE_ELDRITCH[16] = vec3[16](
    vec3(0.020, 0.016, 0.043),  // Noir Abyssal
    vec3(0.102, 0.086, 0.141),  // Obsidienne Maudite
    vec3(0.075, 0.118, 0.180),  // Fosse Marine
    vec3(0.259, 0.071, 0.086),  // Sang Coagulé
    vec3(0.118, 0.161, 0.122),  // Marécage Sombre
    vec3(0.184, 0.165, 0.243),  // Gris Ardoise
    vec3(0.220, 0.176, 0.149),  // Boue Séchée
    vec3(0.302, 0.149, 0.369),  // Décomposition Royale
    vec3(0.200, 0.302, 0.220),  // Mousse Toxique
    vec3(0.275, 0.259, 0.333),  // Fer Ancien
    vec3(0.471, 0.337, 0.251),  // Bois de Cercueil
    vec3(0.710, 0.322, 0.192),  // Rouille
    vec3(0.431, 0.447, 0.471),  // Gris Cendre
    vec3(0.357, 0.478, 0.620),  // Acier Lunaire
    vec3(0.878, 0.651, 0.306),  // Or Fiévreux
    vec3(0.831, 0.827, 0.812)   // Os Blanchi
);

// ============================================================================
// CUSTOM PALETTE ACCESS
// ============================================================================

vec3 getCustomColor(int index) {
    // Use array-like access pattern
    if (index == 0) return PALETTE_CUSTOM_COLOR_1;
    if (index == 1) return PALETTE_CUSTOM_COLOR_2;
    if (index == 2) return PALETTE_CUSTOM_COLOR_3;
    if (index == 3) return PALETTE_CUSTOM_COLOR_4;
    if (index == 4) return PALETTE_CUSTOM_COLOR_5;
    if (index == 5) return PALETTE_CUSTOM_COLOR_6;
    if (index == 6) return PALETTE_CUSTOM_COLOR_7;
    return PALETTE_CUSTOM_COLOR_8;
}

// ============================================================================
// UNIFIED PALETTE ACCESS
// ============================================================================

/**
 * Get color from any palette by ID and index
 * Centralizes all palette access for maintainability
 */
vec3 getPaletteColor(int paletteId, int index) {
    // 4-color palettes
    if (paletteId == 4) return PALETTE_GAMEBOY[clamp(index, 0, 3)];
    if (paletteId == 5) return PALETTE_CGA[clamp(index, 0, 3)];
    if (paletteId == 6) return PALETTE_VBOY[clamp(index, 0, 3)];
    if (paletteId == 7) return PALETTE_SEPIA[clamp(index, 0, 3)];
    
    // 8-color palettes
    if (paletteId == 9)  return PALETTE_NORD[clamp(index, 0, 7)];
    if (paletteId == 10) return PALETTE_SOLARIZED[clamp(index, 0, 7)];
    
    // 16-color palettes
    if (paletteId == 8)  return PALETTE_PICO8[clamp(index, 0, 15)];
    if (paletteId == 14) return PALETTE_ELDRITCH[clamp(index, 0, 15)];
    
    // 1-Bit
    if (paletteId == 3) return PALETTE_1BIT[clamp(index, 0, 1)];
    
    // Custom palettes
    if (paletteId == 11) return (index == 0) ? getCustomColor(0) : getCustomColor(1);
    if (paletteId == 12) return getCustomColor(clamp(index, 0, 3));
    if (paletteId == 13) return getCustomColor(clamp(index, 0, 7));
    
    return vec3(0.0);
}

/**
 * Get palette size by ID
 */
int getPaletteSize(int paletteId) {
    if (paletteId == 3 || paletteId == 11) return 2;
    if (paletteId >= 4 && paletteId <= 7) return 4;
    if (paletteId == 12) return 4;
    if (paletteId == 9 || paletteId == 10 || paletteId == 13) return 8;
    return 16; // Pico-8 (8) and Eldritch (14)
}

// ============================================================================
// UNIFIED DITHERING FUNCTIONS
// ============================================================================

/**
 * Luminance-based palette dithering (generic)
 * Works for any palette size
 */
vec3 ditherToPaletteLuma(vec3 color, float ditherValue, int paletteId) {
    float luma = getLuminance(color);
    int paletteSize = getPaletteSize(paletteId);
    int maxIdx = paletteSize - 1;
    
    // Handle single-color palette edge case
    if (maxIdx <= 0) return getPaletteColor(paletteId, 0);
    
    // Scale luminance to palette range
    float scaledLuma = luma * float(maxIdx);
    int lowIdx = clamp(int(floor(scaledLuma)), 0, maxIdx - 1);
    int highIdx = lowIdx + 1;
    
    // Dither between adjacent colors
    float frac = fract(scaledLuma);
    int selectedIdx = (ditherValue < frac) ? highIdx : lowIdx;
    
    return getPaletteColor(paletteId, selectedIdx);
}

/**
 * Color-matching palette dithering (generic)
 * Finds two closest colors and dithers between them
 */
vec3 ditherToPaletteColor(vec3 color, float ditherValue, int paletteId) {
    int paletteSize = getPaletteSize(paletteId);
    
    // Initialize with first two colors
    vec3 closest = getPaletteColor(paletteId, 0);
    vec3 secondClosest = getPaletteColor(paletteId, 1);
    float minDist = colorDistance(color, closest);
    float secondMinDist = colorDistance(color, secondClosest);
    
    // Ensure closest is actually closest
    if (secondMinDist < minDist) {
        vec3 tmpC = closest; closest = secondClosest; secondClosest = tmpC;
        float tmpD = minDist; minDist = secondMinDist; secondMinDist = tmpD;
    }
    
    // Search remaining colors (explicit loop bounds for GLSL 1.20 compatibility)
    for (int i = 2; i < 16; i++) {
        if (i >= paletteSize) break;
        
        vec3 pColor = getPaletteColor(paletteId, i);
        float dist = colorDistance(color, pColor);
        
        if (dist < minDist) {
            secondClosest = closest;
            secondMinDist = minDist;
            closest = pColor;
            minDist = dist;
        } else if (dist < secondMinDist) {
            secondClosest = pColor;
            secondMinDist = dist;
        }
    }
    
    // Dither between the two closest colors
    float totalDist = minDist + secondMinDist;
    float blendFactor = (totalDist > 0.001) ? (minDist / totalDist) : 0.0;
    
    return (ditherValue < blendFactor) ? secondClosest : closest;
}

// ============================================================================
// MAIN PALETTE APPLICATION
// ============================================================================

/**
 * Apply selected palette to a dithered result
 * 
 * @param color       Original color (for color-aware modes)
 * @param ditherValue The raw dither value (0-1)
 * @param renderStyle The render style (3-14 for palettes)
 * @param useColorMatch If true, use color-aware matching
 */
vec3 applyPalette(vec3 color, float ditherValue, int renderStyle, bool useColorMatch) {
    // Styles 0-2 handled by color module (RGB, Grayscale, CMYK)
    if (renderStyle < 3) return color;
    
    // 1-Bit is always luminance-based (no color matching needed)
    if (renderStyle == 3) {
        return ditherToPaletteLuma(color, ditherValue, 3);
    }
    
    // For other palettes, choose method based on useColorMatch
    if (useColorMatch) {
        return ditherToPaletteColor(color, ditherValue, renderStyle);
    }
    return ditherToPaletteLuma(color, ditherValue, renderStyle);
}

#endif // DITHER3D_PALETTES_GLSL
