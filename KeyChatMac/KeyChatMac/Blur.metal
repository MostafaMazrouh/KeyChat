//
//  Blur.metal
//  KeyChatMac
//
//  Created by Mostafa Mazrouh on 2024-06-23.
//

#include <metal_stdlib>
using namespace metal;

kernel void gaussianBlur(
    texture2d<float, access::read> inTexture [[texture(0)]],  // Input texture
    texture2d<float, access::write> outTexture [[texture(1)]], // Output texture
    uint2 gid [[thread_position_in_grid]]) {  // Thread position in grid

    // Get the width and height of the textures
    uint width = inTexture.get_width();
    uint height = inTexture.get_height();

    // Calculate flipped y-coordinate to correct image orientation
    uint flippedY = height - 1 - gid.y;

    // Check if the current thread's position is within the bounds of the output texture
    if (gid.x >= width || gid.y >= height) {
        return;
    }

    // Define the blur radius and sigma for the Gaussian function
    const int blurRadius = 5;
    const float sigma = blurRadius / 2.0;
    const float twoSigmaSq = 2.0 * sigma * sigma;

    // Initialize the color and total weight accumulators
    float4 color = float4(0.0);
    float totalWeight = 0.0;

    // Iterate over the kernel
    for (int x = -blurRadius; x <= blurRadius; ++x) {
        for (int y = -blurRadius; y <= blurRadius; ++y) {
            
            // Calculate the Gaussian weight
            float weight = exp(-(x * x + y * y) / twoSigmaSq);
            
            // Calculate the sample position
            int2 samplePos = int2(gid.x + x, flippedY + y);
            
            // Ensure sample position is within bounds
            if (samplePos.x >= 0 &&
                samplePos.x < (int)width &&
                samplePos.y >= 0 &&
                samplePos.y < (int)height) {
                
                // Accumulate the color weighted by the Gaussian
                color += inTexture.read(uint2(samplePos)) * weight;
                
                // Accumulate the weight
                totalWeight += weight;
            }
        }
    }

    // Normalize the accumulated color by the total weight
    color /= totalWeight;
        
    // Write the final color to the output texture
    outTexture.write(color, gid);
}
