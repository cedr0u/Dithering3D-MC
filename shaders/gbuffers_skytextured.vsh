/*
 * Surface-Stable Fractal Dithering - Sky Textured Vertex Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Vertex shader for textured sky (sun, moon, stars)
 */

#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 screenPos;

void main() {
    gl_Position = ftransform();
    screenPos = gl_Position;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}
