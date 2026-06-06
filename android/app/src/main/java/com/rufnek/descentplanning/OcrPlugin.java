package com.rufnek.descentplanning;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;

@CapacitorPlugin(name = "NativeOcr")
public class OcrPlugin extends Plugin {

    @PluginMethod
    public void recognize(PluginCall call) {
        String imageData = call.getString("imageBase64");
        if (imageData == null || imageData.isEmpty()) {
            call.reject("No image data");
            return;
        }

        try {
            // data:image/jpeg;base64,XXXX 형식에서 base64 부분만 추출
            String base64 = imageData.contains(",") ? imageData.split(",")[1] : imageData;
            byte[] bytes = Base64.decode(base64, Base64.DEFAULT);
            Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);

            if (bitmap == null) {
                call.reject("Bitmap decode failed");
                return;
            }

            InputImage image = InputImage.fromBitmap(bitmap, 0);
            TextRecognizer recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS);

            recognizer.process(image)
                .addOnSuccessListener(visionText -> {
                    JSObject result = new JSObject();
                    result.put("text", visionText.getText());
                    call.resolve(result);
                })
                .addOnFailureListener(e -> {
                    call.reject("ML Kit OCR error: " + e.getMessage());
                });

        } catch (Exception e) {
            call.reject("OCR exception: " + e.getMessage());
        }
    }
}
