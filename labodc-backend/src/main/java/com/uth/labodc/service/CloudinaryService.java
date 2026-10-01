package com.uth.labodc.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryService {

    private final Cloudinary cloudinary;

    @Value("${cloudinary.folder}")
    private String folder;

    /**
     * Upload PDF file to Cloudinary
     * @param pdfBytes PDF file content as byte array
     * @param fileName File name (without extension)
     * @return Cloudinary secure URL
     */
    public String uploadPDF(byte[] pdfBytes, String fileName) {
        try {
            log.info("Uploading PDF to Cloudinary: {}", fileName);
            
            // Convert byte array to Base64 data URI
            String base64Data = "data:application/pdf;base64," + Base64.getEncoder().encodeToString(pdfBytes);
            
            Map<String, Object> uploadParams = ObjectUtils.asMap(
                "folder", folder,
                "public_id", fileName, // Don't add .pdf - Cloudinary adds it automatically
                "resource_type", "raw", // Use raw for PDF files
                "type", "upload", // Upload type (not authenticated)
                "access_mode", "public", // Make file publicly downloadable
                "overwrite", true, // Overwrite if file already exists
                "invalidate", true // Invalidate CDN cache
            );
            
            Map uploadResult = cloudinary.uploader().upload(
                base64Data, 
                uploadParams
            );
            
            String secureUrl = (String) uploadResult.get("secure_url");
            
            log.info("PDF uploaded successfully: {}", secureUrl);
            
            return secureUrl;
            
        } catch (Exception e) {
            log.error("Failed to upload PDF to Cloudinary: {}", fileName, e);
            throw new RuntimeException("Failed to upload file to Cloudinary: " + e.getMessage());
        }
    }

    /**
     * Delete file from Cloudinary
     * @param publicId Cloudinary public_id (e.g., "labodc/transparency-reports/report_123")
     */
    public void deleteFile(String publicId) {
        try {
            log.info("Deleting file from Cloudinary: {}", publicId);
            
            Map deleteParams = ObjectUtils.asMap(
                "resource_type", "raw",
                "invalidate", true
            );
            
            Map deleteResult = cloudinary.uploader().destroy(publicId, deleteParams);
            log.info("File deleted from Cloudinary: {}, result: {}", publicId, deleteResult.get("result"));
            
        } catch (Exception e) {
            log.error("Failed to delete file from Cloudinary: {}", publicId, e);
            throw new RuntimeException("Failed to delete file from Cloudinary: " + e.getMessage());
        }
    }

    /**
     * Extract public_id from Cloudinary URL
     * @param cloudinaryUrl Full Cloudinary URL
     * @return Public ID or null if invalid URL
     */
    public String extractPublicId(String cloudinaryUrl) {
        try {
            if (cloudinaryUrl == null || !cloudinaryUrl.contains("cloudinary.com")) {
                return null;
            }
            
            // URL format: https://res.cloudinary.com/{cloud_name}/raw/upload/{folder}/{public_id}.{format}
            String[] parts = cloudinaryUrl.split("/upload/");
            if (parts.length < 2) {
                return null;
            }
            
            String pathWithExtension = parts[1];
            // Remove file extension
            String publicId = pathWithExtension.substring(0, pathWithExtension.lastIndexOf('.'));
            
            return publicId;
            
        } catch (Exception e) {
            log.error("Failed to extract public_id from URL: {}", cloudinaryUrl, e);
            return null;
        }
    }
}
