/*
 * Surface-Stable Fractal Dithering - Utility Functions
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#ifndef DITHER3D_UTILS_GLSL
#define DITHER3D_UTILS_GLSL

// ============================================================================
// MATHEMATICAL CONSTANTS
// ============================================================================

const float PI = 3.14159265359;
const float INV_PI = 0.31830988618;
const float EPSILON = 0.0001;

// ============================================================================
// LUMINANCE CALCULATION (Rec. 601)
// ============================================================================

/**
 * Convert RGB to luminance using perceptual weights
 * Single definition used throughout the codebase
 */
float getLuminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// ============================================================================
// TRIPLANAR UV PROJECTION
// ============================================================================

/**
 * Compute surface-stable UV using triplanar projection
 * Automatically selects the best projection plane based on surface normal
 * 
 * @param pos    World position
 * @param normal World-space normal (doesn't need to be normalized)
 * @return       Blended UV coordinates
 */
vec2 getTriplanarUV(vec3 pos, vec3 normal) {
    // Normalize and get absolute values for blend weights
    vec3 n = normalize(normal);
    vec3 blend = abs(n);
    
    // Sharpen blend to prefer dominant axis (reduces blending artifacts)
    // Using pow(4) provides good sharpness without harsh transitions
    blend *= blend;  // pow(blend, 2)
    blend *= blend;  // pow(blend, 4)
    
    // Normalize weights to sum to 1
    float sum = blend.x + blend.y + blend.z;
    blend *= (sum > EPSILON) ? (1.0 / sum) : 1.0;
    
    // Project position onto each plane and blend
    return pos.yz * blend.x + pos.xz * blend.y + pos.xy * blend.z;
}

/**
 * Simple UV from world position for non-planar geometry
 * Uses XZ plane with Y offset for variation
 * 
 * @param pos World position
 * @return    Pseudo-surface UV
 */
vec2 getSimpleWorldUV(vec3 pos) {
    return pos.xz + vec2(pos.y * 0.37, pos.y * 0.73);
}

// ============================================================================
// COLOR SPACE CONVERSIONS
// ============================================================================

/**
 * Convert RGB to CMYK
 */
vec4 rgbToCMYK(vec3 rgb) {
    // Key (black) is the minimum of the complements
    float k = min(1.0 - rgb.r, min(1.0 - rgb.g, 1.0 - rgb.b));
    float invK = 1.0 - k;
    
    // Avoid division by zero when invK is near 0 (pure black)
    vec3 cmy = (invK > EPSILON) ? (1.0 - rgb - k) / invK : vec3(0.0);
    
    return clamp(vec4(cmy, k), 0.0, 1.0);
}

/**
 * Convert CMYK to RGB
 */
vec3 cmykToRGB(vec4 cmyk) {
    float invK = 1.0 - cmyk.w;
    vec3 rgb = 1.0 - min(vec3(1.0), cmyk.xyz * invK + cmyk.w);
    return clamp(rgb, 0.0, 1.0);
}

// ============================================================================
// UV MANIPULATION
// ============================================================================

/**
 * Rotate UV coordinates using unit direction vector
 */
vec2 rotateUV(vec2 uv, vec2 xUnitDir) {
    return uv.x * xUnitDir + uv.y * vec2(-xUnitDir.y, xUnitDir.x);
}

/**
 * Apply slight UV offset for channel separation
 */
vec2 offsetUV(vec2 uv, float offset) {
    return uv + vec2(offset * 0.1, offset * 0.07);
}

// ============================================================================
// COLOR DISTANCE
// ============================================================================

/**
 * Perceptual color distance (squared Euclidean)
 */
float colorDistance(vec3 a, vec3 b) {
    vec3 diff = a - b;
    return dot(diff, diff);
}

#endif // DITHER3D_UTILS_GLSL
