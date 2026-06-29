
// Context Path
const _ctxPath = '1';

let staffList = [
  /* c:forEach */
    {
      id: 1,
      username: '1',
      fullName: '"c_out_value"',
      roleId: 1,
      roleName: '1'
    }1
  /* /c:forEach */
];

let shiftList = [
  /* c:forEach */
    {
      caLamViecId: 1,
      accountId: 1,
      ngayLam: '1',
      gioBatDau: '1',
      gioKetThuc: '1',
      tenCa: '"c_out_value"',
      viTri: '"c_out_value"',
      trangThai: '"c_out_value"',
      gioNghi: 1,
      ghiChu: `"c_out_value"`
    }1
  /* /c:forEach */
];

function formatDate(str) {
  if (!str) return '';
  const parts = str.split('-');
  if (parts.length !== 3) return str;
  return `${parts[2]}/${parts[1]}/${parts[0]}`;
}

function formatTime(str) {
  if (!str) return '';
  const parts = str.split(':');
  if (parts.length < 2) return str;
  return `${parts[0]}:${parts[1]}`;
}

function getShiftStatus(ngayLamStr, batDauStr, ketThucStr) {
  const now = new Date();
  const [y, m, d] = ngayLamStr.split('-').map(Number);
  const [sh, sm] = batDauStr.split(':').map(Number);
  const [eh, em] = ketThucStr.split(':').map(Number);

  const startDateTime = new Date(y, m - 1, d, sh, sm, 0);
  const endDateTime = new Date(y, m - 1, d, eh, em, 0);
  if (endDateTime < startDateTime) { endDateTime.setDate(endDateTime.getDate() + 1); }

  if (now < startDateTime) return { label: 'Sắp diễn ra', cssClass: 'badge-blue' };
  else if (now > endDateTime) return { label: 'Đã kết thúc', cssClass: 'badge-zinc' };
  else return { label: 'Đang diễn ra', cssClass: 'badge-green live-dot' };
}

function getTrangThaiBadge(trangThai) {
    if (trangThai === 'Published' || trangThai === 'Confirmed') return { label: 'Đã xuất bản', cssClass: 'badge-green' };
    return { label: 'Nháp (Draft)', cssClass: 'badge-yellow' };
}

function toggleDateInputs() {
  const opt = document.getElementById('filterDateOpt').value;
  const container = document.getElementById('dateInputs');
  if (opt === 'custom') {
    container.classList.remove('hidden');
  } else {
    container.classList.add('hidden');
    document.getElementById('filterStartDate').value = '';
    document.getElementById('filterEndDate').value = '';
  }
}

function filterShifts() {
  const searchName = document.getElementById('searchName').value.trim().toLowerCase();
  const filterRole = document.getElementById('filterRole').value;
  const dateOpt = document.getElementById('filterDateOpt').value;
  const startDate = document.getElementById('filterStartDate').value;
  const endDate = document.getElementById('filterEndDate').value;

  const todayStr = new Date().toISOString().split('T')[0];
  let tomorrowStr = '';
  {
    const tom = new Date();
    tom.setDate(tom.getDate() + 1);
    tomorrowStr = tom.toISOString().split('T')[0];
  }

  const filtered = shiftList.filter(s => {
    const staff = staffList.find(st => st.id === s.accountId);
    const staffName = staff ? staff.fullName.toLowerCase() : '';
    const staffUsername = staff ? staff.username.toLowerCase() : '';
    const staffRole = staff ? String(staff.roleId) : '';

    if (searchName && !staffName.includes(searchName) && !staffUsername.includes(searchName)) return false;
    if (filterRole && staffRole !== filterRole) return false;
    if (dateOpt === 'today' && s.ngayLam !== todayStr) return false;
    if (dateOpt === 'tomorrow' && s.ngayLam !== tomorrowStr) return false;
    if (dateOpt === 'custom') {
      if (startDate && s.ngayLam < startDate) return false;
      if (endDate && s.ngayLam > endDate) return false;
    }
    return true;
  });

  renderTable(filtered);
}

function renderTable(list) {
  const tbody = document.getElementById('shiftBody');
  const emptyState = document.getElementById('emptyState');
  document.getElementById('shiftCountDisplay').innerText = `${list.length} ca`;

  if (list.length === 0) {
    tbody.innerHTML = '';
    emptyState.classList.remove('hidden');
    return;
  }
  emptyState.classList.add('hidden');

  list.sort((a, b) => {
    if (a.ngayLam !== b.ngayLam) return b.ngayLam.localeCompare(a.ngayLam);
    return b.gioBatDau.localeCompare(a.gioBatDau);
  });

  tbody.innerHTML = list.map(s => {
    const staff = staffList.find(st => st.id === s.accountId);
    const staffName = staff ? staff.fullName : 'Nhân viên không tồn tại';
    const staffUsername = staff ? staff.username : 'N/A';
    const initial = staffName.substring(0, 1).toUpperCase();

    const statusWork = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);
    const statusSched = getTrangThaiBadge(s.trangThai);
    const dateFormatted = formatDate(s.ngayLam);
    const timeFrame = `${formatTime(s.gioBatDau)} - ${formatTime(s.gioKetThuc)}`;

    return `
      <tr class="hover:bg-purple-50/35 transition-colors">
        <td class="px-5 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8.5 h-8.5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center shrink-0 font-bold text-xs">${initial}</div>
            <div>
              <p class="font-bold text-purple-950 leading-tight">${staffName}</p>
              <p class="text-[10px] text-purple-400 mt-0.5">${staffUsername}</p>
            </div>
          </div>
        </td>
        <td class="px-5 py-4 text-xs">
          <p class="font-semibold text-purple-750">${s.tenCa || 'Tùy chỉnh'} / ${s.viTri || 'Lễ tân'}</p>
        </td>
        <td class="px-5 py-4 text-xs font-medium text-zinc-700">${dateFormatted}</td>
        <td class="px-5 py-4 text-xs font-bold text-purple-900">
          ${timeFrame}
          ${s.gioNghi > 0 ? `<span class="text-[10px] text-red-500 block font-semibold mt-0.5">Nghỉ: ${s.gioNghi}m</span>` : ''}
        </td>
        <td class="px-5 py-4">
            <div class="flex flex-col gap-1 items-start">
                <span class="badge ${statusSched.cssClass}">${statusSched.label}</span>
                <span class="badge ${statusWork.cssClass}">${statusWork.label}</span>
            </div>
        </td>
        <td class="px-5 py-4 text-xs text-zinc-500 max-w-[150px] truncate" title="${s.ghiChu || 'Không có'}">${s.ghiChu || '-'}</td>
        <td class="px-5 py-4 text-right">
          <div class="flex items-center justify-end gap-1">
            <button onclick="editShift(${s.caLamViecId})" class="p-1.5 rounded-lg hover:bg-purple-50 text-purple-600"><span class="material-symbols-outlined text-[18px]">edit</span></button>
            <button onclick="deleteShift(${s.caLamViecId})" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><span class="material-symbols-outlined text-[18px]">delete</span></button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// ============================================
// MODAL & VALIDATION LOGIC CẢI TIẾN
// ============================================

// ============================================
// AJAX & INLINE CONFIGURATION LOGIC
// ============================================

function populateStaffDropdown(selectedId) {
  const select = document.getElementById('shiftStaff');
  select.innerHTML = '<option value="">-- Chọn nhân viên --</option>';
  staffList.forEach(st => {
    const opt = document.createElement('option');
    opt.value = st.id;
    opt.textContent = `[${st.roleName}] ${st.fullName} (${st.username})`;
    if (selectedId && st.id === selectedId) opt.selected = true;
    select.appendChild(opt);
  });
}

function applyShiftTemplate() {
    const tpl = document.getElementById('shiftTemplate').value;
    const start = document.getElementById('shiftStartTime');
    const end = document.getElementById('shiftEndTime');
    const breakTime = document.getElementById('shiftBreakTime');

    if (tpl === 'Ca sáng') { start.value = '06:00'; end.value = '14:00'; breakTime.value = '30'; }
    else if (tpl === 'Ca chiều') { start.value = '14:00'; end.value = '22:00'; breakTime.value = '30'; }
    else if (tpl === 'Ca đêm') { start.value = '22:00'; end.value = '06:00'; breakTime.value = '0'; }
    
    triggerRealtimeValidation();
}

// Generate Weekday Checkboxes dynamically based on shiftDate selection
function updateWeekDays() {
  const dateVal = document.getElementById('shiftDate').value;
  if (!dateVal) return;
  
  const d = new Date(dateVal);
  const day = d.getDay();
  // Get Monday of the selected date's week
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(d.setDate(diff));
  
  const container = document.getElementById('weekDaysCheckboxes');
  container.innerHTML = '';
  
  const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
  const editId = document.getElementById('shiftEditId').value;
  
  for (let i = 0; i < 7; i++) {
    const current = new Date(monday);
    current.setDate(monday.getDate() + i);
    
    const year = current.getFullYear();
    const month = String(current.getMonth() + 1).padStart(2, '0');
    const dateNum = String(current.getDate()).padStart(2, '0');
    const dateStr = `${year}-\${month}-\${dateNum}`;
    const displayDate = `${dateNum}/${month}`;
    
    const isToday = (dateStr === new Date().toISOString().split('T')[0]);
    
    let isChecked = false;
    let isDisabled = false;
    
    if (editId) {
      // In edit mode, check only the exact shift date
      isChecked = (dateStr === dateVal);
      isDisabled = !isChecked;
    }
    
    const checkboxId = `day_${i}`;
    const wrapper = document.createElement('label');
    wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border cursor-pointer select-none transition-all text-center bg-white border-zinc-200 hover:border-purple-300 hover:bg-purple-50/10`;
    
    wrapper.innerHTML = `
      <span class="text-[10px] font-bold text-zinc-500 uppercase tracking-wide">${dayNames[i]}</span>
      <span class="text-sm font-extrabold text-zinc-800 my-1">${displayDate}</span>
      <input type="checkbox" id="${checkboxId}" value="${dateStr}" ${isChecked ? 'checked' : ''} ${isDisabled ? 'disabled' : ''} onchange="updateCheckboxStyles(); triggerRealtimeValidation();"
             class="w-4 h-4 text-purple-650 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer mt-1">
    `;
    container.appendChild(wrapper);
  }
  updateCheckboxStyles();
}

function updateCheckboxStyles() {
  const checkboxes = document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]');
  checkboxes.forEach(cb => {
    const wrapper = cb.closest('label');
    if (cb.checked) {
      wrapper.classList.remove('bg-white', 'border-zinc-200', 'hover:bg-purple-50/10');
      wrapper.classList.add('bg-purple-100/40', 'border-purple-500', 'ring-2', 'ring-purple-400');
    } else {
      const dateStr = cb.value;
      const isToday = (dateStr === new Date().toISOString().split('T')[0]);
      wrapper.classList.remove('bg-purple-100/40', 'border-purple-500', 'ring-2', 'ring-purple-400');
      if (isToday) {
        wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border border-purple-300 ring-1 ring-purple-300 cursor-pointer select-none transition-all text-center bg-purple-50/50`;
      } else {
        wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border border-zinc-200 hover:border-purple-300 hover:bg-purple-50/10 cursor-pointer select-none transition-all text-center bg-white`;
      }
    }
  });
}

function calculateDurationAndOvertime() {
    const staffId = document.getElementById('shiftStaff').value;
    const startVal = document.getElementById('shiftStartTime').value;
    const endVal = document.getElementById('shiftEndTime').value;
    const breakVal = parseInt(document.getElementById('shiftBreakTime').value) || 0;
    
    const displayDiv = document.getElementById('shiftDurationDisplay');
    
    if (!startVal || !endVal) {
        displayDiv.innerHTML = '';
        displayDiv.classList.add('hidden');
        return;
    }

    const start = new Date(`2000-01-01T${startVal}:00`);
    let end = new Date(`2000-01-01T${endVal}:00`);
    if (end < start) end.setDate(end.getDate() + 1); // Overnight shift
    
    const diffMs = end - start;
    const diffMins = Math.floor(diffMs / 60000);
    const workMins = diffMins - breakVal;
    
    if (workMins <= 0) {
        displayDiv.innerHTML = `<div class="p-3 bg-red-50 text-red-800 rounded-xl text-sm border border-red-200">Giờ làm việc không hợp lệ (thời gian nghỉ quá lớn hoặc nhập sai giờ).</div>`;
        displayDiv.classList.remove('hidden');
        return;
    }

    const workHours = (workMins / 60).toFixed(1);
    let html = `<div class="p-3 bg-emerald-50 text-emerald-800 rounded-xl text-sm border border-emerald-200 flex items-center justify-between">
                  <span><strong>Tổng giờ làm một ca:</strong> ${workHours} giờ</span>
                  <span class="text-xs opacity-70">(Đã trừ ${breakVal} phút nghỉ)</span>
                </div>`;

    if (staffId) {
        const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
        let datesToCalculate = checkedCheckboxes.map(cb => cb.value);
        if (datesToCalculate.length === 0) {
            const referenceDate = document.getElementById('shiftDate').value;
            if (referenceDate) datesToCalculate.push(referenceDate);
        }
        
        if (datesToCalculate.length > 0) {
            const months = [...new Set(datesToCalculate.map(d => d.substring(0, 7)))];
            
            months.forEach(month => {
                let existingMins = 0;
                const editId = document.getElementById('shiftEditId').value;
                
                shiftList.forEach(s => {
                    if (s.accountId == staffId && s.ngayLam.startsWith(month) && s.caLamViecId != editId) {
                        const sStart = new Date(`2000-01-01T${s.gioBatDau}`);
                        let sEnd = new Date(`2000-01-01T${s.gioKetThuc}`);
                        if (sEnd < sStart) sEnd.setDate(sEnd.getDate() + 1);
                        
                        let sDiffMins = Math.floor((sEnd - sStart) / 60000) - (s.gioNghi || 0);
                        existingMins += sDiffMins;
                    }
                });

                const newShiftsCountInMonth = datesToCalculate.filter(d => d.startsWith(month)).length;
                const totalMonthMins = existingMins + (newShiftsCountInMonth * workMins);
                const totalMonthHours = (totalMonthMins / 60).toFixed(1);
                
                if (totalMonthHours > 160) {
                    html += `<div class="mt-2 p-3 bg-amber-50 text-amber-800 rounded-xl text-sm border border-amber-200 flex gap-2 items-start">
                               <span class="material-symbols-outlined text-[18px]">warning</span>
                               <div>
                                 <strong>Cảnh báo vượt giờ:</strong> Nhân viên này sẽ đạt <strong>${totalMonthHours}h</strong> trong tháng ${month} (vượt mức 160h quy định).
                               </div>
                             </div>`;
                } else {
                    html += `<div class="mt-1 text-[11px] text-zinc-500 text-right">Luỹ kế tháng ${month}: ${totalMonthHours}h / 160h</div>`;
                }
            });
        }
    }
    
    displayDiv.innerHTML = html;
    displayDiv.classList.remove('hidden');
}

let validationTimeout = null;
function triggerRealtimeValidation() {
    calculateDurationAndOvertime();
    clearTimeout(validationTimeout);
    validationTimeout = setTimeout(runRealtimeValidation, 300);
}

async function runRealtimeValidation() {
    const staffId = document.getElementById('shiftStaff').value;
    const gioBatDau = document.getElementById('shiftStartTime').value;
    const gioKetThuc = document.getElementById('shiftEndTime').value;
    const gioNghi = document.getElementById('shiftBreakTime').value || '0';
    const editId = document.getElementById('shiftEditId').value;
    
    const alertBox = document.getElementById('shiftAlertBox');
    const submitBtn = document.getElementById('btnSubmitShift');
    
    if (!staffId || !gioBatDau || !gioKetThuc) {
        alertBox.classList.add('hidden');
        submitBtn.disabled = false;
        return;
    }

    const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
    let datesToValidate = checkedCheckboxes.map(cb => cb.value);
    
    if (datesToValidate.length === 0) {
        const referenceDate = document.getElementById('shiftDate').value;
        if (referenceDate) datesToValidate.push(referenceDate);
    }
    
    if (datesToValidate.length === 0) {
        alertBox.classList.add('hidden');
        submitBtn.disabled = false;
        return;
    }

    try {
        const validationPromises = datesToValidate.map(date => {
            const url = `${_ctxPath}/manager/ca-lam?action=validate&accountId=${staffId}&ngayLam=${date}&gioBatDau=${gioBatDau}&gioKetThuc=${gioKetThuc}&gioNghi=${gioNghi}` + (editId ? `&caLamViecId=${editId}` : '');
            return fetch(url).then(res => res.json());
        });

        const results = await Promise.all(validationPromises);
        
        let allErrors = [];
        let allWarnings = [];
        
        results.forEach((res, idx) => {
            const dateStr = datesToValidate[idx];
            const dateFormatted = formatDate(dateStr);
            if (!res.valid) {
                res.errors.forEach(err => {
                    allErrors.push(`[Ngày ${dateFormatted}]: ${err}`);
                });
            }
            if (res.warnings && res.warnings.length > 0) {
                res.warnings.forEach(warn => {
                    allWarnings.push(`[Ngày ${dateFormatted}]: ${warn}`);
                });
            }
        });

        alertBox.innerHTML = '';
        
        if (allErrors.length > 0) {
            alertBox.className = 'p-3 rounded-xl text-sm flex flex-col gap-1.5 bg-red-50 border border-red-200 text-red-750 animate-fade-in-up mt-2';
            let html = '<div class="flex items-center gap-1.5 font-bold"><span class="material-symbols-outlined text-[18px]">cancel</span> Lỗi xung đột ca (Hệ thống chặn lưu):</div><ul class="list-disc pl-5 space-y-0.5">';
            allErrors.forEach(err => { html += `<li>${err}</li>`; });
            html += '</ul>';
            alertBox.innerHTML = html;
            alertBox.classList.remove('hidden');
            submitBtn.disabled = true;
        } else if (allWarnings.length > 0) {
            alertBox.className = 'p-3 rounded-xl text-sm flex flex-col gap-1.5 bg-amber-50 border border-amber-200 text-amber-700 animate-fade-in-up mt-2';
            let html = '<div class="flex items-center gap-1.5 font-bold"><span class="material-symbols-outlined text-[18px]">warning</span> Cảnh báo lưu ý:</div><ul class="list-disc pl-5 space-y-0.5">';
            allWarnings.forEach(warn => { html += `<li>${warn}</li>`; });
            html += '</ul>';
            alertBox.innerHTML = html;
            alertBox.classList.remove('hidden');
            submitBtn.disabled = false;
        } else {
            alertBox.classList.add('hidden');
            submitBtn.disabled = false;
        }
    } catch (err) {
        console.error('Validation API failed:', err);
    }
}

function resetForm() {
    document.getElementById('inlineShiftForm').reset();
    document.getElementById('shiftEditId').value = '';
    document.getElementById('formTitle').innerHTML = `<span class="material-symbols-outlined text-purple-650 text-[22px]">calendar_month</span> Phân ca làm việc mới`;
    
    // Set default values
    document.getElementById('shiftDate').value = new Date().toISOString().split('T')[0];
    document.getElementById('shiftTemplate').value = 'Tùy chỉnh';
    document.getElementById('shiftRole').value = 'Lễ tân';
    document.getElementById('shiftStatusOption').value = 'Published';
    document.getElementById('shiftBreakTime').value = '0';
    
    document.getElementById('shiftDurationDisplay').innerHTML = '';
    document.getElementById('shiftDurationDisplay').classList.add('hidden');
    document.getElementById('shiftAlertBox').innerHTML = '';
    document.getElementById('shiftAlertBox').classList.add('hidden');
    document.getElementById('btnSubmitShift').disabled = false;
    
    populateStaffDropdown(null);
    updateWeekDays();
}

function editShift(id) {
  const s = shiftList.find(x => x.caLamViecId === id);
  if (!s) return;

  document.getElementById('formTitle').innerHTML = `<span class="material-symbols-outlined text-purple-600 text-[22px]">edit_calendar</span> Chỉnh sửa ca làm việc`;
  
  document.getElementById('shiftEditId').value = s.caLamViecId;
  document.getElementById('shiftDate').value = s.ngayLam;
  document.getElementById('shiftStartTime').value = formatTime(s.gioBatDau);
  document.getElementById('shiftEndTime').value = formatTime(s.gioKetThuc);
  document.getElementById('shiftTemplate').value = s.tenCa || 'Tùy chỉnh';
  document.getElementById('shiftRole').value = s.viTri || 'Lễ tân';
  document.getElementById('shiftBreakTime').value = s.gioNghi || 0;
  document.getElementById('shiftStatusOption').value = s.trangThai || 'Draft';
  document.getElementById('shiftNotes').value = s.ghiChu || '';
  
  document.getElementById('btnSubmitShift').disabled = false;

  populateStaffDropdown(s.accountId);
  
  // Update weekdays list and check ONLY the current shift's date
  updateWeekDays();
  
  // Scroll to form smoothly
  document.getElementById('inlineShiftForm').scrollIntoView({ behavior: 'smooth', block: 'center' });
  triggerRealtimeValidation();
}

async function deleteShift(id) {
  if (confirm("Xóa ca làm việc này? Hành động này không thể hoàn tác.")) {
    try {
      const response = await fetch(`${_ctxPath}/manager/ca-lam?action=delete&id=${id}&format=json`, {
        method: 'POST'
      });
      if (response.ok) {
        const res = await response.json();
        if (res.success) {
          showToast('success', 'Đã xóa ca làm việc thành công!');
          await loadScheduleData();
        } else {
          showToast('error', res.error || 'Không thể xóa ca làm việc.');
        }
      }
    } catch (err) {
      console.error(err);
      showToast('error', 'Lỗi kết nối hệ thống.');
    }
  }
}

// Unified dynamic loader for shifts via AJAX format=json
async function loadScheduleData() {
  try {
    const response = await fetch(`${_ctxPath}/manager/ca-lam?format=json`);
    if (response.ok) {
      const data = await response.json();
      shiftList = data.shifts || [];
      // Rerender table
      filterShifts();
      // Rerender calendar grid
      if (!document.getElementById('calendarView').classList.contains('hidden')) {
        renderCalendar();
      }
    }
  } catch (error) {
    console.error("Lỗi khi tải lại lịch làm việc:", error);
  }
}

// Convert date string yyyy-MM-dd to Vietnamese "thứ X ngày dd/MM/yyyy"
function getWeekdayAndDateStr(dateStr) {
  const [y, m, d] = dateStr.split('-').map(Number);
  const dateObj = new Date(y, m - 1, d);
  const dayIdx = dateObj.getDay();
  const dayNames = ['chủ Nhật', 'thứ Hai', 'thứ Ba', 'thứ Tư', 'thứ Năm', 'thứ Sáu', 'thứ Bảy'];
  const formattedDate = `${String(d).padStart(2, '0')}/${String(m).padStart(2, '0')}/${y}`;
  return `${dayNames[dayIdx]} ngày ${formattedDate}`;
}

// Display the required Success Result details banner
function showSuccessBanner(staffName, startTime, endTime, datesAndWeekdays) {
  const banner = document.getElementById('successResultBanner');
  const bannerText = document.getElementById('successBannerText');
  
  bannerText.innerHTML = `Nhân viên <strong>${staffName}</strong> đã được phân ca làm từ <strong>${startTime}</strong> tới <strong>${endTime}</strong> ngày và thứ <strong>${datesAndWeekdays}</strong> của nhân viên này làm việc.`;
  
  banner.classList.remove('hidden');
}

function scrollToCalendar() {
  switchScheduleView('calendar');
  setTimeout(() => {
    const target = document.getElementById('calendarView');
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }, 150);
}

// Toast Notifications Helper
function showToast(type, message) {
  let container = document.getElementById('toastContainer');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'fixed top-5 right-5 z-[100] flex flex-col gap-3 max-w-sm w-full pointer-events-none';
    document.body.appendChild(container);
  }
  
  const toast = document.createElement('div');
  toast.className = 'pointer-events-auto flex items-center gap-3 p-4 rounded-xl border shadow-lg transition-all transform translate-x-10 opacity-0 duration-300 bg-white border-purple-100';
  
  let icon = 'info';
  let iconColor = 'text-blue-500';
  
  if (type === 'success') {
    icon = 'check_circle';
    iconColor = 'text-emerald-500';
  } else if (type === 'error') {
    icon = 'cancel';
    iconColor = 'text-red-500';
  } else if (type === 'warning') {
    icon = 'warning';
    iconColor = 'text-amber-500';
  }
  
  toast.innerHTML = `
    <span class="material-symbols-outlined ${iconColor} shrink-0">${icon}</span>
    <p class="text-sm font-semibold text-zinc-700 flex-1 leading-snug">${message}</p>
    <button class="text-zinc-400 hover:text-zinc-700 transition-colors shrink-0" onclick="this.parentElement.remove()">
      <span class="material-symbols-outlined text-[18px]">close</span>
    </button>
  `;
  
  container.appendChild(toast);
  
  setTimeout(() => {
    toast.classList.remove('translate-x-10', 'opacity-0');
  }, 10);
  
  setTimeout(() => {
    toast.classList.add('opacity-0', 'scale-95');
    setTimeout(() => {
      toast.remove();
    }, 300);
  }, 4000);
}

async function handleInlineShiftSubmit(e) {
  e.preventDefault();
  
  const submitBtn = document.getElementById('btnSubmitShift');
  if (submitBtn.disabled) {
    alert("Đang có lỗi xung đột ca hoặc dữ liệu không hợp lệ. Vui lòng kiểm tra lại!");
    return;
  }
  
  const staffId = document.getElementById('shiftStaff').value;
  const startTime = document.getElementById('shiftStartTime').value;
  const endTime = document.getElementById('shiftEndTime').value;
  const editId = document.getElementById('shiftEditId').value;
  
  if (!staffId) {
    alert("Vui lòng chọn nhân viên!");
    return;
  }
  if (!startTime || !endTime) {
    alert("Vui lòng nhập giờ bắt đầu và giờ kết thúc!");
    return;
  }
  
  const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
  
  if (!editId && checkedCheckboxes.length === 0) {
    alert("Vui lòng chọn ít nhất một ngày làm việc trong tuần!");
    return;
  }
  
  const originalBtnText = submitBtn.innerHTML;
  submitBtn.disabled = true;
  submitBtn.innerHTML = `
    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg> Đang lưu...
  `;
  
  try {
    const staffSelect = document.getElementById('shiftStaff');
    const staffName = staffSelect.options[staffSelect.selectedIndex].text.split('] ')[1] || staffSelect.options[staffSelect.selectedIndex].text;
    
    if (editId) {
      // Edit Mode (single day)
      const dateToSave = checkedCheckboxes.length > 0 ? checkedCheckboxes[0].value : document.getElementById('shiftDate').value;
      
      const params = new URLSearchParams();
      params.append('action', 'update');
      params.append('format', 'json');
      params.append('caLamViecId', editId);
      params.append('accountId', staffId);
      params.append('coSoId', document.getElementById('shiftFacility').value);
      params.append('ngayLam', dateToSave);
      params.append('gioBatDau', startTime);
      params.append('gioKetThuc', endTime);
      params.append('tenCa', document.getElementById('shiftTemplate').value);
      params.append('viTri', document.getElementById('shiftRole').value);
      params.append('trangThai', document.getElementById('shiftStatusOption').value);
      params.append('gioNghi', document.getElementById('shiftBreakTime').value || '0');
      params.append('ghiChu', document.getElementById('shiftNotes').value);
      params.append('reason', 'Cập nhật ca làm việc');
      
      const response = await fetch(`${_ctxPath}/manager/ca-lam`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
      });
      
      if (response.ok) {
        const res = await response.json();
        if (res.success) {
          showToast('success', 'Đã cập nhật ca làm việc thành công!');
          
          const weekdayAndDateStr = getWeekdayAndDateStr(dateToSave);
          showSuccessBanner(staffName, startTime, endTime, weekdayAndDateStr);
          
          await loadScheduleData();
          resetForm();
          scrollToCalendar();
        } else {
          showToast('error', res.error || 'Cập nhật thất bại');
        }
      } else {
        showToast('error', 'Lỗi kết nối máy chủ');
      }
    } else {
      // Add Mode (multiple days in parallel)
      const promises = checkedCheckboxes.map(cb => {
        const dateToSave = cb.value;
        const params = new URLSearchParams();
        params.append('action', 'add');
        params.append('format', 'json');
        params.append('accountId', staffId);
        params.append('coSoId', document.getElementById('shiftFacility').value);
        params.append('ngayLam', dateToSave);
        params.append('gioBatDau', startTime);
        params.append('gioKetThuc', endTime);
        params.append('tenCa', document.getElementById('shiftTemplate').value);
        params.append('viTri', document.getElementById('shiftRole').value);
        params.append('trangThai', document.getElementById('shiftStatusOption').value);
        params.append('gioNghi', document.getElementById('shiftBreakTime').value || '0');
        params.append('ghiChu', document.getElementById('shiftNotes').value);
        
        return fetch(`${_ctxPath}/manager/ca-lam`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: params.toString()
        }).then(res => res.json());
      });
      
      const results = await Promise.all(promises);
      
      const successes = results.filter(r => r.success);
      const errors = results.filter(r => !r.success);
      
      if (successes.length > 0) {
        showToast('success', `Đã phân ca thành công cho ${successes.length} ngày!`);
        
        const dateStrings = checkedCheckboxes.map(cb => getWeekdayAndDateStr(cb.value));
        const datesFormattedText = dateStrings.join(', ');
        
        showSuccessBanner(staffName, startTime, endTime, datesFormattedText);
        
        await loadScheduleData();
        resetForm();
        scrollToCalendar();
      }
      
      if (errors.length > 0) {
        const errorMsgs = [...new Set(errors.map(e => e.error))].join('; ');
        showToast('error', `Có ${errors.length} lỗi xảy ra: ${errorMsgs}`);
      }
    }
  } catch (err) {
    console.error(err);
    showToast('error', 'Đã xảy ra lỗi trong quá trình xử lý');
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerHTML = originalBtnText;
  }
}

function switchScheduleView(viewMode) {
  // Logic giữ nguyên như trước (đổi qua lại Lịch / Bảng)
  const tableView = document.getElementById('tableView');
  const calendarView = document.getElementById('calendarView');
  const tableBtn = document.getElementById('viewTableBtn');
  const calendarBtn = document.getElementById('viewCalendarBtn');

  if (viewMode == 'table') {
    tableView.classList.remove('hidden'); calendarView.classList.add('hidden');
    tableBtn.classList.add('bg-white', 'text-purple-700', 'shadow-sm'); tableBtn.classList.remove('text-purple-600', 'hover:text-purple-700');
    calendarBtn.classList.remove('bg-white', 'text-purple-700', 'shadow-sm'); calendarBtn.classList.add('text-purple-600', 'hover:text-purple-700');
  } else if (viewMode == 'calendar') {
    tableView.classList.add('hidden'); calendarView.classList.remove('hidden');
    calendarBtn.classList.add('bg-white', 'text-purple-700', 'shadow-sm'); calendarBtn.classList.remove('text-purple-600', 'hover:text-purple-700');
    tableBtn.classList.remove('bg-white', 'text-purple-700', 'shadow-sm'); tableBtn.classList.add('text-purple-600', 'hover:text-purple-700');
    renderCalendar();
  }
}

// ================= Lịch Tuần (Calendar) Helper =================
function getMonday(date) { const d = new Date(date); const day = d.getDay(); const diff = d.getDate() - day + (day === 0 ? -6 : 1); return new Date(d.setDate(diff)); }
let currentWeekStart = getMonday(new Date());
function changeWeek(direction) { currentWeekStart.setDate(currentWeekStart.getDate() + (direction * 7)); renderCalendar(); }

function renderCalendar() {
  const grid = document.getElementById('calendarGrid');
  const weekRangeDisplay = document.getElementById('weekRangeDisplay');
  const weekEnd = new Date(currentWeekStart); weekEnd.setDate(weekEnd.getDate() + 6);
  const formatDateVN = (date) => date.getDate() + '/' + (date.getMonth() + 1);
  weekRangeDisplay.textContent = formatDateVN(currentWeekStart) + ' - ' + formatDateVN(weekEnd);

  const days = [];
  for (let i = 0; i < 7; i++) { const dayDate = new Date(currentWeekStart); dayDate.setDate(dayDate.getDate() + i); days.push(dayDate); }

  const shiftsByDate = {};
  days.forEach(day => { const dateStr = day.toISOString().split('T')[0]; shiftsByDate[dateStr] = shiftList.filter(s => s.ngayLam === dateStr); });

  let html = '<div class="grid grid-cols-7 gap-4">';
  days.forEach(day => {
    const dateStr = day.toISOString().split('T')[0];
    const dayShifts = shiftsByDate[dateStr] || [];
    const dayName = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'][day.getDay() === 0 ? 6 : day.getDay() - 1];
    const dateNum = day.getDate();
    const isToday = dateStr === new Date().toISOString().split('T')[0];

    html += `<div class="flex flex-col gap-2 min-h-[400px]">
        <div class="text-center pb-2 border-b border-purple-50">
          <p class="text-xs font-semibold text-purple-600 uppercase">${dayName}</p>
          <p class="text-lg font-bold ${isToday ? 'text-purple-600' : 'text-zinc-800'}">${dateNum}</p>
        </div>
        <div class="flex flex-col gap-2 flex-1">`;

    if (dayShifts.length === 0) {
      html += `<div class="text-center text-zinc-400 text-xs italic py-4">Không có ca</div>`;
    } else {
      dayShifts.sort((a, b) => a.gioBatDau.localeCompare(b.gioBatDau));
      dayShifts.forEach(s => {
        const staff = staffList.find(st => st.id === s.accountId);
        if (!staff) return;
        const timeFrame = formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc);
        const status = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);
        let roleColor = ''; let bgColor = '';
        if (staff.roleId === 4) { roleColor = 'text-green-600'; bgColor = 'bg-green-50 border-green-200 hover:bg-green-100'; } 
        else if (staff.roleId === 5) { roleColor = 'text-orange-600'; bgColor = 'bg-orange-50 border-orange-200 hover:bg-orange-100'; } 
        else { roleColor = 'text-blue-600'; bgColor = 'bg-blue-50 border-blue-200 hover:bg-blue-100'; }

        html += `<div class="shift-block ${bgColor} border rounded-lg p-2 cursor-pointer transition-all shadow-sm" onclick="editShift(${s.caLamViecId})" title="Nhấn để chỉnh sửa">
            <div class="flex items-center justify-between mb-1">
              <span class="text-[10px] font-bold ${roleColor}">${s.tenCa || 'Tùy chỉnh'}</span>
              <span class="text-[9px] px-1 py-0.5 rounded ${status.cssClass}">${status.label}</span>
            </div>
            <p class="text-[11px] font-bold text-zinc-700 mb-1">${timeFrame}</p>
            <div class="flex items-center gap-2">
              <div class="w-5 h-5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">${staff.fullName.substring(0, 1).toUpperCase()}</div>
              <p class="text-xs text-zinc-650 truncate">${staff.fullName}</p>
            </div>
          </div>`;
      });
    }
    html += `</div></div>`;
  });
  html += '</div>';
  grid.innerHTML = html;
}

document.addEventListener('DOMContentLoaded', () => {
  // Populate staff dropdown
  populateStaffDropdown(null);
  
  // Set date picker to today and build weekdays
  const shiftDateInput = document.getElementById('shiftDate');
  if (shiftDateInput) {
    shiftDateInput.value = new Date().toISOString().split('T')[0];
    updateWeekDays();
  }
  
  // Default to Calendar view to see the weekly schedule diagram directly under the form
  switchScheduleView('calendar');
  
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => { document.getElementById('sidebar').classList.toggle('-translate-x-full'); });
  }
});
