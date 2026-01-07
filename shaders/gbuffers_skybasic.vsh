/*
 * Surface-Stable Fractal Dithering - Sky Basic Vertex Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Vertex shader for basic sky rendering (solid color sky)
 */

#version 120

varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 viewDir;        // View direction for spherical UV mapping

uniform mat4 gbufferModelViewInverse;

void main() {
    gl_Position = ftransform();
    screenPos = gl_Position;
    glcolor = gl_Color;
    
    // Calculate view direction in world space
    // Used for spherical UV mapping to avoid flat skybox appearance
    vec4 viewPos = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
    viewDir = normalize(viewPos.xyz);
}
