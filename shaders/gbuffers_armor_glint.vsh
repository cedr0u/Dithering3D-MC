/*
 * Surface-Stable Fractal Dithering - Armor Glint Vertex Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Vertex shader for enchantment glint effect
 */

#version 120

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 worldPos;

void main() {
    gl_Position = ftransform();
    screenPos = gl_Position;
    
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPosH = gbufferModelViewInverse * viewPos;
    worldPos = worldPosH.xyz + cameraPosition;
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}
