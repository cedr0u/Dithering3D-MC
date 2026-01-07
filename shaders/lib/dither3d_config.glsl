/*
 * Surface-Stable Fractal Dithering - Configuration
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Uniform declarations and configuration constants
 *              Options are defined in main shader files for Iris compatibility
 */

#ifndef DITHER3D_CONFIG_GLSL
#define DITHER3D_CONFIG_GLSL

// ============================================================================
// DEFAULT VALUES (used if not defined in main shader)
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

#ifndef DITHER_COLOR_MODE
#define DITHER_COLOR_MODE 0
#endif

// ============================================================================
// MINECRAFT SHADER UNIFORMS
// ============================================================================

uniform mat4 gbufferProjection;       // Projection matrix (for radial compensation)

#endif // DITHER3D_CONFIG_GLSL
