<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..900;1,400..900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" crossorigin="anonymous">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<style>
    :root {
        --bg-warm: #f4f4ef;
        --text-dark: #2a2a2a;
        --primary-blue: #2563eb;
    }
    body { font-family: 'Inter', system-ui, -apple-system, sans-serif; background-color: var(--bg-warm); color: var(--text-dark); }
    .font-serif { font-family: 'Playfair Display', 'Times New Roman', serif; }
    @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    .animate-fade-in-up { animation: fadeInUp 1s cubic-bezier(0.2, 0.8, 0.2, 1) forwards; }
    ::-webkit-scrollbar { display: none; }
    * { -ms-overflow-style: none; scrollbar-width: none; outline: none !important; }
</style>