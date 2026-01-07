/*
 * Surface-Stable Fractal Dithering - Final Fragment Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Final pass - outputs to screen with optional adjustments
 */

#version 120

uniform sampler2D colortex0;     // Main color buffer (from composite)

varying vec2 texcoord;

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;
    
    // Optional: Add final adjustments here
    // - Gamma correction (if needed)
    // - Contrast enhancement
    // - Vignette
    
    // For now, simple pass-through
    gl_FragColor = vec4(color, 1.0);
}
