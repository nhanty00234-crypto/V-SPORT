<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" crossorigin="anonymous">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script id="tailwind-config">
  tailwind.config = {
    darkMode: "class",
    theme: {
      extend: {
        colors: {
          primary: {
            DEFAULT: "#5c6c7b", // Muted slate from image
            hover: "#3d4b58",
            light: "rgba(92, 108, 123, 0.1)",
          },
          accent: "#d92550", // Retain red for highlights
          glass: {
            DEFAULT: "rgba(255, 255, 255, 0.6)",
            dark: "rgba(255, 255, 255, 0.4)",
          }
        },
        borderRadius: {
          "2xl": "1.5rem",
          "3xl": "2.5rem",
        },
        fontFamily: {
          sans: ["Plus Jakarta Sans", "Inter", "system-ui", "-apple-system", "sans-serif"],
        }
      }
    }
  };
</script>

<style>
    :root {
        --glass-bg: rgba(255, 255, 255, 0.65);
        --glass-border: rgba(255, 255, 255, 0.4);
        --glass-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.07);
    }

    body { 
        font-family: 'Plus Jakarta Sans', 'Inter', system-ui, -apple-system, sans-serif;
        background: linear-gradient(135deg, #e0e7ec 0%, #f1f4f6 50%, #e0e7ec 100%);
        background-attachment: fixed;
        color: #3d4b58;
        margin: 0;
        padding: 0;
        min-height: 100vh;
    }
    
    /* Glassmorphism Effect */
    .glass-panel {
        background: var(--glass-bg);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid var(--glass-border);
        box-shadow: var(--glass-shadow);
        border-radius: 2rem;
    }

    .glass-card {
        background: rgba(255, 255, 255, 0.5);
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
        border-radius: 1.5rem;
        transition: all 0.3s ease;
    }

    .glass-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
        background: rgba(255, 255, 255, 0.7);
    }

    /* Override standard app-card */
    .app-card {
        @extend .glass-card;
    }

    .sidebar-glass {
        background: rgba(255, 255, 255, 0.4);
        backdrop-filter: blur(20px);
        border-right: 1px solid rgba(255, 255, 255, 0.3);
    }

    /* Scrollbar */
    ::-webkit-scrollbar { width: 5px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: rgba(92, 108, 123, 0.2); border-radius: 10px; }
    ::-webkit-scrollbar-thumb:hover { background: rgba(92, 108, 123, 0.4); }

    /* Layout Adjustments */
    .main-wrapper {
        padding: 2rem;
        perspective: 1000px;
    }

    /* Typography */
    .heading-gradient {
        background: linear-gradient(to right, #3d4b58, #5c6c7b);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    /* Form Overrides */
    input, select, textarea {
        background: rgba(255, 255, 255, 0.5) !important;
        border: 1px solid rgba(255, 255, 255, 0.5) !important;
        backdrop-filter: blur(4px);
    }
</style>