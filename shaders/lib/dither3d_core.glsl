/*
 * Surface-Stable Fractal Dithering - Core Algorithm
 * Copyright (c) 2025 Cedric - MPL-2.0
 * Procedural circular dots matching original 3D texture behavior
 */

#ifndef DITHER3D_CORE_GLSL
#define DITHER3D_CORE_GLSL

#include "dither3d_config.glsl"

// ============================================================================
// CONSTANTS
// ============================================================================

const float DOTS_PER_SIDE = 4.0;
const float DOTS_TOTAL = 16.0;
const float INV_DOTS_TOTAL = 0.0625;  // 1.0 / 16.0

// 4x4 Bayer matrix as flat array (row-major): [y * 4 + x]
// Values indicate dot activation threshold (0-15)
const int BAYER_MATRIX[16] = int[16](
     0,  8,  2, 10,
    12,  4, 14,  6,
     3, 11,  1,  9,
    15,  7, 13,  5
);

// ============================================================================
// BAYER LOOKUP
// ============================================================================

/**
 * Get Bayer matrix value using array lookup (faster than if-else chain)
 */
int getBayerValue(int x, int y) {
    return BAYER_MATRIX[y * 4 + x];
}

// ============================================================================
// DOT CENTER POSITIONS (pre-computed)
// ============================================================================

/**
 * Get dot center position for a given cell in the 4x4 grid
 */
vec2 getDotCenter(int x, int y) {
    return vec2(float(x) + 0.5, float(y) + 0.5) * 0.25;
}

// ============================================================================
// TILED DISTANCE CALCULATION
// ============================================================================

/**
 * Calculate minimum squared distance to a dot considering tiling (wrap-around)
 * Returns squared distance for efficiency - sqrt applied once at the end
 */
float minDistToDotSq(vec2 p, vec2 dotPos) {
    vec2 d = p - dotPos;
    
    // Wrap to [-0.5, 0.5] range for tiled distance
    d = d - floor(d + 0.5);
    
    return dot(d, d);
}

// ============================================================================
// PROCEDURAL DITHER PATTERN
// ============================================================================

/**
 * Sample the procedural dither pattern (replaces 3D texture lookup)
 * Generates circular dot gradients matching the original 3D texture.
 * 
 * @param uv        Pattern UV coordinates (already scaled by fractal level)
 * @param subLayer  Normalized sublayer [0,1] controlling active dot count
 * @return          Pattern value [0,1] - radial gradient from dot centers
 */
float sampleDitherPattern(vec2 uv, float subLayer) {
    vec2 p = fract(uv);
    
    // Convert sublayer to active dot count (4 to 16)
    float activeDots = clamp(floor(subLayer * DOTS_TOTAL + 0.5), 4.0, 16.0);
    int activeDotsInt = int(activeDots);
    
    // Find minimum squared distance to any active dot
    float minDistSq = 1.0;  // Max possible squared distance in unit cell
    
    for (int i = 0; i < 16; i++) {
        if (BAYER_MATRIX[i] < activeDotsInt) {
            vec2 dotPos = getDotCenter(i & 3, i >> 2);
            minDistSq = min(minDistSq, minDistToDotSq(p, dotPos));
        }
    }
    
    // Convert distance to radial gradient (sqrt only once at end)
    float dotRadius = 0.25 / sqrt(activeDots * 0.25);
    float dotRadiusSq = dotRadius * dotRadius;
    float normalizedDistSq = minDistSq / dotRadiusSq;
    
    return 1.0 - smoothstep(0.0, 1.0, sqrt(normalizedDistSq));
}

// ============================================================================
// MAIN DITHERING FUNCTION
// ============================================================================

/**
 * Core dithering function - faithful port of GetDither3D_()
 * 
 * @param uv         Surface UV coordinates (world-space based)
 * @param screenPos  Clip-space position for radial compensation
 * @param dx         dFdx(uv) - UV change along screen X
 * @param dy         dFdy(uv) - UV change along screen Y  
 * @param brightness Input brightness [0,1]
 * @return           vec4(dithered, debug_u, debug_v, debug_layer)
 */
vec4 getDither3D(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, float brightness) {
    #ifdef DITHER_INVERSE_DOTS
        brightness = 1.0 - brightness;
    #endif
    
    // Clamp brightness to valid range
    float brightnessCurve = clamp(brightness, 0.001, 0.999);
    
    // ========================================================================
    // Radial compensation for camera rotation stability
    // ========================================================================
    #ifdef DITHER_RADIAL_COMP
        vec2 screenP = (screenPos.xy / screenPos.w - 0.5) * 2.0;
        vec2 viewDirProj = vec2(
            screenP.x / gbufferProjection[0][0],
            screenP.y / -gbufferProjection[1][1]
        );
        float radialComp = dot(viewDirProj, viewDirProj) + 1.0;
        dx *= radialComp;
        dy *= radialComp;
    #endif
    
    // ========================================================================
    // SVD-based frequency analysis
    // ========================================================================
    float Q = dot(dx, dx) + dot(dy, dy);
    float R = dx.x * dy.y - dx.y * dy.x;
    float discriminant = sqrt(max(0.0, Q * Q - 4.0 * R * R));
    
    // freq = (max-freq, min-freq)
    vec2 freq = sqrt(vec2(Q + discriminant, Q - discriminant) * 0.5);
    
    // ========================================================================
    // Spacing calculation
    // ========================================================================
    float scaleExp = exp2(DITHER_DOT_SCALE);
    float spacing = freq.y * scaleExp * DOTS_PER_SIDE * 0.125;
    
    // Size variability: 0 = Bayer-like, 1 = halftone-like
    float brightnessMultiplier = pow(brightnessCurve * 2.0 + 0.001, -(1.0 - DITHER_SIZE_VARIABILITY));
    spacing *= brightnessMultiplier;
    
    // ========================================================================
    // Fractal level selection
    // ========================================================================
    float spacingLog = log2(max(spacing, 0.0001));
    float patternScaleLevel = floor(spacingLog);
    float f = spacingLog - patternScaleLevel;
    
    vec2 patternUV = uv / exp2(patternScaleLevel);
    
    // ========================================================================
    // Sublayer calculation
    // ========================================================================
    float subLayer = mix(DOTS_TOTAL * 0.25, DOTS_TOTAL, 1.0 - f);
    
    #ifdef DITHER_QUANTIZE_LAYERS
        float origSubLayer = subLayer;
        subLayer = floor(subLayer + 0.5);
        float thresholdTweak = sqrt(subLayer / origSubLayer);
    #else
        float thresholdTweak = 1.0;
    #endif
    
    float subLayerNorm = (subLayer - 0.5) * INV_DOTS_TOTAL;
    
    // ========================================================================
    // Sample pattern and apply contrast
    // ========================================================================
    float pattern = sampleDitherPattern(patternUV, subLayerNorm);
    
    float contrast = DITHER_DOT_CONTRAST * scaleExp * brightnessMultiplier * 0.15;
    float stretchRatio = freq.y / max(freq.x, 0.0001);
    contrast *= pow(stretchRatio, DITHER_STRETCH_SMOOTH);
    contrast = min(contrast, 50.0);
    
    // Base value and threshold
    float contrastFade = 1.0 / (1.0 + contrast * 0.5);
    float baseVal = mix(0.5, brightness, clamp(contrastFade, 0.0, 1.0));
    
    #ifdef DITHER_QUANTIZE_LAYERS
        float threshold = 1.0 - brightnessCurve * thresholdTweak;
    #else
        float threshold = 1.0 - brightnessCurve;
    #endif
    
    float bw = clamp((pattern - threshold) * contrast + baseVal, 0.0, 1.0);
    
    #ifdef DITHER_INVERSE_DOTS
        bw = 1.0 - bw;
    #endif
    
    return vec4(bw, fract(patternUV.x), fract(patternUV.y), subLayerNorm);
}

// ============================================================================
// SIMPLIFIED INTERFACES
// ============================================================================

/**
 * Simple dithering with automatic derivative calculation
 */
float getDither3DSimple(vec2 uv, vec4 screenPos, float brightness) {
    vec2 dx = dFdx(uv);
    vec2 dy = dFdy(uv);
    return getDither3D(uv, screenPos, dx, dy, brightness).x;
}

/**
 * Alternative UV version for handling UV seams
 * Uses whichever UV has smaller derivatives to avoid discontinuities
 */
vec4 getDither3DAltUV(vec2 uv, vec2 uvAlt, vec4 screenPos, float brightness) {
    vec2 dxA = dFdx(uv);
    vec2 dyA = dFdy(uv);
    vec2 dxB = dFdx(uvAlt);
    vec2 dyB = dFdy(uvAlt);
    
    // Choose derivatives with smaller magnitude (less discontinuous)
    vec2 dx = (dot(dxA, dxA) < dot(dxB, dxB)) ? dxA : dxB;
    vec2 dy = (dot(dyA, dyA) < dot(dyB, dyB)) ? dyA : dyB;
    
    return getDither3D(uv, screenPos, dx, dy, brightness);
}

#endif // DITHER3D_CORE_GLSL
