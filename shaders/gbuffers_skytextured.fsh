/*
 * Surface-Stable Fractal Dithering - Sky Textured Fragment Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Fragment shader for textured sky elements (sun, moon, stars)
 */

#version 120

// ============================================================================
// SHADER OPTIONS
// ============================================================================

#define DITHER_DOT_SCALE 5.0 // [2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
#define DITHER_SIZE_VARIABILITY 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define DITHER_DOT_CONTRAST 1.0 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 3.0 5.0]
#define DITHER_STRETCH_SMOOTH 1.0 // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define DITHER_EXPOSURE 1.0 // [0.2 0.4 0.6 0.8 1.0 1.5 2.0 2.5 3.0 4.0 5.0]
#define DITHER_OFFSET 0.0 // [-1.0 -0.8 -0.6 -0.4 -0.2 0.0 0.2 0.4 0.6 0.8 1.0]
#define DITHER_COLOR_MODE 0 // [0 1 2]

//#define DITHER_INVERSE_DOTS
//#define DITHER_RADIAL_COMP
//#define DITHER_QUANTIZE_LAYERS
//#define DITHER_DEBUG_FRACTAL

// ============================================================================
// INCLUDES
// ============================================================================

#include "lib/dither3d_color.glsl"

// ============================================================================
// UNIFORMS
// ============================================================================

uniform sampler2D texture;

// ============================================================================
// VARYINGS
// ============================================================================

varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 screenPos;

// ============================================================================
// MAIN
// ============================================================================

void main() {
    // Sample sky texture (sun, moon, etc.)
    vec4 texColor = texture2D(texture, texcoord);
    
    // Calculate color
    vec3 color = texColor.rgb * glcolor.rgb;
    
    // Use texture coordinates scaled for consistent dithering
    vec2 ditherUV = texcoord * 4.0;
    
    // Apply dithering
    vec3 dithered = applyDither3DColorSimple(ditherUV, screenPos, color);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, texColor.a * glcolor.a);
}
