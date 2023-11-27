shader_type spatial;
/*
  AUTHOR: Hannah "EMBYR" Crawford
  ENGINE_VERSION: 4.0.3

  HOW TO USE:
    1. Create a MeshInstance3D node and place it in your scene.
    2. Set it's size to 2x2.
    3. Enable the "Flip Faces" option.
    4. Create a new shader material with this shader.
    5. Assign the material to the MeshInstance3D

  LIMITATIONS:
    Does not work well with TAA enabled.

  MOBILE_NOTES:
    The mobile renderer does not have access to the normal_roughness texture
    so we must rely on techniques to reconstruct this information from the
    depth buffer.

    If you require support on mobile please uncomment the SUPPORT_MOBILE line
    below. I have done my best to match the appearance between the two modes
    however, mobile does not take into account smooth-shaded faces.

    The high-quality reconstruction method used on mobile is rather heavy on
    texture samples. If you would like to use the lower-quality recontruction
    method for better performance, please uncomment the NAIVE_NORMAL_RECONSTRUCTION
    line below.
*/
//#define SUPPORT_MOBILE
//#define NAIVE_NORMAL_RECONSTRUCTION
#include "outline-base.gdshaderinc"
