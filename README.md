# Skele's VRC Screen Shaders (VPM)

A shader that allows you to have screen-space images overlay your view without making it disorienting in VR.

## ▶ Installing

You can either [Add this package to Creator Companion](https://uncleskeleton.github.io/VRCScreenShaders/) or [Add it manually from the releases tab](https://github.com/UncleSkeleton/VRCScreenShaders/releases/latest).

## ▶ Usage

You typically will just attach a material with this shader to a sphere and increase the size. Example materials are included in "Packages/SkeleTM Screen Space Shaders/Runtime/Examples".

## ▶ Features

	* VR supported overlay, won't cause cross-eyedness for HMD users.
	* Easy image scaling.
	* Easy switching between cutout/fade variations.
	* Use either Chroma Key or Image Alpha for Transparency.
		* Chroma Key spill reduction options also included, will softly desaturate edges to hide the green.
	* QoL.
		* The shader will not attempt to overrender the VRChat UI.
		* The shader will not render beyond the range of the sphere it is attached to.
		