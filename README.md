# Skele's VRC Screen Shaders (VPM)

A shader that allows you to have screen-space images overlay your view without making it disorienting in VR.

## ▶ Installing

You can either [add this package to Creator Companion](https://uncleskeleton.github.io/VRCScreenShaders/) or [download a unitypackage/zip from the releases tab](https://github.com/UncleSkeleton/VRCScreenShaders/releases/latest).

## ▶ Usage

You typically will just attach a material with this shader to a sphere and increase the size. Example materials are included in "Packages/SkeleTM Screen Space Shaders/Runtime/Examples".

If you want your texture to stop repeating, select it in your Project and change Wrap Mode to Clamp in the Inspector.

## ▶ Features

- VR supported overlay, won't cause cross-eyedness for HMD users.
- Easy image scaling.
- Easy switching between cutout/fade variations.
- Use either Chroma Key or Image Alpha for Transparency.
	- Chroma Key spill reduction options also included, will softly desaturate edges to hide the green.
	![chromakeyexample](https://raw.githubusercontent.com/UncleSkeleton/VRCScreenShaders/refs/heads/main/ReadMeImages/readme_chromakey.png "Chroma Keying Options")
- QoL.
	- The shader will not attempt to overlay the VRChat UI.
	- The shader will not render beyond the range of the sphere it is attached to.
	![rangeexample](https://raw.githubusercontent.com/UncleSkeleton/VRCScreenShaders/refs/heads/main/ReadMeImages/readme_rangeexample.gif "Render Range Example")

## ▶ Credits

[Me, Skele™](https://vrchat.com/home/user/usr_bbf66239-5d7b-4873-a7e6-05e23f90b093) - Shader, Scripting, GUI Art

[z3y's ShaderGraphVRC](https://github.com/z3y/ShaderGraphVRC) - Shader Graph for VRC BIRP

[SapphireSouls](https://vrchat.com/home/user/usr_8cd1c6d6-3644-411b-8918-93ca656b0e38) - Guidance, Suggestions, Moral Support

[Unity](https://unity.com/legal/licenses/unity-companion-license) - Original Shader Graph, Companion License