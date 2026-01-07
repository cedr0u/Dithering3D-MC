/*
 * Surface-Stable Fractal Dithering - Composite Vertex Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Post-processing composite pass (currently pass-through)
 */

#version 120

varying vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
}
