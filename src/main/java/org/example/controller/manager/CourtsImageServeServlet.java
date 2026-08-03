package org.example.controller.manager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Streams court gallery images saved outside the webapp (~/vsport-uploads/courts/).
 * Mounted at /media/courts/* so URLs stored in DB are /media/courts/coso-<uuid>.jpg.
 * Path traversal is blocked by canonicalization check against the courts root dir.
 */
@WebServlet("/media/courts/*")
public class CourtsImageServeServlet extends HttpServlet {

    static File courtsDir() {
        String configured = System.getenv("VSPORT_UPLOAD_DIR");
        if (configured == null || configured.trim().isEmpty()) {
            configured = System.getProperty("vsport.upload.dir");
        }
        if (configured == null || configured.trim().isEmpty()) {
            configured = new File(System.getProperty("user.home"), "vsport-uploads").getAbsolutePath();
        }
        return new File(configured.trim(), "courts");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = pathInfo.replace('\\', '/');
        if (fileName.contains("..")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        // strip leading /
        if (fileName.startsWith("/")) fileName = fileName.substring(1);

        File root = courtsDir().getAbsoluteFile();
        File candidate = new File(root, fileName).getAbsoluteFile();

        Path rootPath = root.toPath().normalize();
        Path candidatePath = candidate.toPath().normalize();
        if (!candidatePath.startsWith(rootPath) || !candidate.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = guessContentType(fileName);
        if (contentType == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        resp.setContentType(contentType);
        resp.setContentLengthLong(candidate.length());
        resp.setHeader("Cache-Control", "public, max-age=31536000, immutable");
        Files.copy(candidate.toPath(), resp.getOutputStream());
    }

    private static String guessContentType(String name) {
        String lower = name.toLowerCase();
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".gif")) return "image/gif";
        return null;
    }
}
