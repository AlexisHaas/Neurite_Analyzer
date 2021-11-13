# Neurite_Analyzer

**Citing Neurite Analyzer paper**

Please be so kind to cite our work.

Alexis J. Haas, Sylvain Prigent, Stéphanie Dutertre, Yves Le Dréan, Yann Le Page. Neurite analyzer: An original Fiji plugin for quantification of neuritogenesis in two-dimensional images. Journal of Neuroscience Methods, Volume 271, 2016, Pages 86-91. [https://doi.org/10.1016/j.jneumeth.2016.07.011](https://doi.org/10.1016/j.jneumeth.2016.07.011)

**Overview**

This macro analyses the branching of neurites in 2D microscopy images of neuronal cells

Parameters:

- Image type: Extension of the images to process

- Neurites canal: Index of the channel containing the neurites

- Min size of neurites: Neurite minimum area (in pixel<sup>2</sup>)

- Max size of cells: Cell maximum area (in pixel<sup>2</sup>)

- Brightness/Contrast Min: Minimum brightness intensity to adjust the image contrast

- Brightness/Contrast Max: Maximum brightness intensity to adjust the image contrast

Author: Yann LE PAGE

Author: Sylvain PRIGENT

Author: Alexis Haas

version: 1.0

Date: 12/2015
  
**Short user guide for Neurite Analyzer Plugin**

**I - Limitation of the Plugin and technical recommendations:**

Neurite Analyzer was originally designed to work with differentiated neuronal cell lines. An option also exists for cells presenting a high density of neurites, such as cultured primary neurons. The plugin was tested in various conditions, but the user must keep in mind important technical recommendations:

- **Plate the cells at a density which avoids formation of cells aggregates**. A too high cell density could lead to a fusion of individual cells by the plugin during analysis and to an overestimation of the number of neurites per cell.
- **Use a picture resolution as close as possible to 1024x1024 pixels at 300 dpi.** Pictures with a higher size must be resized with the &quot;image/adjust/size&quot; function of Fiji, in order to optimize analysis.
- **The use of a low magnification leads to an underestimation of neurites length.** For most cells, at least 20x magnification is recommended. Note that the minimum size required for a nucleus is 100 pixels square.
- **Pictures with artifactual fluorescence or out of focus must be removed of the analyzed set, before running the plugin.**
- **If the neurite density is high, check the option &quot;High cells density&quot;**. This option solves the problems of cells and neurites segmentation, but can lead to an overestimation of the &quot;number of neurites per cell&quot; parameter.

**II - Install and run the Plugin:**

1. Download and install Fiji software on your computer: [http://fiji.sc/Fiji](http://fiji.sc/Fiji)
2. Download &quot;Neurite Analyzer.ijm&quot; file and copy it in the &quot;Macros&quot; directory of the Fiji installation directory (C:\Program Files\Fiji.app\macros).
3. Put all your images in the same folder. Note that a set of three images can be downloaded from the repository for demonstration. All images must have the same size and the same filename extension. The filename extension should be &quot;.bmp&quot;; &quot;.tif&quot;; or &quot;.jpg&quot;.
4. To run the plugin, go to Plugins/Macros/Run in the Fiji software, select the directory used in step 2, and then double-click on &quot;Neurite Analyzer.ijm&quot;.

**III - Adjust the plugin parameters:**

1. Select the input directory, which is the directory of the file containing your images.
2. Select the output directory, which is the directory of the file that will contain all the results of the analysis.
3. Select the &quot;image type&quot;, which is the filename extension of your images.
4. Select the &quot;Neurites channel&quot;. This is the channel used to stain the neurites.
5. Select the &quot;Min size of neurites&quot;. This parameter depends of the size of your images (best size is 1024x1024 pixels) and must be carefully adjusted to exclude small particles that are not neurites. You can start with a small value and increase this value until only neurites of the minimum required size are drawn in the file &quot;\_neurite\_per\_cell.tif&quot;, after analysis.
6. Select the &quot;Max size of cells&quot;. This parameter must be carefully adjusted to exclude groups of cells from the analysis. You can start with a high value and reduce it until no cell aggregates are shown in the file &quot;\_projection.tif&quot;, after analysis.
7. Select the &quot;Brigthness/Contrast&quot; minimum and maximum values. You can adjust those parameters if your images are too dark and if the neurites are not recognized by the plugin. Always use the same values if you want to compare different set of images.
8. Clicking &quot;OK&quot; starts the analysis. Time taken for the process will depend on the RAM installed on your computer and on the number and size of images. When analysis is completed, you will find all the results in the directory selected on step 2.

