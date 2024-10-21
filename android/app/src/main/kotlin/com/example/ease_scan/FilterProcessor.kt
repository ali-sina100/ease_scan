import android.content.Context
import org.opencv.core.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.core.Core
import java.io.File



class FilterProcessor private constructor(private val context: Context) {

    private val filteredImagePath: String = context.filesDir.absolutePath + "/filtered/"

    companion object {
        @Volatile
        private var instance: FilterProcessor? = null

        fun getInstance(context: Context): FilterProcessor {
            return instance ?: synchronized(this) {
                instance ?: FilterProcessor(context).also { instance = it }
            }
        }
    }

    // Method to process the grey Image
    // Step 1: Take the image Path
    // Step 2: Apply grey filter
    // Step 3: Save the new file in the files/filtered/filtered_2323.jpg
    fun processGreyImage(imagePath: String): String {
        // Step 1
        val src = Imgcodecs.imread(imagePath)
        // Step 2
        val grey = Mat()
        Imgproc.cvtColor(src, grey, Imgproc.COLOR_BGR2GRAY)
        // Step 3
        val newImagePath = filteredImagePath + "filtered_" + System.currentTimeMillis() + ".jpg"
        // Create the directory if it doesn't exist

        val directory = File(filteredImagePath)
        if (!directory.exists()) {
            directory.mkdirs()
        }
        // save the grey image into newImagePath
        Imgcodecs.imwrite(newImagePath, grey)
        return newImagePath
    }

    // Method to process No Shadow filter
    // Step 1: Take the image Path
    // Step 2: Apply No Shadow filter
    // Step 3: Save the new file in the files/filtered/filtered_2323.jpg
    fun processNoShadowImage(imagePath: String): String {
        // Step 1
        val src = Imgcodecs.imread(imagePath)

        // Step 2
        val noShadow = Mat()
        Imgproc.cvtColor(src, noShadow, Imgproc.COLOR_BGR2GRAY)
        Imgproc.adaptiveThreshold(
            noShadow,
            noShadow,
            255.0,
            Imgproc.ADAPTIVE_THRESH_MEAN_C,
            Imgproc.THRESH_BINARY,
            15,
            15.0
        )
        // Step 3
        val newImagePath = filteredImagePath + "filtered_" + System.currentTimeMillis() + ".jpg"

        Imgcodecs.imwrite(newImagePath, noShadow)
        return newImagePath
    }
    // Method to process Black and White filter
    // Step 1: Take the image Path
    // Step 2: Apply Black and White filter
    // Step 3: Save the new file in the files/filtered/filtered_2323.jpg
    fun processBlackWhiteImage(imagePath: String): String {
        // Step 1
        val src = Imgcodecs.imread(imagePath)
        // Step 2
        val blackWhite = Mat()
        Imgproc.cvtColor(src, blackWhite, Imgproc.COLOR_BGR2GRAY)
        Imgproc.adaptiveThreshold(
            blackWhite,
            blackWhite,
            255.0,
            Imgproc.ADAPTIVE_THRESH_MEAN_C,
            Imgproc.THRESH_BINARY,
            11, // Decrease the block size to make the filter more intense
            10.0  // Decrease the constant to make the filter more intense
        )
        // Step 3
        val newImagePath = filteredImagePath + "filtered_" + System.currentTimeMillis() + ".jpg"
        Imgcodecs.imwrite(newImagePath, blackWhite)
        return newImagePath
    }

    // Method to process Invert filter
    // Step 1: Take the image Path
    // Step 2: Apply Invert filter
    // Step 3: Save the new file in the files/filtered/filtered_2323.jpg
    // fun processInvertImage(imagePath: String): String {
    //     // Step 1
    //     val src = Imgcodecs.imread(imagePath)
    //     // Step 2
    //     val invert = Mat()
    //     Core.bitwise_not(src, invert)
    //     // Step 3
    //     val newImagePath = filteredImagePath + "filtered_" + System.currentTimeMillis() + ".jpg"
    //     Imgcodecs.imwrite(newImagePath, invert)
    //     return newImagePath
    // }

    // Method to process lighten filter
    // Step 1: Take the image Path
    // Step 2: Apply lighten filter
    // Step 3: Save the new file in the files/filtered/filtered_2323.jpg
    fun processLightenImage(imagePath: String): String {
        // Step 1
        val src = Imgcodecs.imread(imagePath)
        // Step 2
        val lighten = Mat()
        Core.add(src, Scalar(20.0, 20.0, 20.0), lighten)
        // Step 3
        val newImagePath = filteredImagePath + "filtered_" + System.currentTimeMillis() + ".jpg"
        Imgcodecs.imwrite(newImagePath, lighten)
        return newImagePath
    }

    // Method to process Enhance filter
    // Step 1: Take the image Path
    // Step 2: Apply Enhance filter
    // Step 3: Save the new file in the files/filtered/filtered_2323.jpg
    // the enhance filter result is a colorful image with more contrast and text is more readable
    fun processEnhanceImage(imagePath: String): String {
        // Step 1
        val src = Imgcodecs.imread(imagePath)
        // Step 2
        val enhance = applyBrightnessContrast(src, brightness = 0, contrast = 40)
        // Step 3
        val newImagePath = filteredImagePath + "filtered_" + System.currentTimeMillis() + ".jpg"
        Imgcodecs.imwrite(newImagePath, enhance)
        return newImagePath
    }

   // Magic Color filter
  private  fun applyBrightnessContrast(inputImg: Mat, brightness: Int = 0, contrast: Int = 0): Mat {
        val outputImg = Mat()
        inputImg.copyTo(outputImg)

        if (brightness != 0) {
            val shadow = if (brightness > 0) brightness else 0
            val highlight = if (brightness > 0) 255 else 255 + brightness
            val alphaB = (highlight - shadow) / 255.0
            val gammaB = shadow.toDouble()

            Core.addWeighted(inputImg, alphaB, inputImg, 0.0, gammaB, outputImg)
        }

        if (contrast != 0) {
            val f = 131.0 * (contrast + 127) / (127 * (131 - contrast))
            val alphaC = f
            val gammaC = 127 * (1 - f)

            Core.addWeighted(outputImg, alphaC, outputImg, 0.0, gammaC, outputImg)
        }

        return outputImg
    }
}
