/*
 * Surface-Stable Fractal Dithering - Color Modes
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Color mode implementations (Grayscale, RGB, CMYK)
 *              Improved from original with better color handling
 */

#ifndef DITHER3D_COLOR_GLSL
#define DITHER3D_COLOR_GLSL

#include "dither3d_core.glsl"

// ============================================================================
// COLOR CONVERSION FUNCTIONS
// ============================================================================

/**
 * Convert RGB to grayscale using perceptual weights (Rec. 601)
 */
float getGrayscale(vec3 color) {
    return clamp(0.299 * color.r + 0.587 * color.g + 0.114 * color.b, 0.0, 1.0);
}

/**
 * Convert CMYK to RGB
 */
vec3 cmykToRGB(vec4 cmyk) {
    float c = cmyk.x;
    float m = cmyk.y;
    float y = cmyk.z;
    float k = cmyk.w;
    
    float invK = 1.0 - k;
    float r = 1.0 - min(1.0, c * invK + k);
    float g = 1.0 - min(1.0, m * invK + k);
    float b = 1.0 - min(1.0, y * invK + k);
    return clamp(vec3(r, g, b), 0.0, 1.0);
}

/**
 * Convert RGB to CMYK with improved handling
 */
vec4 rgbToCMYK(vec3 rgb) {
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;
    
    // Key (black) is the minimum of the complements
    float k = min(1.0 - r, min(1.0 - g, 1.0 - b));
    
    vec3 cmy = vec3(0.0);
    float invK = 1.0 - k;
    
    // Avoid division by zero for pure black
    if (invK > 0.001) {
        cmy.x = (1.0 - r - k) / invK;
        cmy.y = (1.0 - g - k) / invK;
        cmy.z = (1.0 - b - k) / invK;
    }
    
    return clamp(vec4(cmy, k), 0.0, 1.0);
}

/**
 * Rotate UV coordinates using unit direction vector
 */
vec2 rotateUV(vec2 uv, vec2 xUnitDir) {
    return uv.x * xUnitDir + uv.y * vec2(-xUnitDir.y, xUnitDir.x);
}

/**
 * Apply slight UV offset for each channel to reduce overlap artifacts
 */
vec2 offsetUV(vec2 uv, float offset) {
    return uv + vec2(offset * 0.1, offset * 0.07);
}

// ============================================================================
// COLOR MODE: GRAYSCALE
// ============================================================================

/**
 * Applies grayscale dithering
 * Classic black & white newspaper look
 */
vec3 ditherGrayscale(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, vec3 color) {
    float luma = getGrayscale(color);
    
    vec4 ditherResult = getDither3D(uv, screenPos, dx, dy, luma);
    float dithered = ditherResult.x;
    
    #ifdef DITHER_DEBUG_FRACTAL
        vec3 debugVis = ditherResult.yzw;
        return mix(vec3(dithered), debugVis, 0.7);
    #endif
    
    return vec3(dithered);
}

// ============================================================================
// COLOR MODE: RGB (Improved)
// ============================================================================

/**
 * Applies RGB channel-separated dithering with slight offsets
 * Creates colorful comic-book style effect
 */
vec3 ditherRGB(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, vec3 color) {
    // Slight UV offsets per channel to create interesting color separation
    // This creates a more visually appealing chromatic effect
    float r = getDither3D(offsetUV(uv, 0.0), screenPos, dx, dy, color.r).x;
    float g = getDither3D(offsetUV(uv, 1.0), screenPos, dx, dy, color.g).x;
    float b = getDither3D(offsetUV(uv, 2.0), screenPos, dx, dy, color.b).x;
    
    return vec3(r, g, b);
}

// ============================================================================
// COLOR MODE: CMYK HALFTONE (Improved)
// ============================================================================

/**
 * Applies CMYK halftone-style dithering
 * 
 * Traditional 4-color printing simulation with proper screen angles
 * Angles chosen to minimize moiré: C=15°, M=75°, Y=0°, K=45°
 */
vec3 ditherCMYK(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, vec3 color) {
    // Convert RGB to CMYK
    vec4 cmyk = rgbToCMYK(color);
    
    // Pre-computed rotation vectors for traditional halftone angles
    const vec2 DIR_C = vec2(0.9659, 0.2588);   // 15°
    const vec2 DIR_M = vec2(0.2588, 0.9659);   // 75°
    const vec2 DIR_Y = vec2(1.0000, 0.0000);   // 0°
    const vec2 DIR_K = vec2(0.7071, 0.7071);   // 45°
    
    // Dither each color plate with rotated UVs
    // Scale UVs slightly differently for each to reduce moiré
    float c = getDither3D(rotateUV(uv * 1.00, DIR_C), screenPos, dx, dy, cmyk.x).x;
    float m = getDither3D(rotateUV(uv * 1.02, DIR_M), screenPos, dx, dy, cmyk.y).x;
    float y = getDither3D(rotateUV(uv * 0.98, DIR_Y), screenPos, dx, dy, cmyk.z).x;
    float k = getDither3D(rotateUV(uv * 1.01, DIR_K), screenPos, dx, dy, cmyk.w).x;
    
    // Convert back to RGB
    return cmykToRGB(vec4(c, m, y, k));
}

// ============================================================================
// UNIFIED COLOR DITHERING INTERFACE
// ============================================================================

/**
 * Main entry point for color dithering
 */
vec3 applyDither3DColor(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, vec3 color) {
    // Apply exposure and offset
    color = clamp(color * DITHER_EXPOSURE + DITHER_OFFSET, 0.0, 1.0);
    
    #if DITHER_COLOR_MODE == 0
        return ditherGrayscale(uv, screenPos, dx, dy, color);
    #elif DITHER_COLOR_MODE == 1
        return ditherRGB(uv, screenPos, dx, dy, color);
    #elif DITHER_COLOR_MODE == 2
        return ditherCMYK(uv, screenPos, dx, dy, color);
    #else
        return ditherGrayscale(uv, screenPos, dx, dy, color);
    #endif
}

/**
 * Simplified interface with automatic derivative calculation
 */
vec3 applyDither3DColorSimple(vec2 uv, vec4 screenPos, vec3 color) {
    vec2 dx = dFdx(uv);
    vec2 dy = dFdy(uv);
    return applyDither3DColor(uv, screenPos, dx, dy, color);
}

/**
 * Alternative UV version for handling UV seams (for sky)
 */
vec3 applyDither3DColorAltUV(vec2 uv, vec2 uvAlt, vec4 screenPos, vec3 color) {
    vec2 dxA = dFdx(uv);
    vec2 dyA = dFdy(uv);
    vec2 dxB = dFdx(uvAlt);
    vec2 dyB = dFdy(uvAlt);
    
    // Use whichever has smaller derivatives (avoids seam artifacts)
    vec2 dx = (dot(dxA, dxA) < dot(dxB, dxB)) ? dxA : dxB;
    vec2 dy = (dot(dyA, dyA) < dot(dyB, dyB)) ? dyA : dyB;
    
    return applyDither3DColor(uv, screenPos, dx, dy, color);
}

#endif // DITHER3D_COLOR_GLSL
