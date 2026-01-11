/*
 * Surface-Stable Fractal Dithering - Color Modes
 * Copyright (c) 2025 Cedric - MPL-2.0
 * Entry point: applyDither3DColor() / applyDither3DColorSimple()
 */

#ifndef DITHER3D_COLOR_GLSL
#define DITHER3D_COLOR_GLSL

#include "dither3d_core.glsl"
#include "dither3d_utils.glsl"
#include "dither3d_palettes.glsl"

// ============================================================================
// CMYK HALFTONE CONSTANTS
// Traditional screen angles to minimize moiré
// ============================================================================

const vec2 CMYK_DIR_C = vec2(0.9659, 0.2588);   // 15°
const vec2 CMYK_DIR_M = vec2(0.2588, 0.9659);   // 75°
const vec2 CMYK_DIR_Y = vec2(1.0000, 0.0000);   // 0°
const vec2 CMYK_DIR_K = vec2(0.7071, 0.7071);   // 45°

// ============================================================================
// CMYK HALFTONE DITHERING
// ============================================================================

/**
 * CMYK halftone-style dithering with proper screen angles
 */
vec3 ditherCMYK(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, vec3 color) {
    vec4 cmyk = rgbToCMYK(color);
    
    // Dither each plate with rotated UVs and slight scale variation
    float c = getDither3D(rotateUV(uv * 1.00, CMYK_DIR_C), screenPos, dx, dy, cmyk.x).x;
    float m = getDither3D(rotateUV(uv * 1.02, CMYK_DIR_M), screenPos, dx, dy, cmyk.y).x;
    float y = getDither3D(rotateUV(uv * 0.98, CMYK_DIR_Y), screenPos, dx, dy, cmyk.z).x;
    float k = getDither3D(rotateUV(uv * 1.01, CMYK_DIR_K), screenPos, dx, dy, cmyk.w).x;
    
    return cmykToRGB(vec4(c, m, y, k));
}

// ============================================================================
// UNIFIED COLOR DITHERING INTERFACE
// ============================================================================

/**
 * Main entry point for color dithering
 * Handles all render styles (RGB, Grayscale, CMYK, Palettes)
 */
vec3 applyDither3DColor(vec2 uv, vec4 screenPos, vec2 dx, vec2 dy, vec3 color) {
    // Apply exposure and offset
    vec3 adjustedColor = clamp(color * DITHER_EXPOSURE + DITHER_OFFSET, 0.0, 1.0);
    
    #if RENDER_STYLE == 0
        // Full Color RGB - separate channel dithering
        float r = getDither3D(offsetUV(uv, 0.0), screenPos, dx, dy, adjustedColor.r).x;
        float g = getDither3D(offsetUV(uv, 1.0), screenPos, dx, dy, adjustedColor.g).x;
        float b = getDither3D(offsetUV(uv, 2.0), screenPos, dx, dy, adjustedColor.b).x;
        return vec3(r, g, b);
        
    #elif RENDER_STYLE == 1
        // Grayscale - classic B&W newspaper look
        float luma = getLuminance(adjustedColor);
        vec4 ditherResult = getDither3D(uv, screenPos, dx, dy, luma);
        
        #ifdef DITHER_DEBUG_FRACTAL
            return mix(vec3(ditherResult.x), ditherResult.yzw, 0.7);
        #else
            return vec3(ditherResult.x);
        #endif
        
    #elif RENDER_STYLE == 2
        // CMYK Halftone
        return ditherCMYK(uv, screenPos, dx, dy, adjustedColor);
        
    #else
        // Palette-based styles (3-14)
        float luma = getLuminance(adjustedColor);
        float ditherValue = getDither3D(uv, screenPos, dx, dy, luma).x;
        
        #if PALETTE_COLOR_MATCH == 1
            return applyPalette(adjustedColor, ditherValue, RENDER_STYLE, true);
        #else
            return applyPalette(adjustedColor, ditherValue, RENDER_STYLE, false);
        #endif
    #endif
}

/**
 * Simplified interface with automatic derivative calculation
 */
vec3 applyDither3DColorSimple(vec2 uv, vec4 screenPos, vec3 color) {
    return applyDither3DColor(uv, screenPos, dFdx(uv), dFdy(uv), color);
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
