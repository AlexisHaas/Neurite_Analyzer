/**
 * This macro analyse the branching of neurites
 * Parameters: 
 *      - Image type: Extension of the images to process
 *		- Neurites canal: Index of the channel containing the neurites 
 *		- Min size of neurites: Neurite minimum area (in pixel^2) 
 *		- Max size of cells: Cell maximum area (in pixel^2)
 *		- Brightness/Contrast Min: Minimum brightness intensity to adjust the image contrast
 * 		- Brightness/Contrast Max: Maximum brightness intensity to adjust the image contrast
 * 
 * @Author: Yann LE PAGE
 * @Author: Sylvain PRIGENT
 * @Author: Alexis Haas

 * @version: 1.0
 * @Date: 12/2015
 */
macro "Neurites Analysis" {

	// dialog to get IO and parameters
	repertoire = getDirectory("Select the input directory");
	liste_fichiers = getFileList(repertoire);

	outputDir = getDirectory("Select the output directory");

	Dialog.create("Select parameters");
	extensions = newArray(".tif", ".jpg", ".bmp");
	Dialog.addChoice("Image type: ",extensions,0);

	couleur = newArray("red", "green");
	Dialog.addChoice("Neurites channel?",couleur,0);
	Dialog.addNumber("Min size of neurites (pixel^2)?",150)
	Dialog.addNumber("Max size of cells (pixel^2)?",6000)
	Dialog.addSlider("Brightness/Contrast Min",1,255,0);
	Dialog.addSlider("Brightness/Contrast Max",1,255,100);
	Dialog.addCheckbox("In vivo ?", false);
	Dialog.show();

	extension = Dialog.getChoice();
	couleur1 = Dialog.getChoice();
	min_neurite = Dialog.getNumber();
	max_cell = Dialog.getNumber();
	min_bright = Dialog.getNumber();
	max_bright = Dialog.getNumber();
	in_vivo = Dialog.getCheckbox();

	// remove previous outputs if exists
	freeSummaryFiles(outputDir);
	
	// Main Processing
	for(i=0; i<liste_fichiers.length; i++) {
		chemin = repertoire + liste_fichiers[i];
		if (endsWith(chemin,extension)) {

			if(in_vivo){
				inVivoNeuritesAnalysis(chemin, outputDir, couleur1, min_neurite, max_cell, min_bright, max_bright);
			}
			else{
				neuritesAnalysis(chemin, outputDir, couleur1, min_neurite, max_cell, min_bright, max_bright);
			}
		}
	}
	
	// Generate summary files
	for(i=0; i<liste_fichiers.length; i++) {
		chemin = repertoire + liste_fichiers[i];
		if (endsWith(chemin,extension)) {

			startIdx = 1;
			if (i == 0){
				startIdx = 0;
			}
			appendSummmaryFile(outputDir, liste_fichiers[i], "_branch_information.xls", startIdx);
			appendSummmaryFile(outputDir, liste_fichiers[i], "_neurites_analysis.xls", startIdx);
			appendSummmaryFile(outputDir, liste_fichiers[i], "_neurites_per_cell.xls", startIdx);
			appendNucleusSummary(outputDir, liste_fichiers[i]);
		}
	}
}

/**
 * Remove the summary files if they exists in the output directory
 * @param outputDir Directory where the results are save 
 */
function freeSummaryFiles(outputDir){

	arrayFiles = newArray(4);
	arrayFiles[0] = outputDir + "summary" + "_branch_information.xls";
	arrayFiles[1] = outputDir + "summary" + "_neurites_analysis.xls";
	arrayFiles[2] = outputDir + "summary" + "_neurites_per_cell.xls";
	arrayFiles[3] = outputDir + "summary" + "_nucleus.xls";

	for( i = 0 ; i < arrayFiles.length ; i++){
		summaryFilePath = arrayFiles[i];
		if (File.exists(summaryFilePath)){
			File.delete(summaryFilePath);
		}
	}
}

/**
 * Append a txt file to the end of a second file. Needed to create a summary file
 * @param outputDir Directory containing the files
 * @param imageName Base name of the txt file to append
 * @param fileEndStr Suffix of the txt file name to append (also used for the final file suffix)
 */
function appendSummmaryFile(outputDir, imageName, fileEndStr, startIdx){

	
	subImageName = substring(imageName,0,lengthOf(imageName)-4);
	curentImagePath = outputDir + subImageName + fileEndStr; 
	curentImageContent = File.openAsString(curentImagePath);
	lines=split(curentImageContent,"\n");
	content = "";
	
	for(l = startIdx ; l < lines.length ; l++){
		if (l==0){
			content += "image name" + "\t" + lines[l] + "\n";
		}
		else{
			content += subImageName + "\t" + lines[l];
			if (l < lines.length-1){
				content += "\n";
			}
		}
	}
	

	summaryFilePath = outputDir + "summary" + fileEndStr;
	if (!File.exists(summaryFilePath)){
		f = File.open(summaryFilePath);
		File.close(f);
	}
	File.append( content, summaryFilePath);
}

/**
 * Create a Nucleus summary xls file calculating the number of nucleus for each image
 * @param outputDir Directory containing the files
 * @param imageName Base name of the txt file process
 */
function appendNucleusSummary(outputDir, imageName){

	subImageName = substring(imageName,0,lengthOf(imageName)-4);
	curentImagePath = outputDir + subImageName + "_nucleus.xls"; 
	curentImageContent = File.openAsString(curentImagePath);
	lines=split(curentImageContent,"\n"); 
	NbNucleus = lines.length-1;
	contentTxt = subImageName + "\t" + NbNucleus;

	summaryFilePath = outputDir + "summary_nucleus.xls";
	if (!File.exists(summaryFilePath)){
		f = File.open(summaryFilePath);
		File.close(f);
	}
	File.append( contentTxt, summaryFilePath);
}

/**
 * Main function that does the neurites analysis
 * @param chemin Adress of the image to process
 * @param outputDir Directory where the results are save 
 * @param couleur1 Channel containing the neurites
 * @param min_neurite Minimum area of a neurite (in pixel^2)
 * @param max_cell Maximum area of a cell (in pixel^2)
 * @param min_bright Minimum brightness intensity to adjust the image contrast
 * @max_bright Maximum brightness intensity to adjust the image contrast
 */
function neuritesAnalysis(chemin, outputDir, couleur1, min_neurite, max_cell, min_bright, max_bright){
	
	open(chemin);
	run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	name = getTitle();
	rename("image001");
	run("Split Channels");


	// Comptage des noyaux:

	selectWindow("image001 (blue)");
	run("Gaussian Blur...", "sigma=2");
	setAutoThreshold("Otsu dark");
	
	//run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Watershed");
	run("Set Measurements...", "area redirect=None decimal=0");
	run("Analyze Particles...", "size=100-Infinity show=Outlines display clear");
	selectWindow("Drawing of image001 (blue)");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_nucleus.tif");
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_nucleus.xls");
	close();
	run("Clear Results");

	selectWindow("image001 (blue)");
	close();
	
	// Traçage des neurites:

	selectWindow("image001 (" + couleur1 + ")");
	run("Duplicate...", " ");
	
	//run("Brightness/Contrast...");
	setMinAndMax(min_bright, max_bright);
	run("Apply LUT");
		
	run("Frangi Vesselness (imglib, experimental)", "number=10 minimum=1.000000 maximum=1.000000");
	setAutoThreshold("Mean dark");
	//run("Threshold...");
	setAutoThreshold("Mean");
	setAutoThreshold("Mean dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Make Binary");
	selectWindow("image001 (" + couleur1 + ")");
	close();

	selectWindow("image001 (" + couleur1 + ")-1");
	run("Gray Morphology", "radius=10 type=circle operator=erode");
	setAutoThreshold("Mean dark");
	//run("Threshold...");
	setAutoThreshold("RenyiEntropy dark");
	//setThreshold(37, 255);
	run("Convert to Mask");
	run("Make Binary");

	for(c = 0 ; c < 8 ; c++ ){
		run("Dilate");
		run("Watershed");
	}

	run("Invert");
	run("Divide...", "value=255");
	imageCalculator("Multiply create", "vesselness of image001 (" + couleur1 + ")-1","image001 (" + couleur1 + ")-1");
	selectWindow("vesselness of image001 (" + couleur1 + ")-1");
	close();
	
	selectWindow("Result of vesselness of image001 (" + couleur1 + ")-1");
	run("Analyze Particles...", "size="+ min_neurite + "-Infinity show=Masks clear");
	selectWindow("Result of vesselness of image001 (" + couleur1 + ")-1");
	close();
	
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-1");
	run("Fill Holes");
	setOption("BlackBackground", false);
	run("Dilate");
	run("Gaussian Blur...", "sigma=2");
	run("Make Binary");
	run("Skeletonize");
	run("Duplicate...", " ");
	

	// Calcul du nombre de neurites par cellule:

	selectWindow("image001 (" + couleur1 + ")-1");
	run("Multiply...", "value=255");
	run("Invert");

	for(c = 0 ; c < 5 ; c++ ){
		run("Dilate");
		run("Watershed");
	}
	
	run("Analyze Particles...", "size=1000-" + max_cell + " show=Nothing clear add");

	
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-1");
	run("Dilate");
	count=roiManager("count");
	array=newArray(count);
	for(j=0; j<count;j++) {array[j] = j;}
	roiManager("Select", array);
	roiManager("Add");
	run("Set Measurements...", "area integrated redirect=None decimal=0");
	run("Clear Results");
	roiManager("Measure");

	// add the neurites number
	selectWindow("Results");
	for( l = 0 ; l < nResults ; l++){	
		intDen = getResult("IntDen", l);
		setResult("# Neurites", l, round(intDen/5000.0));
	}
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_per_cell.xls");


	
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-1");
	run("Flatten");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_per_cell.tif");
	close();
	run("Clear Results");

	// Squelettisation:
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-2");
	run("Analyze Skeleton (2D/3D)", "prune=none show");

	// add the branch length
	selectWindow("Results");
	for( l = 0 ; l < nResults ; l++){	
		nbBranch = getResult("# Branches", l);
		avBranch = getResult("Average Branch Length", l);
		//print("av branch = " + avBranch +"\n");
		setResult("Total Branch Length", l, nbBranch*avBranch);
	}
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_analysis.xls");
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-2");
	close();
	selectWindow("Tagged skeleton");
	roiManager("Select", array);
	roiManager("Add");
	run("Flatten");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_skeleton.tif");
	close();

	close("Results");
    selectWindow("Branch information");
    IJ.renameResults("Branch information","Results");
	for( l = 0 ; l < nResults ; l++){	

		x1 = getResult("V1 x", l);
		y1 = getResult("V1 y", l);
		x2 = getResult("V2 x", l);
		y2 = getResult("V2 y", l);

		angle = 0;
		if (y2 < y1){
			if (x2 > x1 ){
				angle =  (180/PI) * atan( (y1 - y2)/((x2 - x1) + 0.01) ); 
			}
			else{
				angle = 180- (180/PI) * atan((y1 - y2)/((x1 - x2) + 0.01));
			}
		}
		else{
			if (x2 > x1 ){
				angle = 180 - (180/PI) * atan((y2 - y1)/((x2 - x1) + 0.01));
			}
			else{
				angle = (180/PI) * atan((y2 - y1)/((x1 - x2) + 0.01));
			}
		}
		angle = round(angle);	
		setResult("angle", l, angle);
	}
	
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_branch_information.xls");
	
	selectWindow("Results");
  	run("Close");
  	selectWindow("ROI Manager");
  	run("Close");
	
	while (nImages>0) { 
    	selectImage(nImages); 
        close();
 	}
      
	open(chemin);
	open(outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_skeleton.tif");
    run("Images to Stack", "name=Stack title=[] use");
	run("Z Project...", "projection=[Sum Slices]");
	selectWindow("SUM_Stack");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_projection.tif");
	run("Close");
    selectWindow("Stack");
	run("Close");
}

/**
 * Main function that does the neurites analysis for in vivo data
 * @param chemin Adress of the image to process
 * @param outputDir Directory where the results are save 
 * @param couleur1 Channel containing the neurites
 * @param min_neurite Minimum area of a neurite (in pixel^2)
 * @param max_cell Maximum area of a cell (in pixel^2)
 * @param min_bright Minimum brightness intensity to adjust the image contrast
 * @max_bright Maximum brightness intensity to adjust the image contrast
 */
function inVivoNeuritesAnalysis(chemin, outputDir, couleur1, min_neurite, max_cell, min_bright, max_bright){
	
	open(chemin);
	run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	name = getTitle();
	rename("image001");
	run("Split Channels");


	// Comptage des noyaux:

	selectWindow("image001 (blue)");
	run("Gaussian Blur...", "sigma=2");
	setAutoThreshold("Otsu dark");
	
	//run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Watershed");
	run("Set Measurements...", "area redirect=None decimal=0");
	run("Analyze Particles...", "size=100-Infinity show=Outlines display clear");
	selectWindow("Drawing of image001 (blue)");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_nucleus.tif");
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_nucleus.xls");
	close();
	run("Clear Results");

	// Traçage des neurites:

	selectWindow("image001 (" + couleur1 + ")");

	
	//run("Brightness/Contrast...");
	setMinAndMax(min_bright, max_bright);
	run("Apply LUT");
		
	run("Frangi Vesselness (imglib, experimental)", "number=10 minimum=1.000000 maximum=1.000000");
	setAutoThreshold("Mean dark");
	//run("Threshold...");
	setAutoThreshold("Mean");
	setAutoThreshold("Mean dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Make Binary");
	selectWindow("image001 (" + couleur1 + ")");
	close();

	selectWindow("image001 (blue)");

	for(c = 0 ; c < 8 ; c++ ){
		run("Dilate");
		run("Watershed");
	}

	run("Invert");
	run("Divide...", "value=255");
	imageCalculator("Multiply create", "vesselness of image001 (" + couleur1 + ")","image001 (blue)");
	selectWindow("vesselness of image001 (" + couleur1 + ")");
	close();
	
	selectWindow("Result of vesselness of image001 (" + couleur1 + ")");
	run("Analyze Particles...", "size="+ min_neurite + "-Infinity show=Masks clear");
	selectWindow("Result of vesselness of image001 (" + couleur1 + ")");
	close();
	
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")");
	
	setOption("BlackBackground", false);
	run("Dilate");
	run("Gaussian Blur...", "sigma=2");
	run("Make Binary");
	run("Skeletonize");
	run("Duplicate...", " ");
	

	// Calcul du nombre de neurites par cellule:

	selectWindow("image001 (blue)");
	run("Multiply...", "value=255");
	run("Invert");

	for(c = 0 ; c < 8 ; c++ ){
		run("Dilate");
		run("Watershed");
	}
	
	run("Analyze Particles...", "size=1000-" + max_cell + " show=Nothing clear add");

	
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-1");
	run("Dilate");
	count=roiManager("count");
	array=newArray(count);
	for(j=0; j<count;j++) {array[j] = j;}
	roiManager("Select", array);
	roiManager("Add");
	run("Set Measurements...", "area integrated redirect=None decimal=0");
	run("Clear Results");
	roiManager("Measure");

	// add the neurites number
	selectWindow("Results");
	for( l = 0 ; l < nResults ; l++){	
		intDen = getResult("IntDen", l);
		setResult("# Neurites", l, round(intDen/12000.0));
	}
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_per_cell.xls");


	
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")-1");
	run("Flatten");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_per_cell.tif");
	close();
	run("Clear Results");

	// Squelettisation:
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")");
	run("Analyze Skeleton (2D/3D)", "prune=none show");

	// add the branch length
	selectWindow("Results");
	for( l = 0 ; l < nResults ; l++){	
		nbBranch = getResult("# Branches", l);
		avBranch = getResult("Average Branch Length", l);
		//print("av branch = " + avBranch +"\n");
		setResult("Total Branch Length", l, nbBranch*avBranch);
	}
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_analysis.xls");
	selectWindow("Mask of Result of vesselness of image001 (" + couleur1 + ")");
	close();
	selectWindow("Tagged skeleton");
	roiManager("Select", array);
	roiManager("Add");
	run("Flatten");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_skeleton.tif");
	close();

	close("Results");
    selectWindow("Branch information");
    IJ.renameResults("Branch information","Results");
	for( l = 0 ; l < nResults ; l++){	

		x1 = getResult("V1 x", l);
		y1 = getResult("V1 y", l);
		x2 = getResult("V2 x", l);
		y2 = getResult("V2 y", l);

		angle = 0;
		if (y2 < y1){
			if (x2 > x1 ){
				angle =  (180/PI) * atan( (y1 - y2)/((x2 - x1) + 0.01) ); 
			}
			else{
				angle = 180- (180/PI) * atan((y1 - y2)/((x1 - x2) + 0.01));
			}
		}
		else{
			if (x2 > x1 ){
				angle = 180 - (180/PI) * atan((y2 - y1)/((x2 - x1) + 0.01));
			}
			else{
				angle = (180/PI) * atan((y2 - y1)/((x1 - x2) + 0.01));
			}
		}
		angle = round(angle);	
		setResult("angle", l, angle);
	}
	
	saveAs("Results", outputDir + substring(name,0,lengthOf(name)-4) + "_branch_information.xls");
	
	selectWindow("Results");
  	run("Close");
  	selectWindow("ROI Manager");
  	run("Close");
	
	while (nImages>0) { 
    	selectImage(nImages); 
        close();
 	}
      
	open(chemin);
	open(outputDir + substring(name,0,lengthOf(name)-4) + "_neurites_skeleton.tif");
    run("Images to Stack", "name=Stack title=[] use");
	run("Z Project...", "projection=[Sum Slices]");
	selectWindow("SUM_Stack");
	saveAs("Tiff", outputDir + substring(name,0,lengthOf(name)-4) + "_projection.tif");
	run("Close");
    selectWindow("Stack");
	run("Close");

}


