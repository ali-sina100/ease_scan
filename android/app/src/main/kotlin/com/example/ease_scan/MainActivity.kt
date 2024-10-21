package com.example.ease_scan
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sqrt
class MainActivity: FlutterActivity() {
    
    private val CHANNEL = "com.sample.edgedetection/processor"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!OpenCVLoader.initDebug()) {
            Log.e(TAG, "OpenCV initialization failed")
        } else {
            Log.i(TAG, "OpenCV initialization succeeded")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

             
            if (call.method == "processImage") {

                val byteArray = call.argument<ByteArray>("byteData")
                val width = call.argument<Double>("width") 
                val height = call.argument<Double>("height")


               if (byteArray != null && width != null && height != null){
                    val convertedWidth: Int = width.toInt()
                    val convertedHeight: Int = height.toInt()
                    val bitmap = convertYUV420ToBitmap(byteArray, convertedWidth, convertedHeight)
                
                bitmap?.let {
                    val corners = processImage(it)
                    if (corners != null) {
                        // Send corners data back to Flutter if needed
//                        val modifiedString = corners.corners.toString().replace("{", "[")
//                                  .replace("}", "]")
                        // change corners to [{x: 0, y: 0}, {x: 0, y: 0}, {x: 0, y: 0}, {x: 0, y: 0}]
                       val pointsList = corners.corners.mapNotNull { point ->
            point?.let {
                mapOf("x" to it.x, "y" to it.y)
            }
        }
                        result.success(pointsList)
                        
                        


                        
                    } else {
                        result.error("Bitmap Conversion", "Failed to convert ByteArray to Bitmap", null)
                    }
                } ?: run {
                    result.error("Bitmap Conversion", "Failed to convert ByteArray to Bitmap", null)
                }
            }else {
                result.notImplemented()
            }}
            else if(call.method == "cropImage"){
                val image_path = call.argument<String>("image_path")
                // Get all files in the directory '/files/temp/' and list
                val directoryPath = applicationContext.filesDir.absolutePath + "/temp/"
                 val croppedImagePath = applicationContext.filesDir.absolutePath + "/cropped/"
                // Load the copy of image from the absolute path
                val image = File(image_path)
                // Convert image to bitmap
                BitmapFactory.decodeFile(image?.absolutePath)?.let {
                    val croppedImageMat: Mat? = cropImageProcess(it)
                    croppedImageMat?.let { mat ->
                        // Convert the cropped image to a Bitmap
                        val croppedImage = Bitmap.createBitmap(mat.cols(), mat.rows(), Bitmap.Config.ARGB_8888)
                        if (croppedImage != null) {
                            // Save the cropped image into '/files/cropped/' directory already created
                           
                            val croppedImageFile = File(croppedImagePath,"cropped_image_${System.currentTimeMillis()}.png")
                            Utils.matToBitmap(mat, croppedImage)
                            if (!croppedImageFile.parentFile.exists()) {
                                croppedImageFile.parentFile.mkdirs()
                            }
                            val croppedImageOutputStream = FileOutputStream(croppedImageFile)
                            croppedImage.compress(Bitmap.CompressFormat.PNG, 100, croppedImageOutputStream)
                            croppedImageOutputStream.close()
                            result.success(croppedImageFile.absolutePath)
                        } else {
                            result.error("CROPPED_IMAGE_NULL", "Cropped image is null", null)
                        }
                    } ?: run {
                        result.error("CROPPED_IMAGE_MAT_NULL", "Cropped image Mat is null", null)
                    }
                } ?: run {
                    result.error("IMAGE_NULL", "Image is null", null)
                }

            }
            // Filters
            else if(call.method == "applyFilter") {
                var imagePath = call.argument<String>("image_path")
                var filterName = call.argument<String>("filter_name")
                if (imagePath != null) {
                    val filterProcessor = FilterProcessor.getInstance(applicationContext)
                    if(filterName == "GREYSCALE"){
                        imagePath = filterProcessor.processGreyImage(imagePath)
                    }
                    else if(filterName == "NO_SHADOW"){
                        imagePath = filterProcessor.processNoShadowImage(imagePath)
                    }
                    else if(filterName == "BLACK_WHITE"){
                        imagePath = filterProcessor.processBlackWhiteImage(imagePath)
                    }
                    // else if(filterName == "INVERT"){
                    //     imagePath = filterProcessor.processInvertImage(imagePath)
                    // }
                    else if(filterName == "LIGHTEN"){
                        imagePath = filterProcessor.processLightenImage(imagePath)
                    }
                   else if(filterName == "ENHANCE"){
                        imagePath = filterProcessor.processEnhanceImage(imagePath)
                    }
                   
                    else{
                        result.error("FILTER_NOT_FOUND", "Filter not found", null)
                    }
                    result.success(imagePath)
                }
            }
        }
    }


    // Function to convert Mat to byte array

    fun matToByteArray(mat: Mat): ByteArray? {
        // Create a Bitmap from the Mat
        val bitmap = Bitmap.createBitmap(mat.cols(), mat.rows(), Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(mat, bitmap)

        // Create a ByteArrayOutputStream to hold the compressed image
        val byteArrayOutputStream = ByteArrayOutputStream()
        
        // Compress the Bitmap to PNG or JPEG
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)

        // Convert the output stream to a byte array
        return byteArrayOutputStream.toByteArray()
    }

    
    // Convert image to bitmap
    private fun convertYUV420ToBitmap(imageData: ByteArray, width: Int, height: Int): Bitmap? {
        try {
            val yuvImage = YuvImage(imageData, ImageFormat.NV21, width, height, null)
            val out = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, width, height), 100, out)
            val imageBytes = out.toByteArray()
            return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
    //cropImageProcess function
    private fun cropImageProcess(bitmap: Bitmap): Mat? {
        val mat = Mat()
        Utils.bitmapToMat(bitmap, mat)
        val corners = processPicture(mat)
        // Ensure corners is not null and contains non-null Points
        val croppedImageMat = if (corners != null && corners.corners.all { it != null }) {
            cropPicture(mat, corners.corners.filterNotNull())
        } else {
            null
        }
        // Rotate the cropped image 90 degres
        Core.rotate(croppedImageMat, croppedImageMat, Core.ROTATE_90_CLOCKWISE)

        //apply gaussian blur
        Imgproc.GaussianBlur(croppedImageMat, croppedImageMat, Size(5.0, 5.0), 0.0)

       //  Enhance the cropped image
        //  Imgproc.cvtColor(croppedImageMat, croppedImageMat, Imgproc.COLOR_RGBA2GRAY)
        //     Imgproc.adaptiveThreshold(
        //         croppedImageMat,
        //         croppedImageMat,
        //         255.0,
        //         Imgproc.ADAPTIVE_THRESH_MEAN_C,
        //         Imgproc.THRESH_BINARY,
        //         15,
        //         15.0
        //     )
        // mat.release()
        return croppedImageMat
    }
//  private fun cropImageProcess(bitmap: Bitmap): Mat? {
//     val mat = Mat()
//     Utils.bitmapToMat(bitmap, mat)
//     val corners = processPicture(mat)
//     // Ensure corners is not null and contains non-null Points
//     val croppedImageMat = if (corners != null && corners.corners.all { it != null }) {
//         cropPicture(mat, corners.corners.filterNotNull())
//     } else {
//         null
//     }

//     if (croppedImageMat != null) {
//     Core.rotate(croppedImageMat, croppedImageMat, Core.ROTATE_90_CLOCKWISE)
//     mat.release()
//     return croppedImageMat
//     }

//     mat.release()
//     return null; 
// }

    // Function to start manage the process of finding corners
    private fun processImage(bitmap: Bitmap): Corners? {
        val mat = Mat()
        Utils.bitmapToMat(bitmap, mat)
        val corners = processPicture(mat)
        mat.release()
        return corners
    }

fun processPicture(previewFrame: Mat): Corners? {
    val contours = findContours(previewFrame)
    return getCorners(contours, previewFrame.size())
}


// Crop image and return as a Matrix
fun cropPicture(picture: Mat, pts: List<Point>): Mat {

    pts.forEach { Log.i(TAG, "point: $it") }
    val tl = pts[0]
    val tr = pts[1]
    val br = pts[2]
    val bl = pts[3]

    val widthA = sqrt((br.x - bl.x).pow(2.0) + (br.y - bl.y).pow(2.0))
    val widthB = sqrt((tr.x - tl.x).pow(2.0) + (tr.y - tl.y).pow(2.0))

    val dw = max(widthA, widthB)
    val maxWidth = java.lang.Double.valueOf(dw).toInt()

    val heightA = sqrt((tr.x - br.x).pow(2.0) + (tr.y - br.y).pow(2.0))
    val heightB = sqrt((tl.x - bl.x).pow(2.0) + (tl.y - bl.y).pow(2.0))

    val dh = max(heightA, heightB)
    val maxHeight = java.lang.Double.valueOf(dh).toInt()

    val croppedPic = Mat(maxHeight, maxWidth, CvType.CV_8UC4)

    val srcMat = Mat(4, 1, CvType.CV_32FC2)
    val dstMat = Mat(4, 1, CvType.CV_32FC2)

    
    srcMat.put(0, 0, tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y)
    dstMat.put(0, 0, 0.0, 0.0, dw, 0.0, dw, dh, 0.0, dh)

    val m = Imgproc.getPerspectiveTransform(srcMat, dstMat)

    Imgproc.warpPerspective(picture, croppedPic, m, croppedPic.size())
    m.release()
    srcMat.release()
    dstMat.release()
    Log.i(TAG, "crop finish")
    return croppedPic
}
// Magic Color filter
fun applyBrightnessContrast(inputImg: Mat, brightness: Int = 0, contrast: Int = 0): Mat {
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

fun enhancePicture(src: Bitmap?): Bitmap {
    val srcMat = Mat()
    Utils.bitmapToMat(src, srcMat)
    Imgproc.cvtColor(srcMat, srcMat, Imgproc.COLOR_RGBA2GRAY)
    Imgproc.adaptiveThreshold(
        srcMat,
        srcMat,
        255.0,
        Imgproc.ADAPTIVE_THRESH_MEAN_C,
        Imgproc.THRESH_BINARY,
        15,
        15.0
    )
    val result = Bitmap.createBitmap(src?.width ?: 1080, src?.height ?: 1920, Bitmap.Config.RGB_565)
    Utils.matToBitmap(srcMat, result, true)
    srcMat.release()
    return result
}

private fun findContours(src: Mat): List<MatOfPoint> {

    val grayImage: Mat
    val cannedImage: Mat
    val kernel: Mat = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(9.0, 9.0))
    val dilate: Mat
    val size = Size(src.size().width, src.size().height)
    grayImage = Mat(size, CvType.CV_8UC4)
    cannedImage = Mat(size, CvType.CV_8UC1)
    dilate = Mat(size, CvType.CV_8UC1)

    Imgproc.cvtColor(src, grayImage, Imgproc.COLOR_BGR2GRAY)
    Imgproc.GaussianBlur(grayImage, grayImage, Size(5.0, 5.0), 0.0)
    Imgproc.threshold(grayImage, grayImage, 20.0, 255.0, Imgproc.THRESH_TRIANGLE)
    Imgproc.Canny(grayImage, cannedImage, 75.0, 200.0)
    Imgproc.dilate(cannedImage, dilate, kernel)
    val contours = ArrayList<MatOfPoint>()
    val hierarchy = Mat()
    Imgproc.findContours(
        dilate,
        contours,
        hierarchy,
        Imgproc.RETR_TREE,
        Imgproc.CHAIN_APPROX_SIMPLE
    )

    val filteredContours = contours
        .filter { p: MatOfPoint -> Imgproc.contourArea(p) > 100e2 }
        .sortedByDescending { p: MatOfPoint -> Imgproc.contourArea(p) }
        .take(25)

    hierarchy.release()
    grayImage.release()
    cannedImage.release()
    kernel.release()
    dilate.release()

    return filteredContours
}

private fun getCorners(contours: List<MatOfPoint>, size: Size): Corners? {
    val indexTo: Int = when (contours.size) {
        in 0..5 -> contours.size - 1
        else -> 4
    }
    for (index in 0..contours.size) {
        if (index in 0..indexTo) {
            val c2f = MatOfPoint2f(*contours[index].toArray())
            val peri = Imgproc.arcLength(c2f, true)
            val approx = MatOfPoint2f()
            Imgproc.approxPolyDP(c2f, approx, 0.03 * peri, true)
            val points = approx.toArray().asList()
            val convex = MatOfPoint()
            approx.convertTo(convex, CvType.CV_32S)
            // select biggest 4 angles polygon
            if (points.size == 4 && Imgproc.isContourConvex(convex)) { 
                val foundPoints = sortPoints(points)
                return Corners(foundPoints, size)
            }
        } else {
            return null
        }
    }

    return null
}
    private fun sortPoints(points: List<Point>): List<Point> {
        val p0 = points.minByOrNull { point -> point.x + point.y } ?: Point()
        val p1 = points.minByOrNull { point: Point -> point.y - point.x } ?: Point()
        val p2 = points.maxByOrNull { point: Point -> point.x + point.y } ?: Point()
        val p3 = points.maxByOrNull { point: Point -> point.y - point.x } ?: Point()
        return listOf(p0, p1, p2, p3)
    }
}