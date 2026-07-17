<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>Bản đồ Sân Thể Thao - V-SPORT</title>
    <jsp:include page="/common/head.jsp" />
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    
    <!-- Leaflet JS & CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

    <style>
        body {
            background-color: var(--vs-surface);
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            overflow-x: hidden;
        }

        /* Full viewport height layout minus header (64px) */
        .map-wrapper {
            position: relative;
            height: calc(100vh - 64px);
            display: flex;
            flex-direction: column;
        }

        @media (max-width: 1023px) {
            .map-wrapper {
                height: calc(100vh - 64px - var(--vs-bottomnav-h));
            }
        }

        /* Sidebar filter container */
        .map-sidebar {
            position: absolute;
            top: 16px;
            left: 16px;
            z-index: 1000;
            width: 380px;
            max-height: calc(100% - 32px);
            background: #ffffff;
            border: 1px solid var(--vs-border);
            border-radius: var(--vs-r-card);
            box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.1), 0 8px 10px -6px rgba(15, 23, 42, 0.1);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        @media (max-width: 767px) {
            .map-sidebar {
                position: relative;
                top: 0;
                left: 0;
                width: 100%;
                max-height: none;
                border-radius: 0;
                box-shadow: none;
                border-left: none;
                border-right: none;
                border-top: none;
            }
        }

        /* Floating GPS button */
        .gps-btn {
            position: absolute;
            top: 16px;
            right: 16px;
            z-index: 1000;
            background: #ffffff;
            border: 1px solid var(--vs-border);
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.12);
            cursor: pointer;
            color: var(--vs-muted);
            transition: all 0.2s ease;
        }
        .gps-btn:hover {
            color: var(--vs-primary);
            border-color: var(--vs-primary);
            transform: scale(1.05);
        }
        .gps-btn.active {
            background: var(--vs-primary);
            color: #ffffff;
            border-color: var(--vs-primary);
        }

        /* Custom Marker style */
        .vs-marker-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            background: var(--vs-primary);
            border: 3px solid #ffffff;
            border-radius: 50%;
            box-shadow: 0 4px 10px rgba(4, 120, 87, 0.4);
            color: #ffffff;
        }

        .vs-marker-icon span {
            font-size: 18px;
            line-height: 1;
        }

        .vs-marker-self {
            background: #3b82f6;
            box-shadow: 0 0 0 6px rgba(59, 130, 246, 0.3);
            border-color: #ffffff;
        }

        /* Leaflet popup customization */
        .leaflet-popup-content-wrapper {
            border-radius: 12px;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
            padding: 0;
            overflow: hidden;
        }
        .leaflet-popup-content {
            margin: 0;
            padding: 12px 14px;
        }
        .leaflet-popup-close-button {
            top: 8px !important;
            right: 8px !important;
        }

        .pb-safe {
            padding-bottom: env(safe-area-inset-bottom, 0px);
        }
    </style>
</head>
<body class="antialiased text-on-surface">

    <jsp:include page="/common/header.jsp" />

    <div class="map-wrapper">
        <!-- Floating controls (Sidebar) -->
        <div class="map-sidebar p-5">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <h2 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                        <span class="material-symbols-outlined text-emerald-700">explore</span>
                        Khám phá V-SPORT
                    </h2>
                    <p class="text-xs text-gray-500 mt-0.5">Tìm sân đấu thể thao quanh bạn</p>
                </div>
            </div>

            <div class="space-y-4 flex-1 overflow-y-auto pr-1">
                <!-- Bộ môn -->
                <div>
                    <label class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Bộ môn thể thao</label>
                    <div class="flex flex-wrap gap-2">
                        <button type="button" class="vs-chip is-active" data-sport-id="" onclick="selectSport(this)">
                            Tất cả
                        </button>
                        <c:forEach var="mon" items="${dsMon}">
                            <button type="button" class="vs-chip" data-sport-id="${mon.monTheThaoID}" onclick="selectSport(this)">
                                ${mon.tenMon}
                            </button>
                        </c:forEach>
                    </div>
                </div>

                <!-- Bán kính tìm kiếm -->
                <div>
                    <label for="radiusSelect" class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Bán kính tìm kiếm</label>
                    <select id="radiusSelect" class="w-full bg-white border border-gray-200 rounded-lg p-2.5 text-sm font-semibold text-gray-800 focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 outline-none" onchange="filterMap()">
                        <option value="">Toàn thành phố</option>
                        <option value="2">Trong vòng 2 km</option>
                        <option value="5">Trong vòng 5 km</option>
                        <option value="10">Trong vòng 10 km</option>
                        <option value="20">Trong vòng 20 km</option>
                    </select>
                </div>

                <!-- Lọc mở cửa & Trống -->
                <div class="pt-2 border-t border-gray-100 space-y-3">
                    <label class="flex items-center justify-between cursor-pointer select-none">
                        <span class="text-sm font-semibold text-gray-700">Đang mở cửa</span>
                        <input type="checkbox" id="openNowCheck" class="sr-only peer" onchange="filterMap()" />
                        <span class="w-9 h-5 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:height-4 after:width-4 after:h-4 after:w-4 after:transition-all peer-checked:bg-emerald-600 relative after:top-[2px] after:left-[2px]"></span>
                    </label>
                </div>
            </div>

            <!-- List Results summary -->
            <div class="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
                <span>Tìm thấy <strong id="resultsCount" class="text-emerald-700">0</strong> cơ sở</span>
                <button type="button" class="text-emerald-700 font-bold hover:underline" onclick="resetFilters()">Đặt lại</button>
            </div>
        </div>

        <!-- Floating GPS Target Locator Button -->
        <button id="gpsBtn" class="gps-btn" onclick="requestGeolocation()" title="Tìm vị trí của tôi">
            <span class="material-symbols-outlined">my_location</span>
        </button>

        <!-- Leaflet Map Container -->
        <div id="map" class="w-full h-full z-0"></div>
    </div>

    <!-- Mobile Bottom Sheet Details -->
    <div id="facilityBottomSheet" class="fixed bottom-0 left-0 right-0 z-[1250] bg-white border-t border-gray-200 rounded-t-2xl shadow-2xl translate-y-full transition-transform duration-300 ease-out md:hidden pb-safe">
        <div class="w-12 h-1.5 bg-gray-300 rounded-full mx-auto my-3 cursor-pointer" onclick="closeBottomSheet()"></div>
        <div class="px-5 pb-6">
            <div class="flex gap-4">
                <img id="bsImage" class="w-24 h-24 object-cover rounded-lg border border-gray-100 shrink-0" src="" alt="Facility" />
                <div class="flex-1 min-w-0">
                    <h3 id="bsTitle" class="font-bold text-gray-900 text-lg truncate">Tên cơ sở</h3>
                    <p id="bsAddress" class="text-xs text-gray-500 line-clamp-2 mt-1">Địa chỉ</p>
                    <div class="flex items-center gap-2 mt-2 flex-wrap">
                        <span id="bsDistance" class="inline-flex items-center gap-1 text-[10px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded">0.0 km</span>
                        <span id="bsCourts" class="inline-flex items-center gap-1 text-[10px] font-semibold text-gray-700 bg-gray-100 px-2 py-0.5 rounded">0 sân sẵn sàng</span>
                    </div>
                </div>
            </div>
            <div class="border-t border-gray-100 my-4"></div>
            <div class="flex items-center justify-between">
                <div>
                    <div class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Giá từ</div>
                    <div id="bsPrice" class="text-base font-extrabold text-emerald-700">100.000đ/giờ</div>
                </div>
                <a id="bsBookingLink" href="#" class="vs-btn vs-btn-primary py-2 px-5 rounded-lg text-sm">
                    <span>Đặt sân</span>
                    <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/customer/common/bottom-nav.jsp" />

    <script>
        const ctx = "${pageContext.request.contextPath}";
        const mapTilerKey = "${maptilerApiKey != null ? maptilerApiKey : ''}";

        let map;
        let activeMarkers = [];
        let userLocation = null;
        let selfMarker = null;
        let currentSportId = "";

        // Default to Ho Chi Minh City coordinates
        const defaultCenter = [10.772561, 106.698021];
        const defaultZoom = 13;

        document.addEventListener('DOMContentLoaded', () => {
            initMap();
            loadFacilities();
        });

        function initMap() {
            // Leaflet Map setup
            map = L.map('map', {
                zoomControl: false // Position zoom control appropriately later
            }).setView(defaultCenter, defaultZoom);

            L.control.zoom({ position: 'bottomright' }).addTo(map);

            // Determine tiles provider
            let tileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
            let attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors';

            if (mapTilerKey) {
                tileUrl = `https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=${mapTilerKey}`;
                attribution = '&copy; <a href="https://www.maptiler.com/">MapTiler</a> &copy; OpenStreetMap contributors';
            }

            L.tileLayer(tileUrl, {
                maxZoom: 19,
                attribution: attribution
            }).addTo(map);

            // Close bottom sheet if clicked elsewhere on map
            map.on('click', () => {
                closeBottomSheet();
            });
        }

        function requestGeolocation() {
            const gpsBtn = document.getElementById('gpsBtn');
            if (gpsBtn.classList.contains('active')) {
                // Disable geolocation filter
                userLocation = null;
                gpsBtn.classList.remove('active');
                if (selfMarker) {
                    map.removeLayer(selfMarker);
                    selfMarker = null;
                }
                filterMap();
                return;
            }

            if (!navigator.geolocation) {
                alert("Trình duyệt của bạn không hỗ trợ định vị GPS.");
                return;
            }

            gpsBtn.innerHTML = `<span class="material-symbols-outlined animate-spin">refresh</span>`;

            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;
                    userLocation = { lat, lon };

                    gpsBtn.classList.add('active');
                    gpsBtn.innerHTML = `<span class="material-symbols-outlined">my_location</span>`;

                    // Update or create self marker
                    if (selfMarker) {
                        selfMarker.setLatLng([lat, lon]);
                    } else {
                        const selfIcon = L.divIcon({
                            className: 'vs-marker-icon vs-marker-self',
                            html: '<span class="material-symbols-outlined">person_pin_circle</span>',
                            iconSize: [36, 36],
                            iconAnchor: [18, 18]
                        });
                        selfMarker = L.marker([lat, lon], { icon: selfIcon }).addTo(map);
                        selfMarker.bindPopup("<b>Vị trí của bạn</b>").openPopup();
                    }

                    map.setView([lat, lon], 14);
                    filterMap();
                },
                (error) => {
                    console.error("GPS Error: ", error);
                    gpsBtn.innerHTML = `<span class="material-symbols-outlined">my_location</span>`;
                    alert("Không thể truy cập GPS của bạn. Vui lòng cấp quyền hoặc thử lại.");
                },
                { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 }
            );
        }

        function selectSport(btn) {
            // Uncheck other sport chips
            const siblings = btn.parentElement.querySelectorAll('.vs-chip');
            siblings.forEach(s => s.classList.remove('is-active'));
            btn.classList.add('is-active');

            currentSportId = btn.getAttribute('data-sport-id');
            filterMap();
        }

        function resetFilters() {
            // Chips reset
            const chips = document.querySelectorAll('.vs-chip');
            chips.forEach(s => s.classList.remove('is-active'));
            chips[0].classList.add('is-active');
            currentSportId = "";

            // Inputs reset
            document.getElementById('radiusSelect').value = "";
            document.getElementById('openNowCheck').checked = false;

            filterMap();
        }

        function filterMap() {
            loadFacilities();
        }

        function loadFacilities() {
            const radius = document.getElementById('radiusSelect').value;
            const openNow = document.getElementById('openNowCheck').checked;

            let url = `${ctx}/api/customer/facilities/map?`;
            
            if (currentSportId) url += `sportId=${currentSportId}&`;
            if (openNow) url += `openNow=true&`;
            
            if (userLocation) {
                url += `latitude=${userLocation.lat}&longitude=${userLocation.lon}&`;
                if (radius) {
                    url += `radiusKm=${radius}&`;
                }
            }

            fetch(url)
                .then(res => res.json())
                .then(data => {
                    if (data.success === false) {
                        console.error("API error:", data.error);
                        return;
                    }
                    displayFacilities(data);
                })
                .catch(err => {
                    console.error("Fetch facilities error:", err);
                });
        }

        function displayFacilities(facilities) {
            // Clear existing markers
            activeMarkers.forEach(m => map.removeLayer(m));
            activeMarkers = [];

            const countEl = document.getElementById('resultsCount');
            if (countEl) countEl.innerText = facilities.length;

            const bounds = L.latLngBounds();

            facilities.forEach(fac => {
                if (!fac.latitude || !fac.longitude) return;

                const customIcon = L.divIcon({
                    className: 'vs-marker-icon',
                    html: '<span class="material-symbols-outlined">sports_tennis</span>',
                    iconSize: [36, 36],
                    iconAnchor: [18, 18]
                });

                const marker = L.marker([fac.latitude, fac.longitude], { icon: customIcon }).addTo(map);
                
                // Desktop popup
                const distanceStr = fac.distanceKm ? `${fac.distanceKm} km` : 'Gần bạn';
                const popupContent = `
                    <div class="p-1 min-w-[210px]">
                        <h4 class="font-bold text-gray-900 text-sm mb-0.5 truncate">${fac.tenCoSo}</h4>
                        <p class="text-xs text-gray-500 mb-2 truncate">${fac.address}</p>
                        <div class="flex items-center gap-1.5 mb-2.5">
                            <span class="text-[10px] font-semibold text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded">${distanceStr}</span>
                            <span class="text-[10px] font-semibold text-gray-700 bg-gray-100 px-1.5 py-0.5 rounded">${fac.readyCourtCount} sân trống</span>
                        </div>
                        <div class="flex items-center justify-between border-t border-gray-100 pt-2 mt-2">
                            <span class="font-extrabold text-emerald-700 text-sm">${formatCurrency(fac.minPrice)}</span>
                            <a href="${ctx}/customer/dat-san?facilityId=${fac.coSoId}" class="inline-flex items-center gap-0.5 text-[11px] font-bold text-white bg-emerald-700 hover:bg-emerald-800 px-2.5 py-1.5 rounded transition-colors text-decoration-none">
                                Đặt sân
                            </a>
                        </div>
                    </div>
                `;
                marker.bindPopup(popupContent);

                // Handle Marker Click (Mobile bottom sheet or desktop pan)
                marker.on('click', () => {
                    if (window.innerWidth < 768) {
                        marker.closePopup();
                        openBottomSheet(fac);
                    } else {
                        map.panTo(marker.getLatLng());
                    }
                });

                activeMarkers.push(marker);
                bounds.extend([fac.latitude, fac.longitude]);
            });

            if (userLocation) {
                bounds.extend([userLocation.lat, userLocation.lon]);
            }

            // Fit map to markers if there are markers
            if (facilities.length > 0) {
                map.fitBounds(bounds, { padding: [50, 50] });
            }
        }

        function openBottomSheet(fac) {
            const sheet = document.getElementById('facilityBottomSheet');
            
            // Populate fields
            document.getElementById('bsTitle').innerText = fac.tenCoSo;
            document.getElementById('bsAddress').innerText = fac.address;
            document.getElementById('bsDistance').innerText = fac.distanceKm ? `${fac.distanceKm} km` : 'Gần đây';
            document.getElementById('bsCourts').innerText = `${fac.readyCourtCount} sân sẵn sàng`;
            document.getElementById('bsPrice').innerText = `${formatCurrency(fac.minPrice)}`;
            document.getElementById('bsBookingLink').href = `${ctx}/customer/dat-san?facilityId=${fac.coSoId}`;

            const imgEl = document.getElementById('bsImage');
            if (fac.imageUrl) {
                imgEl.src = fac.imageUrl;
                imgEl.style.display = 'block';
            } else {
                imgEl.style.display = 'none';
            }

            // Slide up
            sheet.classList.remove('translate-y-full');
        }

        function closeBottomSheet() {
            const sheet = document.getElementById('facilityBottomSheet');
            sheet.classList.add('translate-y-full');
        }

        function formatCurrency(amount) {
            if (!amount) return '0đ';
            return amount.toLocaleString('vi-VN') + 'đ';
        }
    </script>
</body>
</html>
