/*
 * Surface-Stable Fractal Dithering - Core Algorithm
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Core dithering algorithm - faithful port from original HLSL
 *              Uses procedural circular dots matching 3D texture behavior
 */

#ifndef DITHER3D_CORE_GLSL
#define DITHER3D_CORE_GLSL

#include "dither3d_config.glsl"
#include "dither3d_utils.glsl"

// ============================================================================
// TEXTURE CONFIGURATION CONSTANTS
// Mimics Unity's 3D dither texture structure
// ============================================================================

// These match the original Dither3D 3D texture structure
const float DOTS_PER_SIDE = 4.0;        // Hardcoded for 4x4 Bayer pattern
const float DOTS_TOTAL = 16.0;          // 4^2 = 16 total dot positions
const float INV_DOTS_TOTAL = 1.0 / 16.0;

// ============================================================================
// BRIGHTNESS CURVE (RAMP TEXTURE REPLACEMENT)
// ============================================================================

/**
 * Simulates the ramp texture lookup for brightness correction
 * The original uses a pre-computed 1D texture for gamma-like correction
 */
float getBrightnessCurve(float brightness) {
    // The ramp texture provides slight gamma correction
    // This approximation matches the original behavior
    return clamp(brightness, 0.001, 0.999);
}

// ============================================================================
// BAYER PATTERN - DOT POSITIONS AND ORDER
// ============================================================================

/**
 * 4x4 Bayer matrix threshold values (0-15)
 * Determines the order in which dots appear as brightness increases
 */
int getBayerValue(int x, int y) {
    // Classic 4x4 Bayer matrix
    // Each value indicates at what threshold that dot becomes active
    if (y == 0) {
        if (x == 0) return 0;
        if (x == 1) return 8;
        if (x == 2) return 2;
        return 10;
    }
    if (y == 1) {
        if (x == 0) return 12;
        if (x == 1) return 4;
        if (x == 2) return 14;
        return 6;
    }
    if (y == 2) {
        if (x == 0) return 3;
        if (x == 1) return 11;
        if (x == 2) return 1;
        return 9;
    }
    // y == 3
    if (x == 0) return 15;
    if (x == 1) return 7;
    if (x == 2) return 13;
    return 5;
}

/**
 * Get dot center position for a given cell in the 4x4 grid
 */
vec2 getDotCenter(int x, int y) {
    return (vec2(float(x), float(y)) + 0.5) * 0.25;
}

/**
 * Calculate minimum distance to a dot considering tiling (wrap-around)
 */
float minDistToDot(vec2 p, vec2 dotPos) {
    float minD = 1000.0;
    
    // Check all 9 tiled positions for seamless wrapping
    for (int ox = -1; ox <= 1; ox++) {
        for (int oy = -1; oy <= 1; oy++) {
            vec2 tiledPos = dotPos + vec2(float(ox), float(oy));
            float d = length(p - tiledPos);
            minD = min(minD, d);
        }
    }
    
    return minD;
}

/**
 * Sample the procedural dither pattern (replaces 3D texture lookup)
 * 
 * This generates circular dot gradients matching the original 3D texture.
 * The original texture has dots appearing in Bayer order as Z increases.
 * 
 * @param uv        Pattern UV coordinates (already scaled by fractal level)
 * @param subLayer  Normalized sublayer [0,1] controlling active dot count
 * @return          Pattern value [0,1] - radial gradient from dot centers
 */
float sampleDitherPattern(vec2 uv, float subLayer) {
    // Wrap UV to [0,1]
    vec2 p = fract(uv);
    
    // Convert sublayer to number of active dots (4 to 16)
    // subLayer comes in normalized [~0.03 to 1.0]
    float dotCountF = subLayer * DOTS_TOTAL;
    float activeDots = clamp(floor(dotCountF + 0.5), 4.0, 16.0);
    
    // Find minimum distance to any active dot
    float minDist = 1000.0;
    
    // Check all 16 possible dot positions
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            // Dot is active if its Bayer value < activeDots
            int bayerVal = getBayerValue(x, y);
            if (float(bayerVal) < activeDots) {
                vec2 dotPos = getDotCenter(x, y);
                float d = minDistToDot(p, dotPos);
                minDist = min(minDist, d);
            }
        }
    }
    
    // Convert distance to radial gradient
    // Dots are sized based on active count for proper coverage
    // More dots = smaller radius each
    float dotRadius = 0.25 / sqrt(activeDots / 4.0);
    float normalizedDist = minDist / dotRadius;
    
    // Smooth radial falloff with smoother edge (reduces halo)
    float pattern = 1.0 - smoothstep(0.0, 1.0, normalizedDist);
    return pattern;
}

// ============================================================================
// MAIN DITHERING FUNCTION
// Faithful port of GetDither3D_() from Dither3DInclude.cginc
// ============================================================================

/**
 * Core dithering function
 * 
 * @param uv         Surface UV coordinates (world-space based)
 * @param screenPos  Clip-space position for radial compensation
 * @param dx         dFdx(uv) - UV change along screen X
 * @param dy         dFdy(uv) - UV change along screen Y  
 * @param brightness Input brightness [0,1]
 * @return           vec4(dithered, debug_u, debug_v, debug_layer)
 */
vec4 getDither3D(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, float brightness) {
    // Handle inverse dots mode
    #ifdef DITHER_INVERSE_DOTS
        brightness = 1.0 - brightness;
    #endif
    
    // Lookup brightness curve (simulates ramp texture)
    float brightnessCurve = getBrightnessCurve(brightness);
    
    // ========================================================================
    // Radial compensation for camera rotation stability
    // ========================================================================
    #ifdef DITHER_RADIAL_COMP
        // Make screenPos have 0,0 in the center of the screen
        vec2 screenP = (screenPos.xy / screenPos.w - 0.5) * 2.0;
        
        // Calculate view direction projected onto camera plane
        vec2 viewDirProj = vec2(
            screenP.x / gbufferProjection[0][0],
            screenP.y / -gbufferProjection[1][1]
        );
        
        // Compensation factor: larger toward screen edges
        float radialCompensation = dot(viewDirProj, viewDirProj) + 1.0;
        dx *= radialCompensation;
        dy *= radialCompensation;
    #endif
    
    // ========================================================================
    // SVD-based frequency analysis
    // ========================================================================
    vec4 vectorized = vec4(dx, dy);
    float Q = dot(vectorized, vectorized);
    float R = dx.x * dy.y - dx.y * dy.x;  // determinant
    float discriminantSqr = max(0.0, Q * Q - 4.0 * R * R);
    float discriminant = sqrt(discriminantSqr);
    
    // freq = (max-freq, min-freq)
    vec2 freq = sqrt(vec2(Q + discriminant, Q - discriminant) * 0.5);
    
    // ========================================================================
    // Spacing calculation
    // Use smaller frequency (most stretched direction)
    // ========================================================================
    float spacing = freq.y;
    
    // Scale by user-defined dot scale (exponential)
    float scaleExp = exp2(DITHER_DOT_SCALE);
    spacing *= scaleExp;
    
    // Scale based on pattern structure
    // Original: spacing *= dotsPerSide * 0.125
    spacing *= DOTS_PER_SIDE * 0.125;
    
    // ========================================================================
    // Size variability control
    // ========================================================================
    // _SizeVariability = 0: divide spacing by brightness (Bayer-like)
    // _SizeVariability = 1: spacing unchanged (halftone-like)
    float brightnessSpacingMultiplier = pow(brightnessCurve * 2.0 + 0.001, -(1.0 - DITHER_SIZE_VARIABILITY));
    spacing *= brightnessSpacingMultiplier;
    
    // ========================================================================
    // Fractal level selection
    // ========================================================================
    float spacingLog = log2(max(spacing, 0.0001));
    float patternScaleLevel = floor(spacingLog);
    float f = spacingLog - patternScaleLevel;  // Fractional part [0,1)
    
    // Scale UV to current fractal level
    vec2 patternUV = uv / exp2(patternScaleLevel);
    
    // ========================================================================
    // Sublayer calculation (controls active dot count)
    // ========================================================================
    // subLayer ranges from 0.25*DOTS_TOTAL to DOTS_TOTAL as f goes from 1 to 0
    // This interpolates between fractal levels
    float subLayer = mix(0.25 * DOTS_TOTAL, DOTS_TOTAL, 1.0 - f);
    
    // Optional: Quantize layers to prevent dot morphing
    #ifdef DITHER_QUANTIZE_LAYERS
        float origSubLayer = subLayer;
        subLayer = floor(subLayer + 0.5);
        float thresholdTweak = sqrt(subLayer / origSubLayer);
    #else
        float thresholdTweak = 1.0;
    #endif
    
    // Normalize sublayer for pattern sampling
    // Original: subLayer = (subLayer - 0.5) * invZres
    float subLayerNorm = (subLayer - 0.5) * INV_DOTS_TOTAL;
    
    // ========================================================================
    // Sample dither pattern
    // ========================================================================
    float pattern = sampleDitherPattern(patternUV, subLayerNorm);
    
    // ========================================================================
    // Contrast calculation
    // ========================================================================
    float contrast = DITHER_DOT_CONTRAST * scaleExp * brightnessSpacingMultiplier * 0.15;
    
    // Adjust contrast for anisotropic stretching
    float stretchRatio = freq.y / max(freq.x, 0.0001);
    contrast *= pow(stretchRatio, DITHER_STRETCH_SMOOTH);
    
    // Clamp contrast to prevent halo artifacts
    contrast = min(contrast, 50.0);
    
    // ========================================================================
    // Base value and threshold
    // ========================================================================
    // Base value lerps toward brightness when contrast is low
    // This prevents very blurred patterns from becoming uniform gray
    float contrastFade = clamp(1.0 / (1.0 + contrast * 0.5), 0.0, 1.0);
    float baseVal = mix(0.5, brightness, contrastFade);
    
    // Threshold: brighter output = lower threshold = larger dots
    #ifdef DITHER_QUANTIZE_LAYERS
        float threshold = 1.0 - brightnessCurve * thresholdTweak;
    #else
        float threshold = 1.0 - brightnessCurve;
    #endif
    
    // ========================================================================
    // Final output
    // ========================================================================
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
